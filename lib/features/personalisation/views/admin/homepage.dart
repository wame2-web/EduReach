import 'package:edureach/widgets/admin_drawer.dart';
import 'package:flutter/material.dart';


// Import classes
import 'dashboard_content.dart';
import 'manage_users.dart';
import 'manage_courses.dart';
import 'profile.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // BOTTOM NAVIGATION BAR CONTROLLER
  int _selectedIndex = 0;

  // BOTTOM NAVIGATION BAR PAGES TO NAVIGATE TO
  static final List<Widget> _widgetOptions = <Widget>[
    DashboardContent(), // Admin Dashboard content
    ManageCourses(), // Manage courses screen
    ManageUsers(), // Manage Users screen
    Profile(), // Admin profile screen
  ];

  // NAVIGATE TO SELECTED PAGE
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions[
          _selectedIndex], // Display the selected screen based on index,

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          // HOME BUTTON
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.white,
          ),

          // COURSES BUTTON
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books_outlined),
            label: 'Courses',
            backgroundColor: Colors.white,
          ),

          // USERS BUTTON
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            label: 'Users',
            backgroundColor: Colors.white,
          ),

          // PROFILE BUTTON
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
            backgroundColor: Colors.white,
          ),
        ],
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        showUnselectedLabels: true,
        onTap: _onItemTapped, // Handle tap events
      ),
    );
  }
}
