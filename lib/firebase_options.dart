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
    apiKey: 'AIzaSyCDjW__5Lb5z5uzy-Lr7Sak9pTJlvcG8m8',
    appId: '1:29498082606:web:a95dcd67da6c70318fe6bf',
    messagingSenderId: '29498082606',
    projectId: 'zahratamal-36602',
    authDomain: 'zahratamal-36602.firebaseapp.com',
    storageBucket: 'zahratamal-36602.firebasestorage.app',
    measurementId: 'G-5YMRYXJ4Y4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCDjW__5Lb5z5uzy-Lr7Sak9pTJlvcG8m8',
    appId: '1:29498082606:android:PLACEHOLDER',
    messagingSenderId: '29498082606',
    projectId: 'zahratamal-36602',
    storageBucket: 'zahratamal-36602.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCDjW__5Lb5z5uzy-Lr7Sak9pTJlvcG8m8',
    appId: '1:29498082606:ios:PLACEHOLDER',
    messagingSenderId: '29498082606',
    projectId: 'zahratamal-36602',
    storageBucket: 'zahratamal-36602.firebasestorage.app',
    iosBundleId: 'sd.zahrat.amal',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCDjW__5Lb5z5uzy-Lr7Sak9pTJlvcG8m8',
    appId: '1:29498082606:ios:PLACEHOLDER',
    messagingSenderId: '29498082606',
    projectId: 'zahratamal-36602',
    storageBucket: 'zahratamal-36602.firebasestorage.app',
    iosBundleId: 'sd.zahrat.amal',
  );
}
