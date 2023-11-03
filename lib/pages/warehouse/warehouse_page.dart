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
  TextEditingController searchController = TextEditingController();
  String searchKey = '';

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search Warehouse',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchKey = value.trim();
                });
              },
            ),
          ),
          Expanded(
            child: buildWarehouseList(uid, searchKey),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Color(0xFF2E9496),
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

  Widget buildWarehouseList(String uid, String searchKey) {
    final query = searchKey.isNotEmpty
        ? FirebaseFirestore.instance
            .collection('warehouses')
            .where('uid', isEqualTo: uid)
            .where('itemName_lowercase',
                isGreaterThanOrEqualTo: searchKey.toLowerCase())
            .where('itemName_lowercase',
                isLessThanOrEqualTo: searchKey.toLowerCase() + '\uf8ff')
            .snapshots()
        : FirebaseFirestore.instance
            .collection('warehouses')
            .where('uid', isEqualTo: uid)
            .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: query,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No warehouses found.'));
        } else {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: snapshot.data!.docs.map((warehouse) {
                final Warehouse currentWarehouse =
                    Warehouse.fromFirestore(warehouse);
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 5.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xFFE5E5E5),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
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
                  ),
                );
              }).toList(),
            ),
          );
        }
      },
    );
  }
}
