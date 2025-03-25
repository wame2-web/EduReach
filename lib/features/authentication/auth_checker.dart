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
  final user = FirebaseAuth.instance.currentUser;
  String? userEmail;
  String userName = '';
  String userRole = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      userEmail = user?.email;
      checkUserDetails();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> checkUserDetails() async {
    if (userEmail == null || userEmail!.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .get();

      if (usersSnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDoc = usersSnapshot.docs.first;
        setState(() {
          userRole = userDoc['role'];
          isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error getting user details: $e");
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
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
        } else if (snapshot.hasData) {
          // User is logged in and role has been fetched
          if (userRole == 'student') {
            return  StudentDashboard(); // student screen
          } else if (userRole == 'admin') {
            return const AdminDashboard(); // admin screen
          } else {
            // Invalid role
            return const Login(); // register student

          }
        } else {
          // User is not logged in
          return const Login(); // register student
        }
      },
    );
  }
}