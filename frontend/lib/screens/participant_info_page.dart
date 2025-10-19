import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_menu_page.dart';

class ParticipantInfoPage extends StatefulWidget {
  final bool isEditing;
  const ParticipantInfoPage({Key? key, this.isEditing = false}) : super(key: key);

  @override
  State<ParticipantInfoPage> createState() => _ParticipantInfoPageState();
}

class _ParticipantInfoPageState extends State<ParticipantInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  String? _selectedGender;
  String? _selectedEducation;
  bool _loading = false;

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
      final snap = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (snap.exists) {
        final data = snap.data()!;
        _nameCtrl.text = (data['name'] ?? '') as String;
        _ageCtrl.text = (data['age'] ?? '').toString();

        final g = (data['gender'] ?? '').toString();
        final e = (data['education'] ?? '').toString();

        _selectedGender = ['Male', 'Female', 'Other'].contains(g) ? g : null;
        _selectedEducation = [
          'Elementary School',
          'Middle School',
          'High School',
          'University (Bachelor)',
          'Graduate School (Master or higher)',
        ].contains(e)
            ? e
            : null;

        setState(() {});
      }
    } catch (e) {
      _showErrorDialog('Failed to load profile: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final name = _nameCtrl.text.trim();
    final age = int.parse(_ageCtrl.text.trim());
    final gender = _selectedGender!;
    final education = _selectedEducation!;

    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'name': name,
      'age': age,
      'gender': gender,
      'education': education,
      'createdAt': FieldValue.serverTimestamp(),
    });

    setState(() => _loading = false);

    if (widget.isEditing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainMenuPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 60),
          child: Container(
            width: 650, // ✅ 카드 폭 키움
            padding: const EdgeInsets.all(48), // ✅ 내부 여백 확장
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 25,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.isEditing ? 'Edit Your Profile' : 'Enter Basic Information',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // ─── Name ───
                  TextFormField(
                    controller: _nameCtrl,
                    style: const TextStyle(fontSize: 18),
                    decoration: _inputDecoration('Full Name'),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Please enter your name.'
                        : null,
                  ),
                  const SizedBox(height: 24),

                  // ─── Age ───
                  TextFormField(
                    controller: _ageCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 18),
                    decoration: _inputDecoration('Age'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Please enter your age.';
                      final n = int.tryParse(v.trim());
                      if (n == null || n <= 0) return 'Enter a valid age.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // ─── Gender ───
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    style: const TextStyle(fontSize: 18, color: Colors.black87),
                    decoration: _inputDecoration('Gender'),
                    items: ['Male', 'Female', 'Other']
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedGender = v),
                    validator: (v) => v == null ? 'Please select your gender.' : null,
                  ),
                  const SizedBox(height: 24),

                  // ─── Education ───
                  DropdownButtonFormField<String>(
                    value: _selectedEducation,
                    style: const TextStyle(fontSize: 18, color: Colors.black87),
                    decoration: _inputDecoration('Education Level'),
                    items: [
                      'Elementary School',
                      'Middle School',
                      'High School',
                      'University (Bachelor)',
                      'Graduate School (Master or higher)',
                    ]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedEducation = v),
                    validator: (v) =>
                        v == null ? 'Please select your education level.' : null,
                  ),
                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF43A047),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 8,
                      ),
                      onPressed: _loading ? null : _saveProfile,
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              widget.isEditing ? 'Save Changes' : 'Next',
                              style: const TextStyle(fontSize: 20, color: Colors.white),
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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 18),
      filled: true,
      fillColor: const Color(0xFFF1F8E9),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 18, vertical: 18), // ✅ 입력창 크기 확장
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}



