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
    apiKey: 'AIzaSyDOfOOHeTML2VCA_KSJJwLN13toH44VMVI',
    appId: '1:636024861972:web:14ecc26ab5382d816bfe01',
    messagingSenderId: '636024861972',
    projectId: 'transacgym',
    authDomain: 'transacgym.firebaseapp.com',
    storageBucket: 'transacgym.appspot.com',
    measurementId: 'G-8V36CPPNQX',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD-pkxY8V6RwlMh71BXQUaPtDKSSExghzE',
    appId: '1:636024861972:android:377a47defa0a7f3b6bfe01',
    messagingSenderId: '636024861972',
    projectId: 'transacgym',
    storageBucket: 'transacgym.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDqIfRLQj93wIRkr9wJGqeigd_X1QI-GEw',
    appId: '1:636024861972:ios:3f9b029bbe7986c66bfe01',
    messagingSenderId: '636024861972',
    projectId: 'transacgym',
    storageBucket: 'transacgym.appspot.com',
    iosBundleId: 'com.example.invUpg1',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDqIfRLQj93wIRkr9wJGqeigd_X1QI-GEw',
    appId: '1:636024861972:ios:3f9b029bbe7986c66bfe01',
    messagingSenderId: '636024861972',
    projectId: 'transacgym',
    storageBucket: 'transacgym.appspot.com',
    iosBundleId: 'com.example.invUpg1',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDOfOOHeTML2VCA_KSJJwLN13toH44VMVI',
    appId: '1:636024861972:web:51ecaa167e487b876bfe01',
    messagingSenderId: '636024861972',
    projectId: 'transacgym',
    authDomain: 'transacgym.firebaseapp.com',
    storageBucket: 'transacgym.appspot.com',
    measurementId: 'G-J0X17STZZC',
  );
}
