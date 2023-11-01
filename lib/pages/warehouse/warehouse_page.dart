import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:warebox_seller/pages/category/add_category_screen.dart';
import 'package:warebox_seller/pages/category/category_screen.dart';
import 'package:warebox_seller/pages/warehouse/add_warehouse_page.dart';
import 'package:warebox_seller/utils/custom_themes.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../profile/edit_profile_page.dart';

class MyWarehousePage extends StatefulWidget {
  const MyWarehousePage({super.key});

  @override
  State<MyWarehousePage> createState() => _MyWarehousePageState();
}

class _MyWarehousePageState extends State<MyWarehousePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'My Warehouse',
          style: GoogleFonts.plusJakartaSans(
              fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfilePage(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(25.0),
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/images/defaultAvatar.png'),
                radius: 20.0,
              ),
            ),
          ),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF2E9496),
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.category),
              title: Text('Tambah Kategori'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoriesScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance.collection('warehouses').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Tampilkan indikator loading saat data dimuat
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              // Tampilkan pesan kesalahan jika ada kesalahan
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              // Tampilkan pesan jika tidak ada data
              return Center(
                child: Text('Data not available'),
              );
            }

            final warehouses = snapshot.data!.docs;

            return Column(
              children: warehouses.map((warehouse) {
                final warehouseData = warehouse.data() as Map<String, dynamic>;

                // Buat widget kartu untuk setiap gudang
                return Card(
                  child: ListTile(
                    title: Text(warehouseData['itemName'] ?? ''),
                    subtitle: Text(warehouseData['category'] ?? ''),
                    // Tambahkan data lain sesuai kebutuhan
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
      // FloatingActionButton untuk menambahkan warehouse baru
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddWarehousePage()),
          );
        },
        tooltip: 'Tambah Warehouse',
        child: const Icon(Icons.add),
      ),
    );
  }
}
