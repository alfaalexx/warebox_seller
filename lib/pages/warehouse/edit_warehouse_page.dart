import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:warebox_seller/pages/warehouse/warehouse_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

import '../../widget/custom_dropdownEdit.dart';

class EditWarehousePage extends StatefulWidget {
  final Warehouse warehouse; // Assume Warehouse is a defined model class

  const EditWarehousePage({Key? key, required this.warehouse})
      : super(key: key);

  @override
  State<EditWarehousePage> createState() => _EditWarehousePageState();
}

class _EditWarehousePageState extends State<EditWarehousePage> {
  final _formKey = GlobalKey<FormState>();
  File? _imageFile; // _imageFile is nullable
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String? uid = FirebaseAuth.instance.currentUser?.uid;
  List<File> _detailImageFiles = [];

  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _itemDescriptionController;
  late TextEditingController _itemLargeController;
  late TextEditingController _quantityController;
  late TextEditingController _serialNumberController;
  late TextEditingController _locationController;
  late TextEditingController _warehouseStatusController;
  late TextEditingController _featuresController;
  late TextEditingController _additionalNotesController;
  late TextEditingController _pricePerDayController;
  late TextEditingController _pricePerWeekController;
  late TextEditingController _pricePerMonthController;
  late TextEditingController _pricePerYearController;

