import 'package:edureach/features/personalisation/views/student/courses.dart';
import 'package:edureach/features/personalisation/views/student/dashboard_content.dart';
import 'package:flutter/material.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {

  // BOTTOM NAVIGATION BAR CONTROLLER
  int _selectedIndex = 0;

  // BOTTOM NAVIGATION BAR PAGES TO NAVIGATE TO
  static final List<Widget> _widgetOptions = <Widget>[
    StudentContent(), // Student Dashboard content
    StudentCourses(),  // student courses screen
   Center(child: Text("notifications"),),  // student notifications screen
    Center(child: Text("profile"),), // student profile screen
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

      body: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: _widgetOptions[
        _selectedIndex],
      ),

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
            icon: Icon(Icons.notifications),
            label: 'Notifications',
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
