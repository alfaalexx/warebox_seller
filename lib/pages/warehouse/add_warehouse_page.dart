import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:warebox_seller/pages/warehouse/warehouse_page.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;

class AddWarehousePage extends StatefulWidget {
  const AddWarehousePage({Key? key}) : super(key: key);

  @override
  _AddWarehousePageState createState() => _AddWarehousePageState();
}

class _AddWarehousePageState extends State<AddWarehousePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Deklarasikan semua variabel untuk menyimpan data gudang
  String itemName = '';
  String category = '';
  String itemDescription = '';
  String uid = '';
  String itemLarge = '';
  int quantity = 0;
  String serialNumber = '';
  String location = '';
  String warehouseStatus = 'available';
  String features = '';
  String additionalNotes = '';
  double pricePerDay = 0.0;
  double pricePerWeek = 0.0;
  double pricePerMonth = 0.0;
  double pricePerYear = 0.0;
  File? _imageFile;
  List<File> _detailImageFiles = [];
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;

  // Controller untuk setiap field
  final itemNameController = TextEditingController();
  final categoryController = TextEditingController();
  final itemDescriptionController = TextEditingController();
  final itemLargeController = TextEditingController();
  final quantityController = TextEditingController();
  final serialNumberController = TextEditingController();
  final locationController = TextEditingController();
  final featuresController = TextEditingController();
  final additionalNotesController = TextEditingController();
  final pricePerDayController = TextEditingController();

  String formatRupiah(double value) {
    final formatter = NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0);
    return formatter.format(value);
  }

  @override
  void initState() {
    super.initState();
    _getUserUID();
  }

  Future<void> _getUserUID() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        uid = user.uid;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImageSource? source = await _getImageSource();
    if (source != null) {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    }
  }

  Future<void> _pickDetailImage() async {
    final ImageSource? source = await _getImageSource();
    if (source != null) {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _detailImageFiles.add(File(pickedFile.path));
        });
      }
    }
  }

  Future<ImageSource?> _getImageSource() async {
    return await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choose the image source'),
        actions: <Widget>[
          TextButton(
            child: Text('Camera'),
            onPressed: () => Navigator.pop(context, ImageSource.camera),
          ),
          TextButton(
            child: Text('Gallery'),
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      ),
    );
  }

  Future<String?> uploadImage(File imageFile) async {
    try {
      final ref = FirebaseStorage.instance
          .ref('warehouse_images/$uid/${Path.basename(imageFile.path)}');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<List<String?>> uploadDetailImages() async {
    List<String?> uploadedUrls = [];

    for (var imageFile in _detailImageFiles) {
      try {
        final ref = FirebaseStorage.instance.ref(
            'warehouse_detail_images/$uid/${Path.basename(imageFile.path)}');
        await ref.putFile(imageFile);
        final downloadUrl = await ref.getDownloadURL();
        uploadedUrls.add(downloadUrl);
      } catch (e) {
        print(e);
      }
    }

    return uploadedUrls;
  }

  Future<void> saveWarehouseData() async {
    setState(() {
      _isSaving = true; // Set loading to true
    });

    String? warehouseImageUrl;

    double pricePerWeek = pricePerDay * 7;
    double pricePerMonth = pricePerDay *
        30; // Anda bisa mempertimbangkan menggunakan 30.44 sebagai rata-rata hari dalam sebulan.
    double pricePerYear = pricePerDay * 365;

    if (_imageFile != null) {
      warehouseImageUrl = await uploadImage(_imageFile!);
      if (warehouseImageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image!')),
        );
        return;
      }
    }

    List<String?> detailImageUrls = await uploadDetailImages();
    if (detailImageUrls.contains(null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading detail images!')),
      );
      return;
    }

    Map<String, dynamic> warehouseData = {
      'itemName': itemName,
      'category': category,
      'itemDescription': itemDescription,
      'uid': uid,
      'itemLarge': itemLarge,
      'quantity': quantity,
      'serialNumber': serialNumber,
      'location': location,
      'warehouseStatus': warehouseStatus,
      'features': features,
      'additionalNotes': additionalNotes,
      'pricePerDay': pricePerDay,
      'pricePerWeek': pricePerWeek,
      'pricePerMonth': pricePerMonth,
      'pricePerYear': pricePerYear,
      'warehouseImageUrl': warehouseImageUrl,
      'detailImageUrls': detailImageUrls.whereType<String>().toList(),
    };

    try {
      await _firestore.collection('warehouses').add(warehouseData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Warehouse added successfully!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding warehouse: $e')),
      );
    } finally {
      setState(() {
        _isSaving = false; // Set loading to false regardless of the outcome
      });
    }
  }

  Widget _buildDetailImagePicker() {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: _detailImageFiles.length + 1, // Add one for the add button
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemBuilder: (BuildContext context, int index) {
        if (index < _detailImageFiles.length) {
          return Image.file(
            _detailImageFiles[index],
            fit: BoxFit.cover,
          );
        } else {
          return GestureDetector(
            onTap: () {
              if (_detailImageFiles.length < 5) {
                _pickDetailImage();
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
        title: Text(
          'New Warehouse',
          textAlign: TextAlign.start,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(children: [
        SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(children: [
            Text('Warehouse Image'),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _imageFile != null
                    ? Image.file(_imageFile!)
                    : Icon(Icons.add_a_photo,
                        size: 50, color: Colors.grey[400]),
              ),
            ),
            Text('Detail Warehouse Image'),
            _buildDetailImagePicker(),
            TextFormField(
              controller: itemNameController,
              decoration: InputDecoration(labelText: 'Item Name'),
              onChanged: (value) => setState(() => itemName = value),
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Category'),
              value: category.isNotEmpty ? category : null,
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
                setState(() {
                  category = newValue!;
                });
              },
            ),
            TextFormField(
              controller: itemDescriptionController,
              decoration: InputDecoration(labelText: 'Item Description'),
              onChanged: (value) => setState(() => itemDescription = value),
            ),

            // New fields
            TextFormField(
              controller: itemLargeController,
              decoration: InputDecoration(labelText: 'Item Large'),
              onChanged: (value) => setState(() => itemLarge = value),
            ),
            TextFormField(
              controller: quantityController,
              decoration: InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
              onChanged: (value) =>
                  setState(() => quantity = int.tryParse(value) ?? 0),
            ),
            TextFormField(
              controller: serialNumberController,
              decoration: InputDecoration(labelText: 'Serial Number'),
              onChanged: (value) => setState(() => serialNumber = value),
            ),
            TextFormField(
              controller: locationController,
              decoration: InputDecoration(labelText: 'Location'),
              onChanged: (value) => setState(() => location = value),
            ),
            DropdownButtonFormField(
              decoration: InputDecoration(labelText: 'Warehouse Status'),
              value: warehouseStatus,
              items: ['available', 'not available'].map((value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) =>
                  setState(() => warehouseStatus = value.toString()),
            ),
            TextFormField(
              controller: featuresController,
              decoration: InputDecoration(labelText: 'Features'),
              onChanged: (value) => setState(() => features = value),
            ),
            TextFormField(
              controller: additionalNotesController,
              decoration: InputDecoration(labelText: 'Additional Notes'),
              onChanged: (value) => setState(() => additionalNotes = value),
            ),
            TextFormField(
              controller: pricePerDayController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Price per Day',
                prefixText: 'Rp. ',
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                setState(() {
                  pricePerDay =
                      double.tryParse(value.replaceAll(',', '')) ?? 0.0;
                });
              },
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: 'Price per Week',
              ),
              enabled: false,
              controller:
                  TextEditingController(text: formatRupiah(pricePerDay * 7)),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: 'Price per Month',
              ),
              enabled: false,
              controller:
                  TextEditingController(text: formatRupiah(pricePerDay * 30)),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: 'Price per Year',
              ),
              enabled: false,
              controller:
                  TextEditingController(text: formatRupiah(pricePerDay * 365)),
            ),

            ElevatedButton(
              onPressed: saveWarehouseData,
              child: Text('Add Warehouse'),
            ),
          ]),
        ),
        if (_isSaving) // Sama dengan menggunakan Visibility widget
          Center(
            child: Container(
              color: Colors.black45, // Semitransparent background
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ]),
    );
  }

  @override
  void dispose() {
    itemNameController.dispose();
    categoryController.dispose();
    itemDescriptionController.dispose();
    itemLargeController.dispose();
    quantityController.dispose();
    serialNumberController.dispose();
    locationController.dispose();
    featuresController.dispose();
    additionalNotesController.dispose();
    pricePerDayController.dispose();
    super.dispose();
  }
}
