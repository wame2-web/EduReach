import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edureach/features/authentication/login.dart';
import 'package:edureach/features/personalisation/views/admin/homepage.dart';
import 'package:edureach/features/personalisation/views/student/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  User? _user;
  String? _userEmail;
  String _userRole = '';
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeAuthCheck();
  }

  Future<void> _initializeAuthCheck() async {
    try {
      _user = FirebaseAuth.instance.currentUser;

      if (_user != null) {
        _userEmail = _user?.email;
        await _fetchUserRole();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error initializing auth check: $e");
      }
      _hasError = true;
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchUserRole() async {
    if (_userEmail == null || _userEmail!.isEmpty) return;

    try {
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: _userEmail)
          .limit(1)
          .get();

      if (usersSnapshot.docs.isNotEmpty) {
        final userDoc = usersSnapshot.docs.first;
        if (mounted) {
          setState(() {
            _userRole = userDoc['role'] ?? '';
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching user role: $e");
      }
      _hasError = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_hasError) {
      // Show error screen or retry option
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Something went wrong'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _hasError = false;
                  });
                  _initializeAuthCheck();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final user = snapshot.data;
        if (user != null) {
          // User is logged in
          switch (_userRole) {
            case 'student':
              return const StudentDashboard();
            case 'admin':
              return const AdminDashboard();
            default:
            // Invalid role or role not found
              FirebaseAuth.instance.signOut(); // Force logout for invalid roles
              return const Login();
          }
        } else {
          // User is not logged in
          return const Login();
        }
      },
    );
  }
}