  String formatRupiah(double value) {
    final formatter = NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0);
    return formatter.format(value);
  }

  void _calculateAndSetPeriodPrices() {
    double pricePerDay = double.tryParse(_pricePerDayController.text) ?? 0.0;
    // Calculate other prices based on pricePerDay
    _pricePerWeekController.text = (pricePerDay * 7).toString();
    _pricePerMonthController.text = (pricePerDay * 30).toString();
    _pricePerYearController.text = (pricePerDay * 365).toString();
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.warehouse.itemName);
    _categoryController =
        TextEditingController(text: widget.warehouse.category);
    _itemDescriptionController =
        TextEditingController(text: widget.warehouse.itemDescription);
    _itemLargeController =
        TextEditingController(text: widget.warehouse.itemLarge.toString());
    _quantityController =
        TextEditingController(text: widget.warehouse.quantity.toString());
    _serialNumberController =
        TextEditingController(text: widget.warehouse.serialNumber);
    _locationController =
        TextEditingController(text: widget.warehouse.location);
    _warehouseStatusController =
        TextEditingController(text: widget.warehouse.warehouseStatus);
    _featuresController =
        TextEditingController(text: widget.warehouse.features);
    _additionalNotesController =
        TextEditingController(text: widget.warehouse.additionalNotes);
    _pricePerDayController =
        TextEditingController(text: widget.warehouse.pricePerDay.toString());
    _pricePerWeekController =
        TextEditingController(text: widget.warehouse.pricePerWeek.toString());
    _pricePerMonthController =
        TextEditingController(text: widget.warehouse.pricePerMonth.toString());
    _pricePerYearController =
        TextEditingController(text: widget.warehouse.pricePerYear.toString());

    _calculateAndSetPeriodPrices();
    _pricePerDayController.addListener(_calculateAndSetPeriodPrices);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _itemDescriptionController.dispose();
    _itemLargeController.dispose();
    _quantityController.dispose();
    _serialNumberController.dispose();
    _locationController.dispose();
    _warehouseStatusController.dispose();
    _featuresController.dispose();
    _additionalNotesController.dispose();
    _pricePerDayController.dispose();
    _pricePerWeekController.dispose();
    _pricePerMonthController.dispose();
    _pricePerYearController.dispose();
    _pricePerDayController.removeListener(_calculateAndSetPeriodPrices);
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

  Future<void> _deleteImageFromFirebase(String imageUrl) async {
    try {
      // Get the reference to the file from the URL
      Reference photoRef = FirebaseStorage.instance.refFromURL(imageUrl);

      // Delete the file from Firebase Storage
      await photoRef.delete();
      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image deleted successfully.'),
        ),
      );
    } on FirebaseException catch (e) {
      // Handle any errors
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error occurred while deleting the image.'),
        ),
      );
    }
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
        'category': _categoryController.text,
        'itemDescription': _itemDescriptionController.text,
        'itemLarge': int.tryParse(_itemLargeController.text),
        'quantity': int.tryParse(_quantityController.text),
        'serialNumber': _serialNumberController.text,
        'location': _locationController.text,
        'warehouseStatus': _warehouseStatusController.text,
        'features': _featuresController.text,
        'additionalNotes': _additionalNotesController.text,
        'pricePerDay': double.tryParse(_pricePerDayController.text),
        'pricePerWeek': double.tryParse(_pricePerWeekController.text),
        'pricePerMonth': double.tryParse(_pricePerMonthController.text),
        'pricePerYear': double.tryParse(_pricePerYearController.text),
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
    // Ensure we provide a default empty list if `detailImageUrls` is null
    List<String> existingImageUrls = widget.warehouse.detailImageUrls ?? [];

    // Jumlah total item adalah jumlah gambar lama plus gambar baru ditambah satu untuk tombol tambah
    int totalItemCount =
        existingImageUrls.length + _detailImageFiles.length + 1;

    return GridView.builder(
      shrinkWrap: true,
      itemCount: totalItemCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemBuilder: (BuildContext context, int index) {
        // Check if index is within the range of existing image URLs
        if (index < existingImageUrls.length) {
          // Display existing image
          return Stack(
            children: [
              Image.network(
                existingImageUrls[index],
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    shape: BoxShape.rectangle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.close, size: 16, color: Colors.white),
                    onPressed: () {
                      // Confirm deletion with the user before actually deleting the image
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Delete Image'),
                          content: const Text(
                              'Are you sure you want to delete this image?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.of(context)
                                    .pop(); // Close the dialog first
                                await _deleteImageFromFirebase(
                                    existingImageUrls[index]);
                                setState(() {
                                  existingImageUrls.removeAt(index);
                                });
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ),
              ),
            ],
          );
        } else if (index - existingImageUrls.length <
            _detailImageFiles.length) {
          // Display new selected image
          int fileIndex = index - existingImageUrls.length;
          return Stack(
            children: [
              Image.file(
                _detailImageFiles[fileIndex],
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    shape: BoxShape.rectangle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.close, size: 16, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _detailImageFiles.removeAt(fileIndex);
                      });
                    },
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ),
              ),
            ],
          );
        } else {
          // Display button to add a new image
          return GestureDetector(
            onTap: () {
              if (_detailImageFiles.length + existingImageUrls.length < 5) {
                _pickDetailImages();
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

  Widget _buildQuantityCounter(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.white, // Warna latar belakang container
        borderRadius: BorderRadius.circular(30.0), // Radius border melengkung
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Warna bayangan
            spreadRadius: 0,
            blurRadius: 10, // Seberapa kabur bayangannya
            offset: Offset(0, 3), // Posisi bayangan
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildIconButton(Icons.remove, () {
            int currentQuantity = int.tryParse(_quantityController.text) ?? 0;
            if (currentQuantity > 0) {
              setState(() {
                _quantityController.text = (currentQuantity - 1).toString();
              });
            }
          }),
          SizedBox(width: 20),
          // This text now uses the _quantityController
          Text(
            _quantityController.text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 20),
          _buildIconButton(Icons.add, () {
            int currentQuantity = int.tryParse(_quantityController.text) ?? 0;
            setState(() {
              _quantityController.text = (currentQuantity + 1).toString();
            });
          }),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
      color: Colors.black, // Warna ikon
      splashRadius: 20, // Efek cipratan air ketika diklik
      iconSize: 24, // Ukuran ikon
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
                    SizedBox(height: 20),
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
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Category'),
                      value: _categoryController.text.isNotEmpty
                          ? _categoryController.text
                          : null,
                      items: [
                        'Gudang Umum',
                        'Gudang Dingin',
                        'Gudang Khusus',
                        'Gudang Ecommerce'
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        // If you are using a state management solution, update the state accordingly
                        // For StatefulWidget, you might call setState or another function depending on your state management
                        setState(() {
                          _categoryController.text = newValue ??
                              ''; // Set the new value to the controller
                        });
                      },
                      validator: (value) {
                        // Validation to ensure a category is selected
                        if (value == null || value.isEmpty) {
                          return 'Category is required';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _itemDescriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Item Description'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a Item Description.';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _itemLargeController,
                      decoration:
                          const InputDecoration(labelText: 'Item Large'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a Item Large.';
                        }
                        return null;
                      },
                    ),
                    Text('Quantity'),
                    _buildQuantityCounter(context),
                    TextFormField(
                      controller: _serialNumberController,
                      decoration:
                          const InputDecoration(labelText: 'Serial Number'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a Serial Number.';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(labelText: 'Location'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a Location.';
                        }
                        return null;
                      },
                    ),
                    CustomDropdownFormFieldEdit(
                      hintText: 'Choose Warehouse Status',
                      options: ['available', 'not available'],
                      controller: _warehouseStatusController,
                      validator: (value) {
                        // Validation to ensure a category is selected
                        if (value == null || value.isEmpty) {
                          return 'Warehouse Status is required';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _featuresController,
                      decoration: const InputDecoration(labelText: 'Feature'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a Feature.';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _additionalNotesController,
                      decoration:
                          const InputDecoration(labelText: 'Additional Notes'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a Additional Notes.';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _pricePerDayController,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Price per Day',
                        prefixText: 'Rp. ',
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a Price per Day.';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: TextEditingController(),
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: 'Price per Week',
                        prefixText: 'Rp. ',
                      ),
                    ),
                    TextFormField(
                      controller: _pricePerMonthController,
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: 'Price per Month',
                        prefixText: 'Rp. ',
                      ),
                    ),
                    TextFormField(
                      controller: _pricePerYearController,
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: 'Price per Year',
                        prefixText: 'Rp. ',
                      ),
                    ),
                    SizedBox(height: 20),
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
