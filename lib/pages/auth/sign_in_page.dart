import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:warebox_seller/utils/custom_themes.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:warebox_seller/pages/auth/sign_up_page.dart';
import 'package:warebox_seller/utils/warebox_icon_icons.dart';

import '../dashboard/dashboard_screen.dart';
import '../../utils/color_resources.dart';
import '../../utils/dimensions.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passController = TextEditingController();

  String _email = "";
  String _password = "";
  bool _obscureText = true;

  void _handleLogin() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );

      if (userCredential.user != null) {
        // Cek apakah email pengguna sudah diverifikasi.
        if (userCredential.user!.emailVerified) {
          Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (context) {
            return const DashboardScreen();
          }), (route) => false);
          print("User Logged In: ${userCredential.user!.email}");
        } else {
          // Pengguna belum memverifikasi alamat email mereka.
          // Tampilkan pesan kesalahan atau tindakan yang sesuai.
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Email Verification Required"),
                content: Text("Please verify your email before logging in."),
                actions: <Widget>[
                  TextButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          );
          // Logout pengguna karena mereka belum memverifikasi email mereka.
          await _auth.signOut();
        }
      }
    } catch (e) {
      print("Error During Login: $e");
    }
  }

  // Toggles the password show status
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
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
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sign In', style: extraBold),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  alignment: Alignment.topLeft,
                  margin: const EdgeInsets.only(left: 5, right: 5),
                  child: const Text(
                      'Sign in and get your space personalized \nwith our Warehouse.',
                      style: titleHeader),
                ),
                const SizedBox(height: 30),
                Container(
                  alignment: Alignment.topLeft,
                  child: Form(
                    // key: _formKeyLogin,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 5, right: 5),
                          child: const Text(
                            'Email Address',
                            style: titleHeader2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Input Email
                        TextFormField(
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
                        const SizedBox(height: 20),
                        const Text(
                          'Password',
                          style: titleHeader2,
                        ),
                        const SizedBox(height: 10),
                        // Input Password
                        TextFormField(
                          controller: _passController,
                          obscureText: _obscureText,
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
                            suffixIcon: IconButton(
                                icon: Icon(_obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: _toggle),
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
                                    value: false,
                                    onChanged: (val) {},
                                  ),
                                  const Text(
                                    'Remember Me',
                                    style: titilliumRegular,
                                  ),
                                ],
                              ),
                              InkWell(
                                onTap: () {},
                                child: Text(
                                  'Forgot Password',
                                  style: titilliumRegular.copyWith(
                                    color:
                                        ColorResources.getLightSkyBlue(context),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          margin: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            bottom: 20,
                            top: 30,
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              // Tindakan yang ingin Anda jalankan saat tombol ditekan
                              // Anda dapat menggunakan fungsi loginUser() di sini
                              if (_formKey.currentState!.validate()) {
                                _handleLogin();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorResources.wareboxTosca,
                              minimumSize: const Size(0, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Sign In',
                                  style: pjsExtraBold20,
                                ),
                                SizedBox(width: 10),
                                Icon(Icons.person_2_outlined)
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
                                child: const Text(
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
                                child: const Row(
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
                                      'Sign In with Google',
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
                              const Text(
                                'Don’t have an account? ',
                                style: pjsSemiBold16,
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(context,
                                      MaterialPageRoute(builder: (context) {
                                    return const RegisterPage();
                                  }), (route) => false);
                                },
                                style: TextButton.styleFrom(
                                    backgroundColor: Colors.transparent),
                                child: const Text(
                                  'Sign Up',
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
