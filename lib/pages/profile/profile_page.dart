import 'package:flutter/material.dart';
import 'package:warebox_seller/pages/profile/edit_profile_page.dart';
import 'package:warebox_seller/utils/custom_themes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Import Firebase Core
// import '../../utils/color_resources.dart';
// import '../../utils/dimensions.dart';
import '../auth/sign_in_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String displayName = "Loading...";
  String email = "Loading...";
  String profileImageUrl = "";

  @override
  void initState() {
    super.initState();
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

  void _openEditProfilePage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(),
      ),
    );

    if (result != null && result) {
      // Memuat ulang data profil jika result tidak null dan true
      loadProfileData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        elevation: 0,
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
              'Profile',
              textAlign: TextAlign.start,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 1, 0, 0),
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 3,
                    color: Color(0x33000000),
                    offset: Offset(0, 1),
                  )
                ],
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 20),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Container ini Menampilkan Profile Image
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
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
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
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(30, 0, 70, 0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: pjsMedium18,
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                            child: Text(
                              email,
                              style: pjsRegular14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(16, 16, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('My Account', style: pjsMedium16),
              ],
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
                child: ElevatedButton(
                  onPressed: () {
                    _openEditProfilePage();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: const Size(0, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2.5,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.penToSquare,
                        color: Color(0xFF57636C),
                        size: 20,
                      ),
                      Text(
                        'Edit Profile',
                        style: pjsMedium16Black2,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 190),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFF57636C),
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: const Size(0, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2.5,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.lock_outline,
                        color: Color(0xFF57636C),
                        size: 20,
                      ),
                      Text(
                        'Change Password',
                        style: pjsMedium16Black2,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 150),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFF57636C),
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
                child: ElevatedButton(
                  onPressed: () {
                    // Tambahkan aksi logout di sini
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: const Size(0, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2.5,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.exit_to_app,
                        color: Colors.red,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Log Out',
                        style: pjsSemiBold16Red,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
