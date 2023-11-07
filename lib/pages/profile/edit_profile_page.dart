import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:warebox_seller/utils/custom_themes.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../utils/color_resources.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _aboutMeController = TextEditingController();

  String? displayName;
  String? email;
  String? gender;
  String? phoneNumber;
  String? address;
  String? aboutMe;
  String? profileImageUrl;
  bool isLoading = false;

  final FirebaseStorage _storage = FirebaseStorage.instance;

  List<String> genderOptions = ['Laki - Laki', 'Perempuan'];
  String? selectedGender;

  @override
  void initState() {
    super.initState();
    // Periksa status otentikasi pengguna.
    loadProfileData();
  }

  void loadProfileData() {
    final User? user = _auth.currentUser;
    if (user != null) {
      final uid = user.uid;
      FirebaseFirestore.instance
          .collection('profile')
          .doc(uid)
          .get()
          .then((doc) {
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          setState(() {
            displayName = data['username'];
            email = data['email'];
            gender = data['gender'];
            phoneNumber = data['phone_number'];
            address = data['address'];
            aboutMe = data['about_me'];
            profileImageUrl = data['profile_image'];

            _nameController.text = displayName ?? '';
            _emailController.text = email ?? '';
            selectedGender = gender;
            _phoneNumberController.text = phoneNumber ?? '';
            _addressController.text = address ?? '';
            _aboutMeController.text = aboutMe ?? '';
          });
        }
      });
    }
  }

  Future<void> _uploadProfileImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);

    if (pickedFile == null) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    final User? user = _auth.currentUser;
    if (user == null) {
      // Handle the case where there is no authenticated user.
      return;
    }

    Reference reference = _storage.ref().child(
        'profile_images/${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');
    UploadTask uploadTask = reference.putFile(File(pickedFile.path));

    try {
      await uploadTask.whenComplete(() async {
        final String imageUrl = await reference.getDownloadURL();

        setState(() {
          isLoading = false;
          profileImageUrl = imageUrl;
        });
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading profile image: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  void updateProfile() {
    final User? user = _auth.currentUser;
    if (user != null) {
      final uid = user.uid;
      final updatedName = _nameController.text;
      final updatedEmail = _emailController.text;
      final updatedPhoneNumber = _phoneNumberController.text;
      final updatedAddress = _addressController.text;
      final updatedAboutMe = _aboutMeController.text;

      setState(() {
        isLoading = true;
      });

      FirebaseFirestore.instance.collection('profile').doc(uid).set({
        'uid': uid,
        'username': updatedName,
        'email': updatedEmail,
        'gender': selectedGender,
        'phone_number': updatedPhoneNumber,
        'address': updatedAddress,
        'about_me': updatedAboutMe,
        'profile_image': profileImageUrl,
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          isLoading = false;
          displayName = updatedName;
          email = updatedEmail;
          phoneNumber = updatedPhoneNumber;
          address = updatedAddress;
          aboutMe = updatedAboutMe;
        });

        Navigator.pop(context, true);
      }).catchError((error) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $error'),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          textAlign: TextAlign.start,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  50), // This creates a circular shape
                              child: profileImageUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: profileImageUrl!,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        width: 100,
                                        height: 100,
                                        color: Colors.grey,
                                        child: Center(
                                            child: CircularProgressIndicator()),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        width: 100,
                                        height: 100,
                                        color: Colors.grey,
                                        child: Center(child: Icon(Icons.error)),
                                      ),
                                    )
                                  : Container(
                                      width: 100,
                                      height: 100,
                                      color: Colors.grey,
                                      child: Center(
                                          child: Icon(Icons.add_a_photo,
                                              size: 50)),
                                    ),
                            ),
                          ),
                          TextButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text("Choose an option"),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _uploadProfileImage(
                                                ImageSource.camera);
                                          },
                                          child: Text("Camera"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _uploadProfileImage(
                                                ImageSource.gallery);
                                          },
                                          child: Text("Gallery"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Text(
                                'Edit Photo Profile',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Color(0xFF2E9496),
                                  fontSize: 14,
                                ),
                              ))
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Username',
                      style: pjsMedium16,
                    ),
                    SizedBox(height: 5),
                    TextField(
                      controller: _nameController,
                      style: pjsMedium16Black2,
                      decoration: InputDecoration(
                        errorStyle: pjsSemiBold16Red,
                        filled: true,
                        fillColor: Color(0xFFF2F2F2),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0x00000000), width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF2E9496),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Address',
                      style: pjsMedium16,
                    ),
                    SizedBox(height: 5),
                    TextField(
                      controller: _addressController,
                      style: pjsMedium16Black2,
                      decoration: InputDecoration(
                        errorStyle: pjsSemiBold16Red,
                        filled: true,
                        fillColor: Color(0xFFF2F2F2),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0x00000000), width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF2E9496),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Gender',
                                style: pjsMedium16,
                              ),
                              SizedBox(height: 5),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical:
                                        4), // Padding for inside the dropdown
                                decoration: BoxDecoration(
                                  color: Color(0xFFF2F2F2),
                                  borderRadius: BorderRadius.circular(
                                      12), // Border radius
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedGender,
                                    items: genderOptions.map((String gender) {
                                      return DropdownMenuItem<String>(
                                        value: gender,
                                        child: Text(gender),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedGender = newValue;
                                      });
                                    },
                                    style: pjsMedium16, // Your predefined style
                                    // DropdownButton requires an additional decoration for the dropdown itself
                                    dropdownColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Phone Number',
                                style: pjsMedium16,
                              ),
                              SizedBox(height: 5),
                              TextField(
                                controller: _phoneNumberController,
                                style: pjsMedium16Black2,
                                decoration: InputDecoration(
                                  errorStyle: pjsSemiBold16Red,
                                  filled: true,
                                  fillColor: Color(0xFFF2F2F2),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color(0x00000000), width: 2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.red, width: 2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xFF2E9496),
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'About Me',
                      style: pjsMedium16,
                    ),
                    SizedBox(height: 5),
                    TextField(
                      controller: _aboutMeController,
                      style: pjsMedium16Black2,
                      maxLines: 5,
                      decoration: InputDecoration(
                        errorStyle: pjsSemiBold16Red,
                        filled: true,
                        fillColor: Color(0xFFF2F2F2),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0x00000000), width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF2E9496),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorResources.wareboxTosca,
                          minimumSize: const Size(0, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Update', style: pjsExtraBold20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
