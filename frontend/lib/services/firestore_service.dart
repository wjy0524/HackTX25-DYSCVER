// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  /// 로그인된 사용자의 프로필(age, gender)을 users 컬렉션에 저장
  static Future<void> saveUserProfile(int age, String gender) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('로그인된 사용자가 없습니다.');
    }

    final doc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);

    await doc.set({
      'age': age,
      'gender': gender,
      'joinedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}