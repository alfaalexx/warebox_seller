// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCIrgupy5ujNrlaEZMd5WGG-epi6ZiDEiw',
    appId: '1:746599558975:web:d0a75af831fc57ae3d6d8a',
    messagingSenderId: '746599558975',
    projectId: 'warebox-8279e',
    authDomain: 'warebox-8279e.firebaseapp.com',
    storageBucket: 'warebox-8279e.appspot.com',
    measurementId: 'G-PE8JGYZYER',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDsPtS-6hR8yABPhOu8OPDDE6xssZEDdl0',
    appId: '1:746599558975:android:81aec90ba197b06e3d6d8a',
    messagingSenderId: '746599558975',
    projectId: 'warebox-8279e',
    storageBucket: 'warebox-8279e.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCRoVSeMX3XoBC8ipyRNelzubUSk6NUfxQ',
    appId: '1:746599558975:ios:ee4bbac888a027873d6d8a',
    messagingSenderId: '746599558975',
    projectId: 'warebox-8279e',
    storageBucket: 'warebox-8279e.appspot.com',
    iosBundleId: 'com.example.wareboxSeller',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCRoVSeMX3XoBC8ipyRNelzubUSk6NUfxQ',
    appId: '1:746599558975:ios:fd3ee6003f5fead13d6d8a',
    messagingSenderId: '746599558975',
    projectId: 'warebox-8279e',
    storageBucket: 'warebox-8279e.appspot.com',
    iosBundleId: 'com.example.wareboxSeller.RunnerTests',
  );
}
