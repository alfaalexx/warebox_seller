import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:warebox_seller/pages/profile/edit_profile_page.dart';
import 'package:warebox_seller/pages/warehouse/detail_warehouse_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:warebox_seller/utils/custom_themes.dart';
import 'package:warebox_seller/model/warehouse_model.dart';
import 'package:warebox_seller/pages/home/image_slider/image_slider.dart';
import 'package:warebox_seller/pages/home/warehouse_category/custom_category_button.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:warebox_seller/utils/warebox_icon_icons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  String displayName = "Loading...";
  String email = "Loading...";
  String profileImageUrl = "";
  String searchKey = '';

  TextEditingController searchController = TextEditingController();
  final CarouselController _carouselController = CarouselController();

  final List<String> imageList = [
    "assets/images/image1.jpg",
    "assets/images/image2.jpg",
    "assets/images/image3.jpg",
    "assets/images/image2.jpg",
    "assets/images/image5.jpg"
  ];

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle unauthenticated user if needed
    }
    loadProfileData();
  }

  void loadProfileData() async {
    final User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      final String currentUid = currentUser.uid;
      final DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('profile')
          .doc(currentUid)
          .get();

      if (documentSnapshot.exists) {
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          displayName = data['username'];
          email = data['email'];
          profileImageUrl = data['profile_image'] ??
              ""; // Ambil URL gambar profil jika tersedia
        });
      } else {
        print('Data profil tidak ditemukan');
      }
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Text(
          'Home',
          style: GoogleFonts.plusJakartaSans(
              fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: <Widget>[
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfilePage(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(30.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: profileImageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: profileImageUrl,
                        placeholder: (context, url) => SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              color: Colors.black,
                            )),
                        errorWidget: (context, url, error) => Icon(
                          Icons.error,
                          color: Colors.red,
                        ),
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      )
                    : Image.asset("assets/images/logo.png",
                        width: 40, height: 40),
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // Add more drawer items if needed
          ],
        ),
      ),
      body: SingleChildScrollView(
          child: Column(
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
                  searchKey = value;
                });
              },
            ),
          ),
          if (searchKey.isNotEmpty)
            Column(
              children: [
                // Display search results
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('warehouses')
                      .where('itemName_lowercase',
                          isGreaterThanOrEqualTo: searchKey.toLowerCase())
                      .where('itemName_lowercase',
                          isLessThanOrEqualTo:
                              searchKey.toLowerCase() + '\uf8ff')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No warehouses found.'));
                    } else {
                      return Column(
                        children: snapshot.data!.docs.map((warehouse) {
                          final Warehouse currentWarehouse =
                              Warehouse.fromSnapshot(warehouse);

                          return ListTile(
                            title: Text(currentWarehouse.itemName),
                            subtitle: Text(currentWarehouse.category),
                            onTap: () {
                              // Handle onTap action using currentWarehouse
                              print('Tapped on ${currentWarehouse.itemName}');
                              // Misalnya, navigasi ke halaman detail
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailWarehousePage(
                                    warehouseId: currentWarehouse.id,
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      );
                    }
                  },
                ),
              ],
            )
          else
            Column(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 18.0, right: 18.0, top: 25.0, bottom: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Recomended Warehouse",
                            style: pjsSemiBold14,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 18, right: 18),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            height: 220,
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.0)),
                            child: CustomImageSlider(
                              imageList: imageList,
                              carouselController: _carouselController,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                18, 5, 0, 0),
                            child: Text(
                              'Choose Your Category Warehouse',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1E2022),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 18),
                        child: Row(
                          children: [
                            CustomWarehouseItem(
                              icon: WareboxIcon.gudangUmum,
                              title1: "Gudang",
                              title2: "Umum",
                              onTap: () {
                                // Handle onTap action here
                              },
                            ),
                            CustomWarehouseItem(
                              icon: WareboxIcon.gudangKhusus,
                              title1: "Gudang",
                              title2: "Khusus",
                              onTap: () {
                                // Handle onTap action here
                              },
                            ),
                            CustomWarehouseItem(
                              icon: WareboxIcon.gudangDingin,
                              title1: "Gudang",
                              title2: "Dingin",
                              onTap: () {
                                // Handle onTap action here
                              },
                            ),
                            CustomWarehouseItem(
                              icon: WareboxIcon.gudangEccomerce,
                              title1: "Gudang",
                              title2: "Ecommerce",
                              onTap: () {
                                // Handle onTap action here
                              },
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 18.0, right: 18.0, top: 23, bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Warehouse List",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                              color: const Color(0xFF1E2022),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // click action
                            },
                            child: Text(
                              "See All",
                              style: pjsMedium12Tosca400,
                            ),
                          )
                        ],
                      ),
                    ),
                    // StreamBuilder untuk menampilkan daftar gudang
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('warehouses')
                          .where('itemName_lowercase',
                              isGreaterThanOrEqualTo: searchKey.toLowerCase())
                          .where('itemName_lowercase',
                              isLessThanOrEqualTo:
                                  searchKey.toLowerCase() + '\uf8ff')
                          .limit(3)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.docs.isEmpty) {
                          return const Center(
                              child: Text('No warehouses found.'));
                        } else {
                          return Column(
                            children: snapshot.data!.docs.map((warehouse) {
                              final Warehouse currentWarehouse =
                                  Warehouse.fromSnapshot(warehouse);

                              return ListTile(
                                title: Text(currentWarehouse.itemName),
                                subtitle: Text(currentWarehouse.category),
                                onTap: () {
                                  // Handle onTap action using currentWarehouse
                                  print(
                                      'Tapped on ${currentWarehouse.itemName}');
                                  // Misalnya, navigasi ke halaman detail
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailWarehousePage(
                                        warehouseId: currentWarehouse.id,
                                      ),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          );
                        }
                      },
                    ),
                  ],
                )
              ],
            ),
        ],
      )),
    );
  }
}
