import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:warebox_seller/pages/warehouse/warehouse_page.dart';
import 'package:firebase_auth/firebase_auth.dart'; // for `AsyncMemoizer`

class EditWarehousePage extends StatefulWidget {
  final Warehouse warehouse; // Assume Warehouse is a defined model class

  const EditWarehousePage({Key? key, required this.warehouse})
      : super(key: key);

  @override
  State<EditWarehousePage> createState() => _EditWarehousePageState();
}

class _EditWarehousePageState extends State<EditWarehousePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  File? _imageFile; // _imageFile is nullable
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String? uid = FirebaseAuth.instance.currentUser?.uid;
  List<File> _detailImageFiles = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.warehouse.itemName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickDetailImages() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      List<File> newPickedFiles =
          pickedFiles.map((pickedFile) => File(pickedFile.path)).toList();

      // Memastikan jumlah total gambar tidak lebih dari 5
      if (_detailImageFiles.length + newPickedFiles.length > 5) {
        int availableSlots = 5 - _detailImageFiles.length;
        newPickedFiles = newPickedFiles.take(availableSlots).toList();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You can only add up to 5 images.'),
          ),
        );
      }

      setState(() {
        _detailImageFiles.addAll(newPickedFiles);
      });
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('User not logged in.');

      String fileName =
          'warehouse_${DateTime.now().millisecondsSinceEpoch}.png';
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('warehouse_images/$uid/$fileName');
      UploadTask uploadTask = storageReference.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadURL = await snapshot.ref.getDownloadURL();
      return downloadURL;
    } on FirebaseException catch (e) {
      print(e);
      return null;
    }
  }

  Future<List<String>> _uploadDetailImages(List<File> imageFiles) async {
    List<String> imageUrls = [];

    // Menggunakan forEach dengan async/await menggunakan 'Future.wait'
    await Future.wait(imageFiles.map((imageFile) async {
      String? imageUrl = await _uploadImage(imageFile);
      if (imageUrl != null) {
        imageUrls.add(imageUrl);
      } else {
        throw Exception('Failed to upload image');
      }
    }));

    return imageUrls;
  }

  Future<void> _updateWarehouse() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await _uploadImage(_imageFile!);
        if (imageUrl == null) {
          // Handle the case where the image upload fails
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to upload image. Please try again.')),
          );
          setState(() => _isLoading = false);
          return;
        }
      }

      // Upload detail images and get the URLs
      List<String> newImageUrls = [];
      if (_detailImageFiles.isNotEmpty) {
        newImageUrls = await _uploadDetailImages(_detailImageFiles);
        if (newImageUrls.length != _detailImageFiles.length) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Failed to upload all detail images. Please try again.')),
          );
          setState(() => _isLoading = false);
          return;
        }
      }

      // Merge existing and new detail image URLs
      List<String> allImageUrls =
          List.from(widget.warehouse.detailImageUrls ?? [])
            ..addAll(newImageUrls);

      // Ensure no more than 5 image URLs are stored
      if (allImageUrls.length > 5) {
        allImageUrls = allImageUrls.sublist(0, 5);
      }

      // Create a map of data to update
      Map<String, dynamic> updatedData = {
        'itemName': _nameController.text,
        'detailImageUrls': allImageUrls,
      };
      if (imageUrl != null) {
        updatedData['warehouseImageUrl'] = imageUrl;
      }

      // Update the data in Firestore
      await FirebaseFirestore.instance
          .collection('warehouses')
          .doc(widget.warehouse.id)
          .update(updatedData)
          .then(
              (_) => Navigator.of(context).pop(true)) // return true if updated
          .catchError((e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to update warehouse. Please try again.')),
        );
      });

      setState(() => _isLoading = false);
    }
  }

  Widget _buildDetailImagePicker() {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: _detailImageFiles.length + 1, // Include the add button
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemBuilder: (BuildContext context, int index) {
        if (index < _detailImageFiles.length) {
          // Tampilkan gambar yang telah dipilih
          return Stack(
            children: [
              Image.file(
                _detailImageFiles[index],
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  icon: Icon(Icons.close, size: 16, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      // Remove the image from the list
                      _detailImageFiles.removeAt(index);
                    });
                  },
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ),
            ],
          );
        } else {
          // Tombol untuk menambahkan gambar baru
          return GestureDetector(
            onTap: () {
              if (_detailImageFiles.length < 5) {
                _pickDetailImages(); // Pastikan fungsi ini memperbolehkan pemilihan multi image
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('You can only add up to 5 images.'),
                  ),
                );
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.add,
                color: Colors.white70,
              ),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Warehouse'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter warehouse name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    if (_imageFile != null)
                      Image.file(_imageFile!)
                    else if (widget.warehouse.warehouseImageUrl != null)
                      Image.network(widget.warehouse.warehouseImageUrl!)
                    else
                      Text('No image selected'),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: Text('Select Image'),
                    ),
                    SizedBox(height: 20),
                    _buildDetailImagePicker(),
                    ElevatedButton(
                      onPressed: _updateWarehouse,
                      child: Text('Update Warehouse'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
