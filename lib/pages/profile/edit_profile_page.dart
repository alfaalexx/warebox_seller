import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

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

  Future<void> _uploadProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    Reference reference =
        _storage.ref().child('profile_images/${DateTime.now()}.jpg');
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
        title: Text('Edit Profile'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile Image:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: _uploadProfileImage,
                      child: profileImageUrl != null
                          ? Image.network(
                              profileImageUrl!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            )
                          : Icon(Icons.add_a_photo, size: 100),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Name:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: _nameController,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Email:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: _emailController,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Gender:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<String>(
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
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Phone Number:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: _phoneNumberController,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Address:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: _addressController,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'About Me:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: _aboutMeController,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: updateProfile,
                      child: Text('Save'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
