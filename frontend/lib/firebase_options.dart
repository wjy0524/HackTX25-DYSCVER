// lib/firebase_options.dart

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCoBdGEJth4Zlf2iggoAGRicuFgIA4H0Dg',
    appId: '1:868486919694:web:32b1561c3cb94a20ffae5f',
    messagingSenderId: '868486919694',
    projectId: 'dyslexia-project-2025',
    authDomain: 'dyslexia-project-2025.firebaseapp.com',
    storageBucket: 'dyslexia-project-2025.firebasestorage.app',
    measurementId: 'G-GZJF73YZYQ',
  );

}