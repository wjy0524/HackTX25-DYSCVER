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
    apiKey: 'AIzaSyDeNaGZkya_rBNR4CicAbZ167bSr5hOjTk',
    appId: '1:77545072676:web:f87abbec40ac5f0b4450b1',
    messagingSenderId: '77545072676',
    projectId: 'dyslexia-project-isaacch-a33a0',
    authDomain: 'dyslexia-project-isaacch-a33a0.firebaseapp.com',
    storageBucket: 'dyslexia-project-isaacch-a33a0.firebasestorage.app',
    measurementId: 'G-3445ZQ1T7D',
  );

}