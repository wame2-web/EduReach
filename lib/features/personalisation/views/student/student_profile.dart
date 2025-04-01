import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentProfile extends StatefulWidget {
  const StudentProfile({super.key});

  @override
  State<StudentProfile> createState() => _StudentProfileState();
}

class _StudentProfileState extends State<StudentProfile> {
  late TextEditingController _genderController;
  late TextEditingController _emailController;
  late TextEditingController _schoolLevelController;
  late TextEditingController _schoolNameController;
  late TextEditingController _nationalityController;
  late TextEditingController _fullNameController;
  late TextEditingController _specialNeedsController;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late DocumentReference _userDocRef;

  bool _isEditing = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Initialize TextEditingControllers
    _genderController = TextEditingController();
    _emailController = TextEditingController();
    _schoolLevelController = TextEditingController();
    _schoolNameController = TextEditingController();
    _nationalityController = TextEditingController();
    _fullNameController = TextEditingController();
    _specialNeedsController = TextEditingController();

    // Get current user document reference
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      _userDocRef = _firestore.collection('users').doc(userId);
      _loadUserData();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _loadUserData() async {
    try {
      final docSnapshot = await _userDocRef.get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _fullNameController.text = data['fullName'] ?? '';
          _emailController.text = data['email'] ?? '';
          _genderController.text = data['gender'] ?? '';
          _schoolLevelController.text = data['schoolLevel'] ?? '';
          _schoolNameController.text = data['schoolName'] ?? '';
          _nationalityController.text = data['nationality'] ?? '';
          _specialNeedsController.text = data['specialNeeds'] ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading user data: $e')),
      );
    }
  }

  Future<void> _saveUserData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      await _userDocRef.update({
        'fullName': _fullNameController.text,
        'gender': _genderController.text,
        'schoolLevel': _schoolLevelController.text,
        'schoolName': _schoolNameController.text,
        'nationality': _nationalityController.text,
        'specialNeeds': _specialNeedsController.text,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _isEditing = false;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }

  @override
  void dispose() {
    _genderController.dispose();
    _emailController.dispose();
    _schoolLevelController.dispose();
    _schoolNameController.dispose();
    _nationalityController.dispose();
    _fullNameController.dispose();
    _specialNeedsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get Device Screen Size
    final double screenSizeWidth = MediaQuery.of(context).size.width;
    final double screenSizeHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Profile"),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _isLoading ? null : _saveUserData,
            ),
          IconButton(
            icon: Icon(_isEditing ? Icons.cancel : Icons.edit),
            onPressed: _isLoading
                ? null
                : () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            // User Image
            Container(
              width: screenSizeWidth,
              height: screenSizeHeight * 0.4,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFB7E8E9),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // user photo
                  const CircleAvatar(
                    backgroundColor: Colors.black,
                    radius: 80,
                    // backgroundImage: AssetImage("assets/user_avatar.jpeg"),
                  ),
                  // User Name
                  Text(
                    _fullNameController.text,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    _emailController.text,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // User Details
            ProfileInputField(
              label: "Full Name",
              controller: _fullNameController,
              icon: Icons.edit,
              enabled: _isEditing,
            ),
            ProfileInputField(
              label: "Gender",
              controller: _genderController,
              icon: Icons.edit,
              enabled: _isEditing,
            ),
            ProfileInputField(
              label: "School Level",
              controller: _schoolLevelController,
              icon: Icons.edit,
              enabled: _isEditing,
            ),
            ProfileInputField(
              label: "Name of School",
              controller: _schoolNameController,
              icon: Icons.edit,
              enabled: _isEditing,
            ),
            ProfileInputField(
              label: "Nationality",
              controller: _nationalityController,
              icon: Icons.edit,
              enabled: _isEditing,
            ),
            ProfileInputField(
              label: "Special Needs",
              controller: _specialNeedsController,
              icon: Icons.edit,
              enabled: _isEditing,
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool enabled;

  const ProfileInputField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 10, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty)
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: enabled,
                  cursorColor: const Color(0xFF00ADAE),
                  decoration: InputDecoration(
                    hintText: label,
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              Icon(icon, color: const Color(0xFF00ADAE)),
            ],
          ),
          Divider(thickness: 1, color: Colors.grey[300]),
        ],
      ),
    );
  }
}