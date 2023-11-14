import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;
import 'package:warebox_seller/utils/custom_themes.dart';

import '../../widget/custom_textfield.dart';
import '../../widget/custom_dropdown.dart';
import '../../widget/custom_textfieldmax.dart';
import '../../widget/custom_numberfield.dart';
import '../../widget/custom_textfieldPrice.dart';

class AddWarehousePage extends StatefulWidget {
  const AddWarehousePage({Key? key}) : super(key: key);

  @override
  _AddWarehousePageState createState() => _AddWarehousePageState();
}

class _AddWarehousePageState extends State<AddWarehousePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  // Deklarasikan semua variabel untuk menyimpan data gudang
  String itemName = '';
  String category = '';
  String itemDescription = '';
  String uid = '';
  int itemLarge = 0;
  int quantity = 0;
  String serialNumber = '';
  String location = '';
  String warehouseStatus = 'available';
  String additionalNotes = '';
  double pricePerDay = 0.0;
  double pricePerWeek = 0.0;
  double pricePerMonth = 0.0;
  double pricePerYear = 0.0;
  File? _imageFile;
  List<String> features = [];
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
    quantityController.text = quantity.toString();
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
        final ref = FirebaseStorage.instance
            .ref('warehouse_images/$uid/${Path.basename(imageFile.path)}');
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
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all the required fields')),
      );
      return;
    }

    if (_imageFile == null) {
      // Pastikan _imageFile adalah variabel untuk file gambar yang dipilih.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You must upload a warehouse image!')),
      );
      return;
    }

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
      'itemName_lowercase': itemName.toLowerCase(),
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
          return Stack(
            children: [
              Image.file(
                _detailImageFiles[index],
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
                        _detailImageFiles.removeAt(index);
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
                color: Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.add,
                color: Colors.grey,
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
          itemCount: features.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(features[index]),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    features.removeAt(index);
                  });
                },
              ),
            );
          },
        ),
        TextButton(
          child: Text('Add Feature'),
          onPressed: () async {
            if (features.length >= 4) {
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
                features.add(newFeature);
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Agar ukuran Row menyesuaikan isi
        children: [
          _buildIconButton(Icons.remove, () {
            if (quantity > 0) {
              setState(() {
                quantity--;
                quantityController.text = quantity.toString();
              });
            }
          }),
          SizedBox(width: 20), // Jarak antara tombol dan teks
          Text(
            quantity.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 20), // Jarak antara teks dan tombol
          _buildIconButton(Icons.add, () {
            setState(() {
              quantity++;
              quantityController.text = quantity.toString();
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
          TextButton(
            onPressed: () {
              // Cek apakah form valid.
              bool isFormValid = _formKey.currentState!.validate();
              // Cek apakah gambar sudah dipilih.
              bool isImageSelected = _imageFile !=
                  null; // Pastikan variabel _imageFile merepresentasikan file gambar yang dipilih.

              if (isFormValid && isImageSelected) {
                saveWarehouseData(); // Simpan data jika form valid dan gambar telah dipilih.
              } else {
                // Jika gambar belum dipilih, tampilkan SnackBar.
                if (!isImageSelected) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('You must upload a warehouse image!')),
                  );
                }
                // Anda bisa juga menambahkan kondisi lain jika form tidak valid.
              }
            },
            child: Text('Save', style: pjsMedium16Tosca),
          )
        ],
      ),
      body: Stack(children: [
        SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode
                .onUserInteraction, // Validasi otomatis ketika pengguna berinteraksi
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                'Warehouse Name',
                style: pjsMedium16,
              ),
              SizedBox(height: 5),
              CustomTextField(
                controller: itemNameController,
                hintText: 'Warehouse Name',
                onChanged: (value) => setState(() => itemName = value),
                validator: (value) {
                  // Tambahkan validator
                  if (value == null || value.isEmpty) {
                    return 'Warehouse Name is required';
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
              CustomDropdown<String>(
                hintText: 'Choose Category Warehouse',
                itemBuilder: (item) => item,
                items: [
                  'Gudang Umum',
                  'Gudang Dingin',
                  'Gudang Khusus',
                  'Gudang Ecommerce'
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    category = newValue!;
                  });
                },
                validator: (value) {
                  // Tambahkan validator
                  if (value == null || value.isEmpty) {
                    return 'Category is required';
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
                controller: itemDescriptionController,
                maxLines: 5,
                onChanged: (value) => setState(() => itemDescription = value),
                validator: (value) {
                  // Tambahkan validator
                  if (value == null || value.isEmpty) {
                    return 'Warehouse Description is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            controller: itemLargeController,
                            prefixIcon:
                                Image.asset('assets/images/ILLUSTRATION.png'),
                            suffixIcon: Icon(Icons.arrow_right_rounded),
                            hintText: '10 m\u00B2',
                            onChanged: (value) => setState(() {
                              // Parse the input to an integer before saving it in the state.
                              itemLarge = int.tryParse(value) ??
                                  0; // Use tryParse to avoid exceptions
                            }),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Warehouse Large is required';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Please enter a valid integer'; // Ensure the input is an integer
                              }
                              return null;
                            },
                          ),
                        ]),
                  ),
                  Expanded(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Quantity ',
                        style: pjsMedium16,
                      ),
                      SizedBox(height: 5),
                      _buildQuantityCounter(context),
                    ],
                  ))
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        CustomTextField(
                          controller: serialNumberController,
                          hintText: 'Serial Number',
                          onChanged: (value) =>
                              setState(() => serialNumber = value),
                          validator: (value) {
                            // Tambahkan validator
                            if (value == null || value.isEmpty) {
                              return 'Serial Number is required';
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
                      CustomDropdown(
                        hintText: 'Choose Status',
                        itemBuilder: (item) => item,
                        items: ['available', 'not available'],
                        onChanged: (value) =>
                            setState(() => warehouseStatus = value.toString()),
                        validator: (value) {
                          // Tambahkan validator
                          if (value == null || value.isEmpty) {
                            return 'Warehouse Status is required';
                          }
                          return null;
                        },
                      ),
                    ],
                  )),
                ],
              ),
              SizedBox(height: 10),
              Text(
                'Location',
                style: pjsMedium16,
              ),
              SizedBox(height: 5),
              CustomTextField(
                controller: locationController,
                hintText: 'Location',
                prefixIcon: ImageIcon(
                    AssetImage("assets/images/icon _map marker_.png")),
                onChanged: (value) => setState(() => location = value),
                validator: (value) {
                  // Tambahkan validator
                  if (value == null || value.isEmpty) {
                    return 'Location is required';
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
                controller: additionalNotesController,
                maxLines: 5,
                onChanged: (value) => setState(() => additionalNotes = value),
                validator: (value) {
                  // Tambahkan validator
                  if (value == null || value.isEmpty) {
                    return 'Additional Notes is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
              CustomTextFormFieldPrice(
                controller: pricePerDayController,
                labelText: 'Price per Day',
                labelStyle: pjsMedium16,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  setState(() {
                    pricePerDay =
                        double.tryParse(value.replaceAll(',', '')) ?? 0.0;
                  });
                },
                validator: (value) {
                  // Tambahkan validator
                  if (value == null || value.isEmpty) {
                    return 'Price per Day is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Price per Week',
                  labelStyle: pjsMedium16,
                  filled: true,
                  fillColor: Color(0xFFF2F2F2),
                  disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0x00000000), width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                enabled: false,
                controller:
                    TextEditingController(text: formatRupiah(pricePerDay * 7)),
              ),
              SizedBox(height: 15),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Price per Month',
                  labelStyle: pjsMedium16,
                  filled: true,
                  fillColor: Color(0xFFF2F2F2),
                  disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0x00000000), width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                enabled: false,
                controller:
                    TextEditingController(text: formatRupiah(pricePerDay * 30)),
              ),
              SizedBox(height: 15),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Price per Year',
                  labelStyle: pjsMedium16,
                  filled: true,
                  fillColor: Color(0xFFF2F2F2),
                  disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0x00000000), width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                enabled: false,
                controller: TextEditingController(
                    text: formatRupiah(pricePerDay * 365)),
              ),
              SizedBox(height: 15),
              Text('Warehouse Image', style: pjsMedium16),
              SizedBox(height: 5),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xFFF2F2F2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _imageFile != null
                        ? Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Image.file(_imageFile!,
                                  fit: BoxFit.cover, width: double.infinity),
                              // Overlay 'X' button to allow the user to remove the image
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.grey[
                                      600], // Background color for the close icon
                                  shape: BoxShape.rectangle,
                                ),
                                alignment: Alignment.center,
                                child: IconButton(
                                  icon: Icon(Icons.close, color: Colors.white),
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    setState(() {
                                      // This will remove the image from the UI
                                      _imageFile = null;
                                    });
                                    // Optionally, you can also add logic here to remove the image from where it is stored.
                                    // If you're handling images that are saved on the device or uploaded, make sure to delete them from there as well.
                                  },
                                ),
                              ),
                            ],
                          )
                        : Icon(Icons.add_a_photo,
                            size: 50, color: Colors.grey[400]),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Text('Detail Warehouse Image', style: pjsMedium16),
              SizedBox(height: 5),
              _buildDetailImagePicker(),
              SizedBox(height: 10),
            ]),
          ),
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
