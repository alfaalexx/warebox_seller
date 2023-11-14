import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:warebox_seller/pages/warehouse/warehouse_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:warebox_seller/utils/custom_themes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../widget/custom_dropdownEdit.dart';
import '../../widget/custom_textfieldEdit.dart';
import '../../widget/custom_textfieldmax.dart';
import '../../widget/custom_numberfield.dart';
import '../../widget/custom_textfieldPriceEdit.dart';

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
  List<String> _currentFeatures = [];

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
        TextEditingController(text: widget.warehouse.features.join(', '));
    _currentFeatures = _featuresController.text.split(', ');
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
        'itemName_lowercase': _nameController.text.toLowerCase(),
        'category': _categoryController.text,
        'itemDescription': _itemDescriptionController.text,
        'itemLarge': int.tryParse(_itemLargeController.text),
        'quantity': int.tryParse(_quantityController.text),
        'serialNumber': _serialNumberController.text,
        'location': _locationController.text,
        'warehouseStatus': _warehouseStatusController.text,
        'features': _currentFeatures,
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
              CachedNetworkImage(
                imageUrl: existingImageUrls[index],
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Icon(Icons.error),
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

  Widget _buildFeaturesPicker() {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics:
              NeverScrollableScrollPhysics(), // untuk mencegah scrolling pada ListView
          itemCount: _currentFeatures.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(_currentFeatures[index]),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    _currentFeatures.removeAt(index);
                  });
                },
              ),
            );
          },
        ),
        TextButton(
          child: Text('Add Feature'),
          onPressed: () async {
            if (_currentFeatures.length >= 4) {
              // Tampilkan pesan bahwa tidak bisa menambah lebih dari 4 fitur
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Maximum of 4 features can be added'),
                ),
              );
              return;
            }

            final String? newFeature = await showDialog<String>(
              context: context,
              builder: (BuildContext context) {
                String tempFeature = '';
                return AlertDialog(
                  title: Text('Add New Feature'),
                  content: TextField(
                    onChanged: (value) => tempFeature = value,
                    decoration: InputDecoration(hintText: 'Enter a feature'),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                      child: Text('Add'),
                      onPressed: () => Navigator.of(context).pop(tempFeature),
                    ),
                  ],
                );
              },
            );

            if (newFeature != null && newFeature.isNotEmpty) {
              setState(() {
                _currentFeatures.add(newFeature);
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildQuantityCounter(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0),
      height: 55.0, // Tinggi container
      decoration: BoxDecoration(
        color: Color(0xFFF2F2F2), // Warna latar belakang container
        borderRadius: BorderRadius.circular(12), // Radius border melengkung
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
        title: Text(
          'Edit Warehouse',
          textAlign: TextAlign.start,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black),
        actions: <Widget>[
          TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  setState(() => _isLoading = true);
                  try {
                    await _updateWarehouse();
                    // Jika berhasil, mungkin navigasi keluar atau tampilkan pesan sukses.
                  } catch (error) {
                    // Handle error, tampilkan pesan error.
                  } finally {
                    setState(() => _isLoading = false);
                  }
                }
              },
              child: Text('Save', style: pjsMedium16Tosca))
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 20),
                    Text(
                      'Warehouse Name',
                      style: pjsMedium16,
                    ),
                    SizedBox(height: 5),
                    CustomTextFieldEdit(
                      controller: _nameController,
                      hintText: 'Warehouse Name',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Warehouse name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Warehouse Category',
                      style: pjsMedium16,
                    ),
                    SizedBox(height: 5),
                    CustomDropdownFormFieldEdit(
                      hintText: 'Choose Warehouse Category',
                      options: [
                        'Gudang Umum',
                        'Gudang Dingin',
                        'Gudang Khusus',
                        'Gudang Ecommerce'
                      ],
                      controller: _categoryController,
                      validator: (value) {
                        // Validation to ensure a category is selected
                        if (value == null || value.isEmpty) {
                          return 'Warehouse Category is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Warehouse Description',
                      style: pjsMedium16,
                    ),
                    SizedBox(height: 5),
                    CustomTextFieldMax(
                      controller: _itemDescriptionController,
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a Warehouse Description.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Warehouse Large',
                                style: pjsMedium16,
                              ),
                              SizedBox(height: 5),
                              CustomNumberFormField(
                                controller: _itemLargeController,
                                prefixIcon: Image.asset(
                                    'assets/images/ILLUSTRATION.png'),
                                suffixIcon: Icon(Icons.arrow_right_rounded),
                                hintText: '10 m\u00B2',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a Item Large.';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('Quantity', style: pjsMedium16),
                            SizedBox(height: 5),
                            _buildQuantityCounter(context),
                          ],
                        ))
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Serial Number',
                                style: pjsMedium16,
                              ),
                              SizedBox(height: 5),
                              CustomTextFieldEdit(
                                controller: _serialNumberController,
                                hintText: 'Serial Number',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a Serial Number.';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Warehouse Status',
                                style: pjsMedium16,
                              ),
                              SizedBox(height: 5),
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
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Location',
                      style: pjsMedium16,
                    ),
                    SizedBox(height: 5),
                    CustomTextFieldEdit(
                      controller: _locationController,
                      prefixIcon: ImageIcon(
                          AssetImage("assets/images/icon _map marker_.png")),
                      hintText: 'Location',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a Location.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Warehouse Features',
                      style: pjsMedium16,
                    ),
                    SizedBox(height: 5),
                    _buildFeaturesPicker(),
                    SizedBox(height: 10),
                    Text(
                      'Additional Notes',
                      style: pjsMedium16,
                    ),
                    SizedBox(height: 5),
                    CustomTextFieldMax(
                      controller: _additionalNotesController,
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a Additional Notes.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    CustomTextFieldPriceEdit(
                      controller: _pricePerDayController,
                      labelText: 'Price Per Day',
                      labelStyle: pjsMedium16,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a Price per Day.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: _pricePerWeekController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'Price per Week',
                        prefixText: 'Rp. ',
                        labelStyle: pjsMedium16,
                        filled: true,
                        fillColor: Color(0xFFF2F2F2),
                        disabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0x00000000), width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: _pricePerMonthController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'Price per Month',
                        prefixText: 'Rp. ',
                        labelStyle: pjsMedium16,
                        filled: true,
                        fillColor: Color(0xFFF2F2F2),
                        disabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0x00000000), width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: _pricePerYearController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'Price per Year',
                        prefixText: 'Rp. ',
                        labelStyle: pjsMedium16,
                        filled: true,
                        fillColor: Color(0xFFF2F2F2),
                        disabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0x00000000), width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Warehouse Image',
                      style: pjsMedium16,
                    ),
                    SizedBox(height: 5),
                    if (_imageFile != null)
                      Image.file(_imageFile!)
                    else if (widget.warehouse.warehouseImageUrl != null)
                      CachedNetworkImage(
                        imageUrl: widget.warehouse.warehouseImageUrl!,
                        placeholder: (context, url) =>
                            Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                        fit: BoxFit.cover,
                      )
                    else
                      Container(
                        width: double.infinity, // Set the width as needed
                        height: 200.0, // Set the height as needed
                        decoration: BoxDecoration(
                          color: Colors.grey[
                              200], // Set the background color of the placeholder
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add_photo_alternate, // 'Add image' icon
                                color: Colors
                                    .grey[600], // Set the color of the icon
                                size: 50.0, // Set the size of the icon
                              ),
                            ],
                          ),
                        ),
                      ),
                    Container(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: _pickImage,
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            backgroundColor: Color(0xFF2E9496),
                            foregroundColor: Colors.white),
                        child: Text('Select Image'),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Detail Warehouse Image',
                      style: pjsMedium16,
                    ),
                    SizedBox(height: 5),
                    _buildDetailImagePicker(),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
    );
  }
}
