import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:warebox_seller/pages/warehouse/warehouse_page.dart';

class AddWarehousePage extends StatefulWidget {
  const AddWarehousePage({Key? key}) : super(key: key);

  @override
  _AddWarehousePageState createState() => _AddWarehousePageState();
}

class _AddWarehousePageState extends State<AddWarehousePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Deklarasikan variabel untuk menyimpan data gudang
  String itemName = '';
  String category = '';
  String itemDescription = '';
  String uid = ''; // Variabel untuk UID pengguna

  // Controller untuk field-field yang memerlukan input
  final itemNameController = TextEditingController();
  final categoryController = TextEditingController();
  final itemDescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Dapatkan UID pengguna saat halaman diinisialisasi
    _getUserUID();
  }

  // Fungsi untuk mendapatkan UID pengguna
  Future<void> _getUserUID() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        uid = user.uid;
      });
    }
  }

  // Fungsi untuk menyimpan data gudang ke Firebase Firestore
  Future<void> saveWarehouseData() async {
    // Buat objek Map dengan semua data gudang
    Map<String, dynamic> warehouseData = {
      'itemName': itemName,
      'category': category,
      'itemDescription': itemDescription,
      'uid': uid, // Simpan UID pengguna dalam dokumen gudang
      // Dan seterusnya untuk semua field lainnya
    };

    // Simpan data ke Firebase Firestore
    try {
      await _firestore.collection('warehouses').add(warehouseData);
      // Data berhasil disimpan
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Warehouse added successfully!'),
        ),
      );

      // Navigasi kembali ke halaman "My Warehouse" setelah berhasil menambahkan gudang
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyWarehousePage()),
      );
    } catch (e) {
      // Terjadi kesalahan
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error adding warehouse: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Warehouse'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Field untuk Item Name
            TextFormField(
              controller: itemNameController,
              decoration: InputDecoration(labelText: 'Item Name'),
              onChanged: (value) {
                setState(() {
                  itemName = value;
                });
              },
            ),
            // Field untuk Category
            TextFormField(
              controller: categoryController,
              decoration: InputDecoration(labelText: 'Category'),
              onChanged: (value) {
                setState(() {
                  category = value;
                });
              },
            ),
            // Field untuk Item Description
            TextFormField(
              controller: itemDescriptionController,
              decoration: InputDecoration(labelText: 'Item Description'),
              onChanged: (value) {
                setState(() {
                  itemDescription = value;
                });
              },
            ),
            // Tombol untuk menyimpan data
            ElevatedButton(
              onPressed: () {
                // Panggil fungsi untuk menyimpan data gudang ke Firebase Firestore
                saveWarehouseData();
              },
              child: Text('Add Warehouse'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose controller saat halaman dihapus
    itemNameController.dispose();
    categoryController.dispose();
    itemDescriptionController.dispose();
    super.dispose();
  }
}
