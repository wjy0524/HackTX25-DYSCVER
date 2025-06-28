import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class GoogleSignInApi {
  static Future<UserCredential?> login() async {
    if (kIsWeb) {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();

      return await FirebaseAuth.instance.signInWithPopup(googleProvider);
    } else {
      final googleSignIn = GoogleSignIn();
      final account = await googleSignIn.signIn();
      if (account == null) return null;

      final auth = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    }
  }

  static Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }
}

