import 'package:edureach/features/personalisation/views/admin/homepage.dart';
import 'package:edureach/features/personalisation/views/admin/manage_courses.dart';
import 'package:edureach/features/personalisation/views/admin/manage_users.dart';
import 'package:edureach/features/personalisation/views/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminDrawer extends StatefulWidget {
  const AdminDrawer({super.key});

  @override
  State<AdminDrawer> createState() => _AdminDrawerState();
}

class _AdminDrawerState extends State<AdminDrawer> {

  // Get current logged in user
  // final user = FirebaseAuth.instance.currentUser!;

  // Logout user
  void logoutUser() async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => Login()));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          children: [

            // User Photo
            DrawerHeader(
              child: Column(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.black,
                    radius: 45,
                    // backgroundImage: AssetImage("assets/user_avatar.jpeg"),
                  ),
                  const SizedBox(height: 5),

                  // User email
                  Text(
                    "atang@gmail.com",
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),

                ],
              ),
            ),

            // Admin Dashboard
            ListTile(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return const AdminDashboard();
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

            // Manage courses
            ListTile(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return const ManageCourses();
                  }),
                );
              },
              leading: const Icon(
                Icons.library_books_outlined,
                color: Colors.black,
              ),
              title: const Text(
                "Manage Courses",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),

            // Manage users
            ListTile(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return const ManageUsers();
                  }),
                );
              },
              leading: const Icon(
                Icons.people_alt_outlined,
                color: Colors.black,
              ),
              title: const Text(
                "Manage Users",
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
