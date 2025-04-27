import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edureach/features/authentication/login.dart';
import 'package:edureach/features/personalisation/views/student/achievements.dart';
import 'package:edureach/widgets/progress_indicator.dart';
import 'package:edureach/widgets/streak_widget.dart';
import 'package:edureach/widgets/student_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late DocumentReference _userDocRef;

  bool _isEditing = false;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeUserData();
  }

  void _initializeControllers() {
    _genderController = TextEditingController();
    _emailController = TextEditingController();
    _schoolLevelController = TextEditingController();
    _schoolNameController = TextEditingController();
    _nationalityController = TextEditingController();
    _fullNameController = TextEditingController();
  }

  void _initializeUserData() {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      _userDocRef = _firestore.collection('users').doc(userId);
      _loadUserData();
    } else {
      setState(() => _isLoading = false);
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
          _isLoading = false;
        });
      }
    } catch (e) {
      _showErrorSnackbar('Error loading user data: $e');
      setState(() => _isLoading = false);
    }
  }

  // Update User details
  Future<void> _saveUserData() async {
    try {
      setState(() => _isSaving = true);
      await _userDocRef.update({
        'fullName': _fullNameController.text,
        'gender': _genderController.text,
        'schoolLevel': _schoolLevelController.text,
        'schoolName': _schoolNameController.text,
        'nationality': _nationalityController.text,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      setState(() {
        _isEditing = false;
        _isSaving = false;
      });
      _showSuccessSnackbar('Profile updated successfully!');
    } catch (e) {
      _showErrorSnackbar('Error updating profile: $e');
      setState(() => _isSaving = false);
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _genderController.dispose();
    _emailController.dispose();
    _schoolLevelController.dispose();
    _schoolNameController.dispose();
    _nationalityController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone. All your data will be permanently lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      setState(() => _isLoading = true);
      // Delete Firestore data first
      await _userDocRef.delete();

      // Delete the authentication record
      await _auth.currentUser?.delete();

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackbar('Error deleting account: $e');

      // If the error is because the user needs to reauthenticate
      if (e is FirebaseAuthException && e.code == 'requires-recent-login') {
        _showReauthenticationDialog();
      }
    }
  }

  Future<void> _showReauthenticationDialog() async {
    final passwordController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reauthentication Required'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please enter your password to confirm account deletion'),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (result != true) return;

    try {
      setState(() => _isLoading = true);
      final user = _auth.currentUser;
      final credential = EmailAuthProvider.credential(
        email: user?.email ?? '',
        password: passwordController.text,
      );

      await user?.reauthenticateWithCredential(credential);
      await _deleteAccount();
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackbar('Authentication failed: ${e.toString()}');
    } finally {
      passwordController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (_isEditing)
            IconButton(
              icon: _isSaving
                  ? const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              )
                  : const Icon(Icons.save_rounded),
              onPressed: _isSaving ? null : _saveUserData,
            ),
          IconButton(
            icon: Icon(
              _isEditing ? Icons.close_rounded : Icons.edit_rounded,
              color: _isLoading ? Colors.grey : theme.colorScheme.primary,
            ),
            onPressed: _isLoading || _isSaving
                ? null
                : () => setState(() => _isEditing = !_isEditing),
          ),
        ],
      ),
      drawer: const StudentDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(theme),

            // Profile Details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildProfileCard(theme, isDarkMode),
                  const SizedBox(height: 30),
                  _buildLogoutButton(theme),

                  _buildDeleteAccountButton(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: _auth.currentUser?.photoURL != null
                      ? Image.network(
                    _auth.currentUser!.photoURL!,
                    fit: BoxFit.cover,
                  )
                      : Icon(
                    Icons.person,
                    size: 60,
                    color: theme.colorScheme.onPrimary.withOpacity(0.8),
                  ),
                ),
              ),
              if (_isEditing)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            _fullNameController.text,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 10,
                  color: Colors.black.withOpacity(0.2),
                ),
              ],
            ),
          ),
          Text(
            _emailController.text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(ThemeData theme, bool isDarkMode) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileField(
              "Full Name",
              Icons.person_outline,
              _fullNameController,
              theme,
            ),
            const SizedBox(height: 15),
            _buildProfileField(
              "Gender",
              Icons.transgender,
              _genderController,
              theme,
            ),
            const SizedBox(height: 15),
            _buildProfileField(
              "School Level",
              Icons.school_outlined,
              _schoolLevelController,
              theme,
            ),
            const SizedBox(height: 15),
            _buildProfileField(
              "School Name",
              Icons.location_city_outlined,
              _schoolNameController,
              theme,
            ),
            const SizedBox(height: 15),
            _buildProfileField(
              "Nationality",
              Icons.flag_outlined,
              _nationalityController,
              theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(
      String label,
      IconData icon,
      TextEditingController controller,
      ThemeData theme,
      ) {
    return TextFormField(
      controller: controller,
      enabled: _isEditing,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: theme.colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: _isEditing
                ? theme.colorScheme.primary
                : Colors.grey.withOpacity(0.5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: _isEditing
                ? theme.colorScheme.primary
                : Colors.grey.withOpacity(0.5),
          ),
        ),
        filled: !_isEditing,
        fillColor: Colors.grey.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      ),
      style: TextStyle(
        color: _isEditing ? theme.colorScheme.onSurface : Colors.grey[700],
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildLogoutButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          await _auth.signOut();
          if (!mounted) return;
          await FirebaseAuth.instance.signOut();

          if(mounted) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => Login()));
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.error,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 3,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              "Logout",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGamificationSection(ThemeData theme) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('user_progress')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final progressData = snapshot.data!.data() as Map<String, dynamic>;
        final xp = progressData['xp'] ?? 0;
        final level = progressData['level'] ?? 1;
        final currentStreak = progressData['currentStreak'] ?? 0;
        final longestStreak = progressData['longestStreak'] ?? 0;
        final xpToNextLevel = level * 1000; // Example: 1000 XP per level

        return Column(
          children: [
            const SizedBox(height: 20),
            Text(
              'Your Progress',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            XpProgressIndicator(
              currentXp: xp,
              xpToNextLevel: xpToNextLevel,
              level: level,
            ),
            const SizedBox(height: 16),
            StreakWidget(
              currentStreak: currentStreak,
              longestStreak: longestStreak,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AchievementsScreen(),
                  ),
                );
              },
              child: const Text('View Achievements'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDeleteAccountButton(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: _isLoading ? null : _deleteAccount,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            side: BorderSide(color: theme.colorScheme.error),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delete_outline, color: theme.colorScheme.error),
              const SizedBox(width: 10),
              Text(
                "Delete Account",
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}