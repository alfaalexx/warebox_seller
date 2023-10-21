import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:warebox_seller/utils/custom_themes.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:warebox_seller/utils/warebox_icon_icons.dart';
import 'package:warebox_seller/pages/auth/sign_in_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utils/color_resources.dart';
import '../../utils/dimensions.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passController = TextEditingController();
  TextEditingController _nameController = TextEditingController();

  String _email = "";
  String _password = "";
  String _name = "";
  bool _acceptPrivacy = false;

  void _handleSignUp() async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      );

      // Kirim email verifikasi ke pengguna yang baru mendaftar.
      await userCredential.user?.sendEmailVerification();

      // Simpan data pengguna ke Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'uid': userCredential.user!.uid,
        'name': _name,
        'email': _email,
        'isAdmin': false,
      });

      // Beralih ke halaman login (atau tindakan yang sesuai).
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) {
        return const LoginPage();
      }), (route) => false);
      // Tampilkan pesan sukses dan instruksi verifikasi email.
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Email Verification"),
              content: Text(
                  "A verification email has been sent to your email address. Please verify your email before logging in."),
              actions: <Widget>[
                TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
      // print("User Registered: ${userCredential.user!.email}");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        // print('The account already exists for that email.');
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("An Error Occurred"),
                content: Text("The account already exists for that email."),
                actions: <Widget>[
                  TextButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            });
      }
    } catch (e) {
      // print("Error During Registration: $e");
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("An Error Occurred"),
              content: Text("Error During Registration: $e"),
              actions: <Widget>[
                TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Login')),
      backgroundColor: const Color(0xFFF2F5F9),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 50),
                Container(
                  alignment: Alignment.topLeft,
                  margin: const EdgeInsets.only(left: 5, right: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sign Up', style: extraBold),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  alignment: Alignment.topLeft,
                  child: Form(
                    // key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 5, right: 5),
                          child: Text(
                            'Username',
                            style: titleHeader2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Input User's Name
                        Container(
                          margin: const EdgeInsets.only(left: 5, right: 5),
                          child: TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              hintText: 'Enter Your Name',
                              hintStyle: pjsSemiBold16,
                              errorStyle: pjsSemiBold16Red,
                              filled: true,
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0x00000000), width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF2E9496),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(
                                Icons.person_2_outlined,
                                color: Colors.black,
                                size: 20,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 20),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please Enter Your Name";
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                _name = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Email
                        Container(
                          margin: const EdgeInsets.only(left: 5, right: 5),
                          child: Text(
                            'Email Address',
                            style: titleHeader2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          margin: const EdgeInsets.only(left: 5, right: 5),
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'youremail@gmail.com',
                              hintStyle: pjsSemiBold16,
                              errorStyle: pjsSemiBold16Red,
                              filled: true,
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0x00000000), width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF2E9496),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(
                                WareboxIcon.email,
                                color: Colors.black,
                                size: 20,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 20),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please Enter Your Email";
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                _email = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          margin: const EdgeInsets.only(left: 5, right: 5),
                          child: Text(
                            'Password',
                            style: titleHeader2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          margin: const EdgeInsets.only(left: 5, right: 5),
                          child: TextFormField(
                            controller: _passController,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              hintStyle: pjsSemiBold16,
                              errorStyle: pjsSemiBold16Red,
                              filled: true,
                              fillColor: Colors.white,
                              isDense: true,
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0x00000000), width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF2E9496),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(
                                WareboxIcon.lock,
                                color: Colors.black,
                                size: 20,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 20),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please Enter Your Password";
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                _password = value;
                              });
                            },
                          ),
                        ),
                        // const SizedBox(height: 20),
                        // Container(
                        //   margin: const EdgeInsets.only(left: 5, right: 5),
                        //   child: const Text(
                        //     'Confirm Password',
                        //     style: titleHeader2,
                        //   ),
                        // ),
                        // const SizedBox(height: 10),
                        // Container(
                        //   margin: const EdgeInsets.only(left: 5, right: 5),
                        //   child: TextField(
                        //     obscureText: true,
                        //     decoration: InputDecoration(
                        //       hintText: 'Password',
                        //       hintStyle: pjsSemiBold16,
                        //       errorStyle: pjsSemiBold16Red,
                        //       filled: true,
                        //       fillColor: Colors.white,
                        //       isDense: true,
                        //       enabledBorder: OutlineInputBorder(
                        //         borderSide: BorderSide(
                        //             color: Color(0x00000000), width: 2),
                        //         borderRadius: BorderRadius.circular(12),
                        //       ),
                        //       focusedBorder: OutlineInputBorder(
                        //         borderSide: BorderSide(
                        //           color: Color(0xFF2E9496),
                        //         ),
                        //         borderRadius: BorderRadius.circular(12),
                        //       ),
                        //       prefixIcon: const Icon(
                        //         WareboxIcon.lock,
                        //         color: Colors.black,
                        //         size: 20,
                        //       ),
                        //       contentPadding: EdgeInsets.symmetric(
                        //           vertical: 15, horizontal: 20),
                        //     ),
                        //   ),
                        // ),
                        Container(
                          margin: const EdgeInsets.only(
                            right: Dimensions.marginSizeSmall,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    checkColor: ColorResources.white,
                                    activeColor: Theme.of(context).primaryColor,
                                    value: _acceptPrivacy,
                                    onChanged: (bool? newValue) {
                                      setState(() {
                                        _acceptPrivacy = newValue ?? false;
                                      });
                                    },
                                  ),
                                  Text(
                                    'By continuing you accept our Privacy Policy and\nTerm of Use',
                                    style: titilliumRegular,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          margin: const EdgeInsets.only(
                            left: Dimensions.marginSizeLarge,
                            right: Dimensions.marginSizeLarge,
                            bottom: Dimensions.marginSizeLarge,
                            top: Dimensions.marginSizeLarge,
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _handleSignUp();
                              }
                            }, // Anda dapat menentukan tindakan yang sesuai di sini
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E9496),
                              minimumSize: const Size(0, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Sign Up',
                                  style: pjsExtraBold20,
                                ),
                                const SizedBox(width: 10),
                                const Icon(Icons.person_2_outlined),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 50),
                        Stack(
                          alignment: const AlignmentDirectional(0, 0),
                          children: [
                            Align(
                              alignment: const AlignmentDirectional(0.00, 0.00),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0, 12, 0, 12),
                                child: Container(
                                  width: double.infinity,
                                  height: 2,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE0E3E7),
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: const AlignmentDirectional(0.00, 0.00),
                              child: Container(
                                width: 70,
                                height: 32,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF2F5F9),
                                ),
                                alignment:
                                    const AlignmentDirectional(0.00, 0.00),
                                child: Text(
                                  'OR',
                                  style: pjsMedium16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Container(
                          alignment: Alignment.center,
                          child: Material(
                            elevation: 0, // Efek naik ketika tombol ditekan
                            borderRadius: BorderRadius.circular(12),
                            color: const Color(0xFFF2F5F9),
                            child: InkWell(
                              onTap: () {
                                // Tindakan yang ingin Anda jalankan saat tombol ditekan
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Ink(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 25,
                                    horizontal:
                                        20), // Sesuaikan padding sesuai kebutuhan
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFDCE1E8),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize
                                      .min, // Memastikan tombol hanya mengambil ruang yang dibutuhkan
                                  children: [
                                    FaIcon(
                                      FontAwesomeIcons.google,
                                      color: Color(0xFF3D4966),
                                    ),
                                    SizedBox(
                                        width:
                                            10), // Jarak antara ikon dan teks
                                    Text(
                                      'Sign Up with Google',
                                      style: titleHeader,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.only(top: 0.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: pjsSemiBold16,
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return const LoginPage();
                                      },
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                    backgroundColor: Colors.transparent),
                                child: Text(
                                  'Sign In',
                                  style: pjsExtraBold16RedUnderlined,
                                ),
                              )
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
  }
}
