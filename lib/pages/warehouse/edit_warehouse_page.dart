import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:warebox_seller/pages/warehouse/warehouse_page.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;

class EditWarehousePage extends StatefulWidget {
  final Warehouse warehouse;

  const EditWarehousePage({Key? key, required this.warehouse})
      : super(key: key);

  @override
  State<EditWarehousePage> createState() => _EditWarehousePageState();
}

class _EditWarehousePageState extends State<EditWarehousePage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String uid = '';

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
  late TextEditingController _warehouseImageUrlController;
  late List<TextEditingController> _detailImageUrlsControllers = [];

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
    _warehouseImageUrlController =
        TextEditingController(text: widget.warehouse.warehouseImageUrl);

    // Initialize controllers for detail images assuming they are List<String>
    (widget.warehouse.detailImageUrls ?? []).forEach((url) {
      _detailImageUrlsControllers.add(TextEditingController(text: url));
    });

    _calculateAndSetPeriodPrices();
    _pricePerDayController.addListener(_calculateAndSetPeriodPrices);
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
    _warehouseImageUrlController.dispose();
    _detailImageUrlsControllers.forEach((controller) => controller.dispose());
    _pricePerDayController.removeListener(_calculateAndSetPeriodPrices);
    super.dispose();
  }

  Future<void> _saveWarehouse() async {
    if (_formKey.currentState!.validate()) {
      // UID check here
      String? currentUID = FirebaseAuth.instance.currentUser?.uid;
      if (widget.warehouse.uid != currentUID) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("You are not authorized to update this warehouse."),
          ),
        );
        return;
      }

      Map<String, dynamic> updatedData = {
        'itemName': _nameController.text,
        'category': _categoryController.text,
        'itemDescription': _itemDescriptionController.text,
        'uid': widget.warehouse.uid,
        'itemLarge': int.tryParse(_itemLargeController.text),
        'quantity': int.tryParse(_quantityController.text), //
        'serialNumber': _serialNumberController.text,
        'location': _locationController.text,
        'warehouseStatus': _warehouseStatusController.text,
        'features': _featuresController.text,
        'additionalNotes': _additionalNotesController.text,
        'pricePerDay': double.tryParse(_pricePerDayController.text),
        'pricePerWeek': double.tryParse(_pricePerWeekController.text),
        'pricePerMonth': double.tryParse(_pricePerMonthController.text),
        'pricePerYear': double.tryParse(_pricePerYearController.text),
        'warehouseImageUrl': _warehouseImageUrlController.text,
        'detailImageUrls':
            _detailImageUrlsControllers.map((c) => c.text).toList(),
      };

      // Update the Firestore document
      FirebaseFirestore.instance
          .collection('warehouses')
          .doc(widget.warehouse.id)
          .update(updatedData)
          .then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Warehouse updated successfully"),
          ),
        );
        Navigator.pop(context, true);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update warehouse: $error"),
          ),
        );
      });
    }
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
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveWarehouse,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name.';
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
                  _categoryController.text =
                      newValue ?? ''; // Set the new value to the controller
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
              decoration: const InputDecoration(labelText: 'Item Description'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a Item Description.';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _itemLargeController,
              decoration: const InputDecoration(labelText: 'Item Large'),
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
              decoration: const InputDecoration(labelText: 'Serial Number'),
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
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Warehouse Status'),
              value: _warehouseStatusController.text.isNotEmpty
                  ? _warehouseStatusController.text
                  : null,
              items: ['available', 'not available'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                // If you are using a state management solution, update the state accordingly
                // For StatefulWidget, you might call setState or another function depending on your state management
                setState(() {
                  _warehouseStatusController.text =
                      newValue ?? ''; // Set the new value to the controller
                });
              },
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
              decoration: const InputDecoration(labelText: 'Additional Notes'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a Additional Notes.';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _pricePerDayController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
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
              controller: _pricePerWeekController,
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
          ],
        ),
      ),
    );
  }
}
