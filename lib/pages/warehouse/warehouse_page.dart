import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:warebox_seller/pages/warehouse/add_warehouse_page.dart';
import 'package:warebox_seller/utils/custom_themes.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

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
        automaticallyImplyLeading: true,
        leading: Align(
          alignment: const AlignmentDirectional(0.00, 0.00),
          child: IconButton(
            icon: const Icon(
              Icons.menu,
              color: Colors.black,
              size: 24,
            ),
            onPressed: () {},
          ),
        ),
        title: Align(
          alignment: const AlignmentDirectional(0.00, 0.00),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 50, 0),
            child: Text(
              'My Warehouse',
              textAlign: TextAlign.start,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
            ),
          ),
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
