import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'reading_speed_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_menu_page.dart';

class ParticipantInfoPage extends StatefulWidget {
  /// If true → editing mode (from Main Menu)
  /// If false → first-time registration after login
  final bool isEditing;

  const ParticipantInfoPage({
    Key? key,
    this.isEditing = false,
  }) : super(key: key);

  @override
  State<ParticipantInfoPage> createState() => _ParticipantInfoPageState();
}

class _ParticipantInfoPageState extends State<ParticipantInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();

  String? _selectedGender;
  String? _selectedEducation;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loadExistingProfile();
    }
  }

  Future<void> _loadExistingProfile() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final snap =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (snap.exists) {
        final data = snap.data()!;
        _nameCtrl.text = (data['name'] ?? '') as String;
        _ageCtrl.text = (data['age'] ?? '').toString();
        _selectedGender = data['gender'] as String?;
        _selectedEducation = data['education'] as String?;
        setState(() {});
      }
    } catch (e) {
      _showErrorDialog('Failed to load profile: $e');
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _onNext() async {
    if (!_formKey.currentState!.validate()) return;
    final name = _nameCtrl.text.trim();
    final age = int.parse(_ageCtrl.text.trim());
    final gender = _selectedGender!;
    final education = _selectedEducation!;

    try {
      await FirestoreService.saveUserProfile(
        name: name,
        age: age,
        gender: gender,
        education: education,
      );

      if (widget.isEditing) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainMenuPage()),
        );
      }
    } catch (e) {
      _showErrorDialog('Failed to save profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Center(
                    child: Text(
                      'Enter Basic Information',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF388E3C),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  TextFormField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      filled: true,
                      fillColor: const Color(0xFFF1F8E9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Please enter your name.' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _ageCtrl,
                    decoration: InputDecoration(
                      labelText: 'Age',
                      filled: true,
                      fillColor: const Color(0xFFF1F8E9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Please enter your age.';
                      }
                      final n = int.tryParse(v.trim());
                      if (n == null || n <= 0) return 'Please enter a valid age.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      filled: true,
                      fillColor: const Color(0xFFF1F8E9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: ['Male', 'Female', 'Other']
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedGender = v),
                    validator: (v) => v == null ? 'Please select your gender.' : null,
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _selectedEducation,
                    decoration: InputDecoration(
                      labelText: 'Education Level',
                      filled: true,
                      fillColor: const Color(0xFFF1F8E9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: [
                      'Elementary School',
                      'Middle School',
                      'High School',
                      'University (Bachelor)',
                      'Graduate School (Master or higher)',
                    ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => _selectedEducation = v),
                    validator: (v) => v == null ? 'Please select your education level.' : null,
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF66BB6A),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _onNext,
                      child: const Text(
                        'Next',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}