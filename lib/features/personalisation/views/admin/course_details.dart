import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'lesson_list.dart';
import 'quiz_list.dart';
import 'student_list.dart';

class CourseDetails extends StatefulWidget {
  final String courseId;

  const CourseDetails({
    super.key,
    required this.courseId,
  });

  @override
  State<CourseDetails> createState() => _CourseDetailsState();
}

class _CourseDetailsState extends State<CourseDetails> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('courses').doc(widget.courseId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Course Details"),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: Theme.of(context).primaryColor,
                size: 60,
              ),
            ),
          );
        }

        final courseData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        final (cardColor, textColor) = _getCourseColors(courseData['category']);

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                courseData['title'] ?? 'Course Details',
                style: const TextStyle(fontSize: 20),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              bottom: TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Theme.of(context).primaryColor,
                tabs: const [
                  Tab(text: "Lessons", icon: Icon(FeatherIcons.book)),
                  Tab(text: "Quizzes", icon: Icon(FeatherIcons.checkSquare)),
                  Tab(text: "Students", icon: Icon(FeatherIcons.users)),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                LessonList(courseId: widget.courseId),
                QuizList(courseId: widget.courseId),
                StudentList(courseId: widget.courseId),
              ],
            ),
            floatingActionButton: _getFloatingActionButton(),
          ),
        );
      },
    );
  }

  Widget? _getFloatingActionButton() {
    switch (_tabController.index) {
      case 0: // Lessons
        return FloatingActionButton(
          onPressed: () => _addLesson(context),
          child: const Icon(Icons.add),
        );
      case 1: // Quizzes
        return FloatingActionButton(
          onPressed: () => _addQuiz(context),
          child: const Icon(Icons.add),
        );
      default:
        return null;
    }
  }

  void _addLesson(BuildContext context) {
    // TODO: Implement add lesson
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add lesson functionality')),
    );
  }

  void _addQuiz(BuildContext context) {
    // TODO: Implement add quiz
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add quiz functionality')),
    );
  }

  (Color, Color) _getCourseColors(String? category) {
    switch (category?.toLowerCase()) {
      case 'science':
        return (const Color(0xFF00ADAE), Colors.white);
      case 'mathematics':
        return (Colors.green, Colors.white);
      case 'technology':
        return (Colors.purple, Colors.white);
      case 'humanities':
        return (Colors.orange, Colors.black);
      case 'arts':
        return (Colors.pink, Colors.white);
      case 'business':
        return (Colors.blue, Colors.white);
      default:
        return (Colors.blueGrey, Colors.white);
    }
  }
}