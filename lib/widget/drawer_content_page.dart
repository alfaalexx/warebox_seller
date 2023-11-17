import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:warebox_seller/pages/auth/sign_in_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:warebox_seller/pages/reservation/list_reservation_page.dart';

class DrawerContentPage extends StatefulWidget {
  const DrawerContentPage({super.key});

  @override
  State<DrawerContentPage> createState() => _DrawerContentPageState();
}

class _DrawerContentPageState extends State<DrawerContentPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  String displayName = "Loading...";
  String email = "Loading...";
  String profileImageUrl = "";

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
    return Drawer(
        child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(top: 20.0),
          padding:
              const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 4),
          color: Colors.transparent, // Background color
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color(0xFF2E9496), // Warna border
                    width: 2, // Lebar border
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: profileImageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: profileImageUrl,
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                            fit: BoxFit.cover,
                          )
                        : Image.asset("assets/images/logo.png"),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 50, bottom: 55, left: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    displayName,
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF3A3A3A),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 60,
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12.0),
            child: InkWell(
              onTap: () {
                // Add your payment functionality here
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyReservationPage(),
                  ),
                );
              },
              child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(FontAwesomeIcons.warehouse,
                        color: Color(0xFF11A6A1), size: 18),
                    Padding(
                      padding: const EdgeInsets.only(left: 30.0),
                      child: Text(
                        "My Reservation",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                          color: const Color(0xFF2E9496),
                        ),
                      ),
                    ),
                    Spacer(),
                    ImageIcon(AssetImage("assets/images/arrow_left_side.png"),
                        color: Color(0xFF11A6A1))
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 60,
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12.0),
            child: InkWell(
              onTap: () {
                // Add your payment functionality here
              },
              child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(FontAwesomeIcons.moneyBillTransfer,
                        color: Color(0xFF11A6A1), size: 18),
                    Padding(
                      padding: const EdgeInsets.only(left: 30.0),
                      child: Text(
                        "Recent Payments",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                          color: const Color(0xFF2E9496),
                        ),
                      ),
                    ),
                    Spacer(),
                    ImageIcon(AssetImage("assets/images/arrow_left_side.png"),
                        color: Color(0xFF11A6A1))
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 60,
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12.0),
            child: InkWell(
              onTap: () {
                _auth.signOut();
                Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (context) {
                  return const LoginPage();
                }), (route) => false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Logout Successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(FontAwesomeIcons.arrowRightFromBracket,
                        color: Color(0xFF11A6A1), size: 18),
                    Padding(
                      padding: const EdgeInsets.only(left: 30.0),
                      child: Text(
                        "Logout",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                          color: const Color(0xFF2E9496),
                        ),
                      ),
                    ),
                    Spacer(),
                    ImageIcon(AssetImage("assets/images/arrow_left_side.png"),
                        color: Color(0xFF11A6A1))
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ));
  }
}
