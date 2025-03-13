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
    apiKey: 'AIzaSyB17SoWThru6oqHpEKjW1FaLuYnNDY_dLA',
    appId: '1:945841099979:web:86123a06bf9c0df205374e',
    messagingSenderId: '945841099979',
    projectId: 'rentloapp-admin',
    authDomain: 'rentloapp-admin.firebaseapp.com',
    storageBucket: 'rentloapp-admin.firebasestorage.app',
    measurementId: 'G-VFKLH283GR',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAguaCAv3YP07yjejqpwm7vEfO5EZNaveU',
    appId: '1:945841099979:android:bfe0058313471f3705374e',
    messagingSenderId: '945841099979',
    projectId: 'rentloapp-admin',
    storageBucket: 'rentloapp-admin.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD88PR_DjOJuRPLdzXW2My-m37wnZd_2nU',
    appId: '1:945841099979:ios:d788fcac2f4e513d05374e',
    messagingSenderId: '945841099979',
    projectId: 'rentloapp-admin',
    storageBucket: 'rentloapp-admin.firebasestorage.app',
    androidClientId: '945841099979-92u7lkkvgk572u29sdvto829sqouvk7l.apps.googleusercontent.com',
    iosClientId: '945841099979-f5b84tj94d19f4fn96q6s645l6b3m2fs.apps.googleusercontent.com',
    iosBundleId: 'com.example.rentloappAdmin',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD88PR_DjOJuRPLdzXW2My-m37wnZd_2nU',
    appId: '1:945841099979:ios:d788fcac2f4e513d05374e',
    messagingSenderId: '945841099979',
    projectId: 'rentloapp-admin',
    storageBucket: 'rentloapp-admin.firebasestorage.app',
    androidClientId: '945841099979-92u7lkkvgk572u29sdvto829sqouvk7l.apps.googleusercontent.com',
    iosClientId: '945841099979-f5b84tj94d19f4fn96q6s645l6b3m2fs.apps.googleusercontent.com',
    iosBundleId: 'com.example.rentloappAdmin',
  );
}
