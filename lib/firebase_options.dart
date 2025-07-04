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
    apiKey: 'AIzaSyCYVWcHEeaGi8JYkacUoj3kyyTxc3wJIwE',
    appId: '1:553442323936:web:63a5557cc0f71a1edbcf85',
    messagingSenderId: '553442323936',
    projectId: 'app-melaly',
    authDomain: 'app-melaly.firebaseapp.com',
    storageBucket: 'app-melaly.firebasestorage.app',
    measurementId: 'G-3XNXE5HT45',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAg-chTUVepJ6bazQRClkgChRN3VHN5nfA',
    appId: '1:553442323936:android:53fdc2c9f652b567dbcf85',
    messagingSenderId: '553442323936',
    projectId: 'app-melaly',
    storageBucket: 'app-melaly.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyANPW2OgIMObEzPYYDVB9TXRuiEvcNligA',
    appId: '1:553442323936:ios:8fa3a2b83822dcecdbcf85',
    messagingSenderId: '553442323936',
    projectId: 'app-melaly',
    storageBucket: 'app-melaly.firebasestorage.app',
    iosBundleId: 'com.example.melaly',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyANPW2OgIMObEzPYYDVB9TXRuiEvcNligA',
    appId: '1:553442323936:ios:8fa3a2b83822dcecdbcf85',
    messagingSenderId: '553442323936',
    projectId: 'app-melaly',
    storageBucket: 'app-melaly.firebasestorage.app',
    iosBundleId: 'com.example.melaly',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCYVWcHEeaGi8JYkacUoj3kyyTxc3wJIwE',
    appId: '1:553442323936:web:dd5749a12a0ae1c0dbcf85',
    messagingSenderId: '553442323936',
    projectId: 'app-melaly',
    authDomain: 'app-melaly.firebaseapp.com',
    storageBucket: 'app-melaly.firebasestorage.app',
    measurementId: 'G-SZXZZ61214',
  );
}
