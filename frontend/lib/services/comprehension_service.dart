// lib/services/comprehension_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/comprehension.dart';

Future<List<ComprehensionItem>> fetchComprehensionMaterial(
    int age,
    String gender,
    String nativeLanguage,
) async {
  final resp = await http.post(
    Uri.parse('http://localhost:8000/get-comprehension-material'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'age': age,
      'gender': gender,
      'native_language': nativeLanguage,
    }),
  );
  if (resp.statusCode != 200) {
    throw Exception('Failed to load comprehension material');
  }
  final data = jsonDecode(resp.body) as Map<String, dynamic>;
  return (data['comprehensions'] as List)
      .map((e) => ComprehensionItem.fromJson(e as Map<String, dynamic>))
      .toList();
}