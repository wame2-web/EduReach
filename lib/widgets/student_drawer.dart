import 'package:edureach/features/authentication/login.dart';
import 'package:edureach/features/personalisation/views/student/courses.dart';
import 'package:edureach/features/personalisation/views/student/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentDrawer extends StatefulWidget {
  const StudentDrawer({super.key});

  @override
  State<StudentDrawer> createState() => _StudentDrawerState();
}

class _StudentDrawerState extends State<StudentDrawer> {

  // Logout user
  void logoutUser() async {
    await FirebaseAuth.instance.signOut();

    if(mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => Login()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          children: [

            // TODO: FETCH DATA FROM DATABASE
            // User Photo
            DrawerHeader(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      // TODO: NAVIGATE TO STUDENT PROFILE
                    },
                    child: const CircleAvatar(
                      backgroundColor: Colors.black,
                      radius: 45,
                      // backgroundImage: AssetImage("assets/user_avatar.jpeg"),
                    ),
                  ),
                  const SizedBox(height: 5),

                  // User name
                  Text(
                    "John Doe",
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),

                ],
              ),
            ),

            // Student Dashboard
            ListTile(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return const StudentDashboard();
                  }),
                );
              },
              leading: const Icon(
                Icons.home,
                color: Colors.black,
              ),
              title: const Text(
                "Dashboard",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),

            // Student courses
            ListTile(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return const StudentCourses();
                  }),
                );
              },
              leading: const Icon(
                Icons.library_books_outlined,
                color: Colors.black,
              ),
              title: const Text(
                "Courses",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),

            // My Progress
            ListTile(
              onTap: () {

              },
              leading: const Icon(
                Icons.bar_chart,
                color: Colors.black,
              ),
              title: const Text(
                "My Progress",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),

            // Downloads
            ListTile(
              onTap: () {

              },
              leading: const Icon(
                Icons.download,
                color: Colors.black,
              ),
              title: const Text(
                "Downloads",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),

            // Notifications
            ListTile(
              onTap: () {

              },
              leading: const Icon(
                Icons.notifications,
                color: Colors.black,
              ),
              title: const Text(
                "Notifications",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),

            // Reports
            ListTile(
              onTap: () {

              },
              leading: const Icon(
                Icons.report_rounded,
                color: Colors.black,
              ),
              title: const Text(
                "Reports",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),

            // Logout
            ListTile(
              onTap: logoutUser,
              leading: const Icon(
                Icons.logout,
                color: Colors.red,
              ),
              title: const Text(
                "Logout",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.red,
                ),
              ),
            ),

          ],
        ),
      ),

    );
  }
}
