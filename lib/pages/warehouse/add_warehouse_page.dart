import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:warebox_seller/pages/warehouse/warehouse_page.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

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

  Future<void> saveWarehouseData() async {
    double pricePerWeek = pricePerDay * 7;
    double pricePerMonth = pricePerDay *
        30; // Anda bisa mempertimbangkan menggunakan 30.44 sebagai rata-rata hari dalam sebulan.
    double pricePerYear = pricePerDay * 365;

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
    };

    try {
      await _firestore.collection('warehouses').add(warehouseData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Warehouse added successfully!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyWarehousePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding warehouse: $e')),
      );
    }
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(children: [
          // Existing fields
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
                pricePerDay = double.tryParse(value.replaceAll(',', '')) ?? 0.0;
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
