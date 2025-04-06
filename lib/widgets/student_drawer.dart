import 'package:edureach/features/authentication/login.dart';
import 'package:edureach/features/personalisation/views/student/courses.dart';
import 'package:edureach/features/personalisation/views/student/downloads.dart';
import 'package:edureach/features/personalisation/views/student/homepage.dart';
import 'package:edureach/features/personalisation/views/student/notifications.dart';
import 'package:edureach/features/personalisation/views/student/reports.dart';
import 'package:edureach/features/personalisation/views/student/student_profile.dart';
import 'package:edureach/features/personalisation/views/student/student_progress.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentDrawer extends StatefulWidget {
  const StudentDrawer({super.key});

  @override
  State<StudentDrawer> createState() => _StudentDrawerState();
}

class _StudentDrawerState extends State<StudentDrawer> {
  // Current selected index
  int _selectedIndex = 0;

  // Logout user with confirmation
  Future<void> logoutUser() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout Confirmation"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Logout",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
      ),
    );

    if (shouldLogout == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
              (route) => false,
        );
      }
    }
  }

  // Navigation items
  final List<DrawerItem> _drawerItems = [
    DrawerItem(
      title: "Dashboard",
      icon: Icons.home_rounded,
      page: const StudentDashboard(),
    ),
    DrawerItem(
      title: "Courses",
      icon: Icons.library_books_rounded,
      page: const StudentCourses(),
    ),
    DrawerItem(
      title: "My Progress",
      icon: Icons.bar_chart_rounded,
      page: const MyProgress(),
    ),
    DrawerItem(
      title: "Downloads",
      icon: Icons.download_rounded,
      page: const Downloads(),
    ),
    DrawerItem(
      title: "Notifications",
      icon: Icons.notifications_rounded,
      page: const Notifications(),
      badgeCount: 3,
    ),
    DrawerItem(
      title: "Reports",
      icon: Icons.assessment_rounded,
      page: const Reports(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return SafeArea(
      child: Drawer(
        width: MediaQuery.of(context).size.width * 0.78,
        elevation: 16,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(10)),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[900] : Colors.white,
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // User Header
              _buildUserHeader(theme, isDarkMode),
      
              // Navigation Items
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: _drawerItems.length,
                  itemBuilder: (context, index) {
                    final item = _drawerItems[index];
                    return _buildDrawerItem(
                      item: item,
                      index: index,
                      theme: theme,
                      isDarkMode: isDarkMode,
                    );
                  },
                ),
              ),
      
              // Logout Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildLogoutButton(theme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserHeader(ThemeData theme, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.only(top: 20, bottom: 20, left: 70, right: 80),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(10),
        ),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _navigateTo(const StudentProfile()),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: FirebaseAuth.instance.currentUser?.photoURL != null
                        ? Image.network(
                      FirebaseAuth.instance.currentUser!.photoURL!,
                      fit: BoxFit.cover,
                    )
                        : Icon(
                      Icons.person,
                      size: 40,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.edit,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            FirebaseAuth.instance.currentUser?.displayName ?? "John Doe",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            FirebaseAuth.instance.currentUser?.email ?? "student@example.com",
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required DrawerItem item,
    required int index,
    required ThemeData theme,
    required bool isDarkMode,
  }) {
    final isSelected = _selectedIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primary.withOpacity(0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: () {
          setState(() => _selectedIndex = index);
          _navigateTo(item.page);
        },
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.3)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            item.icon,
            color: isSelected
                ? theme.colorScheme.primary
                : isDarkMode
                ? Colors.grey[300]
                : Colors.grey[700],
            size: 24,
          ),
        ),
        title: Text(
          item.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        trailing: item.badgeCount != null
            ? Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          child: Text(
            item.badgeCount.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
            : null,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildLogoutButton(ThemeData theme) {
    return ElevatedButton.icon(
      onPressed: logoutUser,
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.error.withOpacity(0.1),
        foregroundColor: theme.colorScheme.error,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.colorScheme.error.withOpacity(0.3)),
        ),
      ),
      icon: const Icon(Icons.logout_rounded, size: 20),
      label: const Text(
        "Logout",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  void _navigateTo(Widget page) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.5, 0);
          const end = Offset.zero;
          const curve = Curves.easeOutQuart;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}

class DrawerItem {
  final String title;
  final IconData icon;
  final Widget page;
  final int? badgeCount;

  DrawerItem({
    required this.title,
    required this.icon,
    required this.page,
    this.badgeCount,
  });
}