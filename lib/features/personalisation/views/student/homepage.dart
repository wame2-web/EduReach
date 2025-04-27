import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edureach/features/personalisation/views/student/courses.dart';
import 'package:edureach/features/personalisation/views/student/dashboard_content.dart';
import 'package:edureach/features/personalisation/views/student/notifications.dart';
import 'package:edureach/features/personalisation/views/student/student_profile.dart';
import 'package:edureach/widgets/student_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Stream<QuerySnapshot> _notificationsStream;

  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  static final List<Widget> _widgetOptions = <Widget>[
    const StudentContent(),
    const StudentCourses(),
    const Notifications(),
    const StudentProfile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  void initState() {
    super.initState();
    _notificationsStream = _firestore
        .collection('notifications')
        .where('userId', isEqualTo: _auth.currentUser?.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int _countUnreadNotifications(QuerySnapshot snapshot) {
    return snapshot.docs
        .where((doc) => doc['isRead'] == false)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Disable swipe
        children: _widgetOptions,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            items: [
              // HOME
              BottomNavigationBarItem(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: child,
                    );
                  },
                  child: _selectedIndex == 0
                      ? Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.home_rounded,
                              color: theme.colorScheme.primary, size: 24),
                        )
                      : const Icon(Icons.home_outlined, size: 24),
                ),
                label: 'Home',
                tooltip: 'Home',
              ),

              // COURSES
              BottomNavigationBarItem(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: _selectedIndex == 1
                      ? Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.library_books_rounded,
                              color: theme.colorScheme.primary, size: 24),
                        )
                      : const Icon(Icons.library_books_outlined, size: 24),
                ),
                label: 'Courses',
                tooltip: 'Courses',
              ),

              // NOTIFICATIONS
              BottomNavigationBarItem(
                icon: StreamBuilder<QuerySnapshot>(
                  stream: _notificationsStream,
                  builder: (context, snapshot) {
                    final unreadCount = snapshot.hasData
                        ? _countUnreadNotifications(snapshot.data!)
                        : 0;

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(scale: animation, child: child);
                          },
                          child: _selectedIndex == 2
                              ? Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.notifications_rounded,
                                color: theme.colorScheme.primary, size: 24),
                          )
                              : const Icon(Icons.notifications_outlined, size: 24),
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            right: -4,
                            top: -4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDarkMode ? Colors.grey[900]! : Colors.white,
                                  width: 2,
                                ),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Center(
                                child: Text(
                                  unreadCount > 9 ? '9+' : unreadCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                label: 'Notifications',
                tooltip: 'Notifications',
              ),

              // PROFILE
              BottomNavigationBarItem(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: _selectedIndex == 3
                      ? Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.person_rounded,
                              color: theme.colorScheme.primary, size: 24),
                        )
                      : const Icon(Icons.person_outline, size: 24),
                ),
                label: 'Profile',
                tooltip: 'Profile',
              ),
            ],
            type: BottomNavigationBarType.fixed,
            backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
            elevation: 0,
            currentIndex: _selectedIndex,
            selectedItemColor: theme.colorScheme.primary,
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
            showSelectedLabels: true,
            showUnselectedLabels: true,
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }
}
