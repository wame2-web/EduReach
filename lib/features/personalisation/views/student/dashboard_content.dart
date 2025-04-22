import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edureach/features/personalisation/views/student/course_details.dart';
import 'package:edureach/features/personalisation/views/student/courses.dart';
import 'package:edureach/widgets/course_card.dart';
import 'package:edureach/widgets/search_input_text.dart';
import 'package:edureach/widgets/student_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'flashcards.dart';

import 'quiz.dart';

class StudentContent extends StatefulWidget {
  const StudentContent({super.key});

  @override
  State<StudentContent> createState() => _StudentContentState();
}

class _StudentContentState extends State<StudentContent> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';
  final PageController _pageController = PageController(viewportFraction: 0.8);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Learning',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            )),
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      drawer: const StudentDrawer(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Search Bar with improved styling
              SearchTextField(
                controller: _searchController,
                hintText: 'Search courses, topics...',
                onChanged: (value) =>
                    setState(() => _searchQuery = value.toLowerCase()),
              ),

              const SizedBox(height: 24),

              // In Progress Section
              _buildSectionHeader("In Progress", "View all", () {}),

              const SizedBox(height: 12),

              // In-Progress Content
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.05),
                      theme.colorScheme.primary.withOpacity(0.15),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.school,
                        size: 40, color: theme.colorScheme.primary),
                    const SizedBox(height: 8),
                    Text(
                      "Enroll in courses to track your progress",
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> StudentCourses()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: Text("Browse Courses",
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Assessments Section
              _buildSectionHeader("Quick Access", null, null),

              const SizedBox(height: 12),

              // Quick Access Content - Quizzes, Exams, Flashcards
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildQuickAccessItem(
                        Icons.quiz,
                        "Quizzes",
                        theme.colorScheme.secondary,
                        () => Navigator.push(context, MaterialPageRoute(builder: (context) => QuizzesView()))
                    ),
                    const SizedBox(width: 12),
                    _buildQuickAccessItem(
                        Icons.assignment, "Exams", Colors.purple, null),
                    const SizedBox(width: 12),
                    _buildQuickAccessItem(
                        Icons.library_books,
                        "Flashcards",
                        Colors.orange,
                        () => Navigator.push(context, MaterialPageRoute(builder: (context)=> FlashcardsView()))
                    ),
                    const SizedBox(width: 12),
                    _buildQuickAccessItem(
                        Icons.video_library, "Videos", Colors.blue, null),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // My Courses Section
              _buildSectionHeader("My Courses", "See all", () {}),

              const SizedBox(height: 12),

              // Enhanced Carousel with PageView
              SizedBox(
                height: 220,
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('courses').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Get current user ID
                    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
                    if (currentUserId == null) {
                      return const Center(child: Text('Please sign in to view your courses'));
                    }

                    final courses = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final title =
                          data['title']?.toString().toLowerCase() ?? '';
                      return title.contains(_searchQuery);
                    }).toList();

                    final myCourses = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final userIds = data['userID'] as List? ?? [];
                      return userIds.contains(currentUserId);
                    }).toList();

                    if (myCourses.isEmpty) {
                      return const Center(child: Text('You are not enrolled in any courses'));
                    }

                    return PageView.builder(
                      controller: _pageController,
                      itemCount: myCourses.length,
                      physics: const BouncingScrollPhysics(),
                      padEnds: false,
                      itemBuilder: (context, index) {
                        final course = myCourses[index];
                        final data = course.data() as Map<String, dynamic>;
                        final studentCount =
                            (data['userID'] as List?)?.length ?? 0;
                        final colors = _getCourseColors(data['category']);

                        return AnimatedBuilder(
                          animation: _pageController,
                          builder: (context, child) {
                            double value = 1.0;
                            if (_pageController.position.haveDimensions) {
                              value = _pageController.page! - index;
                              value = (1 - (value.abs() * 0.2)).clamp(0.8, 1.0);
                            }

                            return Transform.scale(
                              scale: value,
                              child: child,
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            child: CourseCard(
                              courseName: data['title'] ?? 'Untitled Course',
                              studentCount: studentCount,
                              onViewPressed: () =>
                                  _viewCourseDetails(course.id),
                              containerColor: colors.$1,
                              textColor: colors.$2,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
      String title, String? actionText, VoidCallback? onAction) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        if (actionText != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuickAccessItem(IconData icon, String label, Color color, Function()? onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 8),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  (Color, Color) _getCourseColors(String? category) {
    switch (category?.toLowerCase()) {
      case 'science':
        return (const Color(0xFF00ADAE), Colors.white);
      case 'mathematics':
        return (const Color(0xFF4CAF50), Colors.white);
      case 'technology':
        return (const Color(0xFF9C27B0), Colors.white);
      case 'humanities':
        return (const Color(0xFFFF9800), Colors.black);
      case 'language':
        return (const Color(0xFF2196F3), Colors.white);
      case 'business':
        return (const Color(0xFF607D8B), Colors.white);
      default:
        return (Theme.of(context).colorScheme.primary, Colors.white);
    }
  }

  void _viewCourseDetails(String courseId) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => CourseDetails(courseId: courseId)));
  }
}
