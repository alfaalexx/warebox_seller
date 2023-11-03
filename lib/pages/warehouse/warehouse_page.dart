import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:warebox_seller/pages/category/category_screen.dart';
import 'package:warebox_seller/pages/profile/edit_profile_page.dart';
import 'package:warebox_seller/pages/warehouse/add_warehouse_page.dart';
import 'package:warebox_seller/pages/warehouse/detail_warehouse_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Warehouse {
  final String id;
  final String itemName;
  final String category;

  Warehouse({required this.id, required this.itemName, required this.category});

  factory Warehouse.fromFirestore(DocumentSnapshot doc) {
    // Ambil data, dan jika doc.data() memberikan null (dokumen tidak ditemukan),
    // gunakan map kosong sebagai gantinya.
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

    // Berikan nilai default untuk 'itemName' dan 'category' jika null.
    String itemName = data['itemName'] as String? ?? 'No Name';
    String category = data['category'] as String? ?? 'No Category';

    return Warehouse(
      id: doc.id,
      itemName: itemName,
      category: category,
    );
  }
}

class MyWarehousePage extends StatefulWidget {
  const MyWarehousePage({Key? key}) : super(key: key);

  @override
  _MyWarehousePageState createState() => _MyWarehousePageState();
}

class _MyWarehousePageState extends State<MyWarehousePage> {
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle unauthenticated user if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text('You are not logged in.'),
        ),
      );
    }

    final uid = user!.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'My Warehouse',
          style: GoogleFonts.plusJakartaSans(
              fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfilePage(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(25.0),
              child: const CircleAvatar(
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
              decoration: const BoxDecoration(
                color: Color(0xFF2E9496),
              ),
              child: const Text(
                'Menu',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Tambah Kategori'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CategoriesScreen(),
                  ),
                );
              },
            ),
            // Add more drawer items if needed
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('warehouses')
              .where('uid', isEqualTo: uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No warehouses found.'));
            } else {
              // Improved null check with list spread operator
              return Column(
                children: [
                  ...snapshot.data!.docs.map((warehouse) {
                    final Warehouse currentWarehouse =
                        Warehouse.fromFirestore(warehouse);
                    return Card(
                      child: ListTile(
                        title: Text(currentWarehouse.itemName),
                        subtitle: Text(currentWarehouse.category),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailWarehousePage(
                                  warehouse: currentWarehouse),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                ],
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddWarehousePage()),
          );
        },
        tooltip: 'Add Warehouse',
        child: const Icon(Icons.add),
      ),
    );
  }
}
