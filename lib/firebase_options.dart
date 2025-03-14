// lib/firebase_options.dart
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  /// Returns the default Firebase options for the current platform.
  /// Here we default to the user configuration.
  static FirebaseOptions get currentPlatform => user;

  /// Options for the primary (user) Firebase project.
  static FirebaseOptions get user {
    if (kIsWeb) {
      return _userWeb;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _userAndroid;
      case TargetPlatform.iOS:
        return _userIOS;
      case TargetPlatform.macOS:
        return _userMacOS;
      case TargetPlatform.windows:
        return _userWindows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux for the user project.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform for the user project.',
        );
    }
  }

  /// Options for the secondary (admin) Firebase project.
  static FirebaseOptions get admin {
    if (kIsWeb) {
      return _adminWeb;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _adminAndroid;
      case TargetPlatform.iOS:
        return _adminIOS;
      case TargetPlatform.macOS:
        return _adminMacOS;
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

  // User (primary) Firebase options
  static const FirebaseOptions _userWeb = FirebaseOptions(
    apiKey: 'AIzaSyClE8kS2CR7ccmWLtmt4GdYPc_Z2dM7q58',
    appId: '1:342439789580:web:18b49f3c69bd176e251a29',
    messagingSenderId: '342439789580',
    projectId: 'rentloapp-aad3f',
    authDomain: 'rentloapp-aad3f.firebaseapp.com',
    databaseURL: 'https://rentloapp-aad3f-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'rentloapp-aad3f.appspot.com',
    measurementId: 'G-CL8DL4MD57',
  );

  static const FirebaseOptions _userAndroid = FirebaseOptions(
    apiKey: 'AIzaSyAhKUhvS9b1UACwSO87b0mL7sHdRnC3UWQ',
    appId: '1:342439789580:android:9ebee13b0ee49c3e251a29',
    messagingSenderId: '342439789580',
    projectId: 'rentloapp-aad3f',
    databaseURL: 'https://rentloapp-aad3f-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'rentloapp-aad3f.appspot.com',
  );

  static const FirebaseOptions _userIOS = FirebaseOptions(
    apiKey: 'AIzaSyD8w4BHDA8aMVijTIKe0MteNANJ8H9H4RQ',
    appId: '1:342439789580:ios:7d54e7dfbf3f9fc0251a29',
    messagingSenderId: '342439789580',
    projectId: 'rentloapp-aad3f',
    databaseURL: 'https://rentloapp-aad3f-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'rentloapp-aad3f.appspot.com',
    androidClientId: '342439789580-3j823qp34i067r8k73mkebvqfltrpjjb.apps.googleusercontent.com',
    iosClientId: '342439789580-segqtd16d4a6sh7erdqa08l3tj491o43.apps.googleusercontent.com',
    iosBundleId: 'com.example.rentloapp',
  );

  static const FirebaseOptions _userMacOS = FirebaseOptions(
    apiKey: 'AIzaSyD8w4BHDA8aMVijTIKe0MteNANJ8H9H4RQ',
    appId: '1:342439789580:ios:7d54e7dfbf3f9fc0251a29',
    messagingSenderId: '342439789580',
    projectId: 'rentloapp-aad3f',
    databaseURL: 'https://rentloapp-aad3f-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'rentloapp-aad3f.appspot.com',
    androidClientId: '342439789580-3j823qp34i067r8k73mkebvqfltrpjjb.apps.googleusercontent.com',
    iosClientId: '342439789580-segqtd16d4a6sh7erdqa08l3tj491o43.apps.googleusercontent.com',
    iosBundleId: 'com.example.rentloapp',
  );

  static const FirebaseOptions _userWindows = FirebaseOptions(
    apiKey: 'AIzaSyBeiKfInbD8d7UEZn3XuaT4af-MyA_gGds',
    appId: '1:342439789580:web:4b32ac462d2e182e251a29',
    messagingSenderId: '342439789580',
    projectId: 'rentloapp-aad3f',
    authDomain: 'rentloapp-aad3f.firebaseapp.com',
    databaseURL: 'https://rentloapp-aad3f-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'rentloapp-aad3f.appspot.com',
    measurementId: 'G-941W8WFGM8',
  );

  // Admin Firebase options
  static const FirebaseOptions _adminWeb = FirebaseOptions(
    apiKey: 'AIzaSyB17SoWThru6oqHpEKjW1FaLuYnNDY_dLA',
    appId: '1:945841099979:web:86123a06bf9c0df205374e',
    messagingSenderId: '945841099979',
    projectId: 'rentloapp-admin',
    authDomain: 'rentloapp-admin.firebaseapp.com',
    storageBucket: 'rentloapp-admin.firebasestorage.app',
    measurementId: 'G-VFKLH283GR',
  );

  static const FirebaseOptions _adminAndroid = FirebaseOptions(
    apiKey: 'AIzaSyAguaCAv3YP07yjejqpwm7vEfO5EZNaveU',
    appId: '1:945841099979:android:bfe0058313471f3705374e',
    messagingSenderId: '945841099979',
    projectId: 'rentloapp-admin',
    storageBucket: 'rentloapp-admin.firebasestorage.app',
  );

  static const FirebaseOptions _adminIOS = FirebaseOptions(
    apiKey: 'AIzaSyD88PR_DjOJuRPLdzXW2My-m37wnZd_2nU',
    appId: '1:945841099979:ios:d788fcac2f4e513d05374e',
    messagingSenderId: '945841099979',
    projectId: 'rentloapp-admin',
    storageBucket: 'rentloapp-admin.firebasestorage.app',
    androidClientId: '945841099979-92u7lkkvgk572u29sdvto829sqouvk7l.apps.googleusercontent.com',
    iosClientId: '945841099979-f5b84tj94d19f4fn96q6s645l6b3m2fs.apps.googleusercontent.com',
    iosBundleId: 'com.example.rentloappAdmin',
  );

  static const FirebaseOptions _adminMacOS = FirebaseOptions(
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
