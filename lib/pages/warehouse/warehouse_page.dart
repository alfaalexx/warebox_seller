import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:warebox_seller/pages/category/category_screen.dart';
import 'package:warebox_seller/pages/profile/edit_profile_page.dart';
import 'package:warebox_seller/pages/warehouse/add_warehouse_page.dart';
import 'package:warebox_seller/pages/warehouse/detail_warehouse_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:warebox_seller/utils/custom_themes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class Warehouse {
  final String id;
  final String itemName;
  final String itemNameLowercase;
  final String category;
  final String itemDescription;
  final String uid;
  final int itemLarge;
  final int quantity;
  final String serialNumber;
  final String location;
  final String warehouseStatus;
  final String features;
  final String additionalNotes;
  final double pricePerDay;
  final double pricePerWeek;
  final double pricePerMonth;
  final double pricePerYear;
  final String? warehouseImageUrl;
  final List<String>? detailImageUrls;

  Warehouse({
    required this.id,
    this.itemName = '',
    this.itemNameLowercase = '',
    this.category = '',
    this.itemDescription = '',
    this.uid = '',
    this.itemLarge = 0,
    this.quantity = 0,
    this.serialNumber = '',
    this.location = '',
    this.warehouseStatus = 'available',
    this.features = '',
    this.additionalNotes = '',
    this.pricePerDay = 0.0,
    this.pricePerWeek = 0.0,
    this.pricePerMonth = 0.0,
    this.pricePerYear = 0.0,
    this.warehouseImageUrl,
    this.detailImageUrls,
  });

  factory Warehouse.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

    // Initialize with default values or the values from the document
    String itemName = data['itemName'] as String? ?? '';
    String itemNameLowercase = itemName.toLowerCase();
    String category = data['category'] as String? ?? '';
    String itemDescription = data['itemDescription'] as String? ?? '';
    String uid = data['uid'] as String? ?? '';
    int itemLarge = data['itemLarge'] as int? ?? 0;
    int quantity = data['quantity'] as int? ?? 0;
    String serialNumber = data['serialNumber'] as String? ?? '';
    String location = data['location'] as String? ?? '';
    String warehouseStatus = data['warehouseStatus'] as String? ?? 'available';
    String features = data['features'] as String? ?? '';
    String additionalNotes = data['additionalNotes'] as String? ?? '';
    double pricePerDay = (data['pricePerDay'] as num?)?.toDouble() ?? 0.0;
    double pricePerWeek = (data['pricePerWeek'] as num?)?.toDouble() ?? 0.0;
    double pricePerMonth = (data['pricePerMonth'] as num?)?.toDouble() ?? 0.0;
    double pricePerYear = (data['pricePerYear'] as num?)?.toDouble() ?? 0.0;
    String? warehouseImageUrl = data['warehouseImageUrl'] as String?;
    List<String>? detailImageUrls = (data['detailImageUrls'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList();

    return Warehouse(
      id: doc.id,
      itemName: itemName,
      itemNameLowercase: itemNameLowercase,
      category: category,
      itemDescription: itemDescription,
      uid: uid,
      itemLarge: itemLarge,
      quantity: quantity,
      serialNumber: serialNumber,
      location: location,
      warehouseStatus: warehouseStatus,
      features: features,
      additionalNotes: additionalNotes,
      pricePerDay: pricePerDay,
      pricePerWeek: pricePerWeek,
      pricePerMonth: pricePerMonth,
      pricePerYear: pricePerYear,
      warehouseImageUrl: warehouseImageUrl,
      detailImageUrls: detailImageUrls,
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

  String formatRupiah(double value) {
    final formatter = NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0);
    return formatter.format(value);
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
                hintText: 'Search Warehouse',
                hintStyle: pjsMedium16Grey,
                filled: true,
                fillColor: Color(0xFFF2F2F2),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0x00000000), width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2E9496)),
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: Icon(Icons.search, color: Color(0xFF2E9496)),
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
                    Warehouse.fromSnapshot(warehouse);
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
                    elevation: 0,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailWarehousePage(
                                warehouseId: currentWarehouse.id),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                topLeft: Radius.circular(12),
                              ),
                              child: currentWarehouse.warehouseImageUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl:
                                          currentWarehouse.warehouseImageUrl!,
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                        width: 100.0,
                                        height: 100.0,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover),
                                        ),
                                      ),
                                      placeholder: (context, url) =>
                                          CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    )
                                  : Container(
                                      width: 100.0,
                                      height: 100.0,
                                      decoration: BoxDecoration(
                                        color: Colors
                                            .grey[200], // Placeholder color
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(12),
                                          topLeft: Radius.circular(12),
                                        ),
                                      ),
                                      child: Icon(
                                        Icons
                                            .store, // Placeholder icon when image is null
                                        color: Colors.grey[400],
                                      ),
                                    ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 6.0),
                                      child: Text(
                                        currentWarehouse.itemName,
                                        style: pjsMedium18,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 6.0),
                                      child: Text(
                                        currentWarehouse.category,
                                        style: pjsMedium16Grey,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6.0),
                                      child: Row(
                                        children: [
                                          Text(
                                              formatRupiah(currentWarehouse
                                                  .pricePerMonth),
                                              style: pjsMedium16Tosca2),
                                          Spacer(),
                                          Icon(Icons.star,
                                              color: Colors.amber, size: 20),
                                          Text(
                                            ' (4.8)',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
