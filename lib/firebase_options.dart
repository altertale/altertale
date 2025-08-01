// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// ⚠️ IMPORTANT: Replace these values with your actual Firebase project configuration!
///
/// To get your config:
/// 1. Go to https://console.firebase.google.com/
/// 2. Select your project
/// 3. Project Settings > General > Your apps > Web app
/// 4. Copy the config values below
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

  // 🔥 REAL FIREBASE PROJECT CONFIG - altertale-d4a3a
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCFnulMTVEN_A3v9_8yoYPqI5VSopJ0cuk',
    appId: '1:275463243167:web:74992433e4fad68d7129aa',
    messagingSenderId: '275463243167',
    projectId: 'altertale-d4a3a',
    authDomain: 'altertale-d4a3a.firebaseapp.com',
    storageBucket: 'altertale-d4a3a.firebasestorage.app',
    measurementId: 'G-ECW65N6YFF',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCFnulMTVEN_A3v9_8yoYPqI5VSopJ0cuk',
    appId: '1:275463243167:android:androidappid',
    messagingSenderId: '275463243167',
    projectId: 'altertale-d4a3a',
    storageBucket: 'altertale-d4a3a.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCFnulMTVEN_A3v9_8yoYPqI5VSopJ0cuk',
    appId: '1:275463243167:ios:iosappid',
    messagingSenderId: '275463243167',
    projectId: 'altertale-d4a3a',
    storageBucket: 'altertale-d4a3a.firebasestorage.app',
    iosClientId: '275463243167-ios.apps.googleusercontent.com',
    iosBundleId: 'com.altertale.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCFnulMTVEN_A3v9_8yoYPqI5VSopJ0cuk',
    appId: '1:275463243167:ios:iosappid',
    messagingSenderId: '275463243167',
    projectId: 'altertale-d4a3a',
    storageBucket: 'altertale-d4a3a.firebasestorage.app',
    iosClientId: '275463243167-ios.apps.googleusercontent.com',
    iosBundleId: 'com.altertale.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCFnulMTVEN_A3v9_8yoYPqI5VSopJ0cuk',
    appId: '1:275463243167:web:74992433e4fad68d7129aa',
    messagingSenderId: '275463243167',
    projectId: 'altertale-d4a3a',
    storageBucket: 'altertale-d4a3a.firebasestorage.app',
  );
}
