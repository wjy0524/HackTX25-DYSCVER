// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  /// 유저 프로필(이름/나이/성별/학력) 저장
  static Future<void> saveUserProfile({
    required String name,
    required int age,
    required String gender,
    required String education,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('로그인된 사용자가 없습니다.');

    final doc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);

    await doc.set({
      'name':      name,
      'age':       age,
      'gender':    gender,
      'education': education,
      'joinedAt':  FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}