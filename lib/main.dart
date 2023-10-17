import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:warebox_seller/pages/auth/sign_in_page.dart';
import 'package:warebox_seller/pages/dashboard/dashboard_screen.dart';
import 'package:warebox_seller/pages/splash/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final user = snapshot.data;
            if (user == null) {
              return SplashScreen(
                onInitializationComplete: () {
                  // Navigasi ke layar Login setelah splash screen selesai
                  navigatorKey.currentState?.pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const LoginPage(),
                    ),
                  );
                },
              );
            } else {
              return SplashScreen(
                onInitializationComplete: () {
                  // Navigasi ke layar Dashboard setelah splash screen selesai
                  navigatorKey.currentState?.pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const DashboardScreen(),
                    ),
                  );
                },
              );
            }
          } else {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
