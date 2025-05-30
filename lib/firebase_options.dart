// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyD1DMTFYH6qJCNy5_dIB9VN_i1UwCBdr_8',
    appId: '1:75781920727:web:372fbc523a6f2ae279dd92',
    messagingSenderId: '75781920727',
    projectId: 'myzik-app',
    authDomain: 'myzik-app.firebaseapp.com',
    storageBucket: 'myzik-app.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAYLKXrVHX07gPxd834JYu-TfqZQm0UfiI',
    appId: '1:75781920727:android:3d619c82a616635579dd92',
    messagingSenderId: '75781920727',
    projectId: 'myzik-app',
    storageBucket: 'myzik-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBg0vcfAAKEOcSA28X77l-CLkbYAzCpQ1Y',
    appId: '1:75781920727:ios:321f79f3867e085d79dd92',
    messagingSenderId: '75781920727',
    projectId: 'myzik-app',
    storageBucket: 'myzik-app.firebasestorage.app',
    iosBundleId: 'com.example.myzikAppTest',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBg0vcfAAKEOcSA28X77l-CLkbYAzCpQ1Y',
    appId: '1:75781920727:ios:321f79f3867e085d79dd92',
    messagingSenderId: '75781920727',
    projectId: 'myzik-app',
    storageBucket: 'myzik-app.firebasestorage.app',
    iosBundleId: 'com.example.myzikAppTest',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD1DMTFYH6qJCNy5_dIB9VN_i1UwCBdr_8',
    appId: '1:75781920727:web:482c8d1998b3796779dd92',
    messagingSenderId: '75781920727',
    projectId: 'myzik-app',
    authDomain: 'myzik-app.firebaseapp.com',
    storageBucket: 'myzik-app.firebasestorage.app',
  );
}
