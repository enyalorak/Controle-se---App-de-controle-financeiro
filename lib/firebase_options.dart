import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: '',
    appId: '',
    messagingSenderId: '',
    projectId: '',
    storageBucket: '',
  );

  // Configuração para Android

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: '',
    appId: '',
    messagingSenderId: '',
    projectId: '',
    storageBucket: '..',
    iosBundleId: '',
  );

  // Configuração para iOS

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: '',
    appId: '',
    messagingSenderId: '',
    projectId: 'controlese2',
    authDomain: 'controlese2.firebaseapp.com',
    storageBucket: 'controlese2.firebasestorage.app',
    measurementId: '',
  );

  // Configuração para Web

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: '',
    appId: '1:448442146402:web:7022daab121c71f1047b3b',
    messagingSenderId: '448442146402',
    projectId: 'controlese2',
    authDomain: 'controlese2.firebaseapp.com',
    storageBucket: 'controlese2.firebasestorage.app',
    measurementId: 'G-TRSQRTYNZY',
  );

  // Configuração para Windows

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: '-041W88',
    appId: '',
    messagingSenderId: '448442146402',
    projectId: '',
    storageBucket: 'controlese2.firebasestorage.app',
    iosBundleId: 'com.example.controlese',
  );
}
