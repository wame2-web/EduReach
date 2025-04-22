// reports.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:edureach/widgets/student_drawer.dart';

class MyProgress extends StatefulWidget {
  const MyProgress({super.key});

  @override
  State<MyProgress> createState() => _MyProgressState();
}

class _MyProgressState extends State<MyProgress> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Progress')),
        body: const Center(child: Text('Please sign in to view your progress.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Progress'),
        centerTitle: true,
      ),
      drawer: const StudentDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Course Progress',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildCourseProgress(currentUser.uid),
            const SizedBox(height: 24),
            const Text(
              'Recently Completed Lessons',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildRecentLessons(currentUser.uid),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseProgress(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('courses')
          .where('userID', arrayContains: userId)
          .snapshots(),
      builder: (context, coursesSnapshot) {
        if (coursesSnapshot.hasError) {
          return Text('Error: ${coursesSnapshot.error}');
        }

        if (coursesSnapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final enrolledCourses = coursesSnapshot.data!.docs;

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: enrolledCourses.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final course = enrolledCourses[index];
            final courseId = course.id;
            final courseData = course.data() as Map<String, dynamic>;

            return FutureBuilder(
              future: Future.wait([
                _firestore.collection('lessons')
                    .where('courseID', isEqualTo: courseId)
                    .get(),
                _firestore.collection('lesson_progress')
                    .where('userID', isEqualTo: userId)
                    .where('courseID', isEqualTo: courseId)
                    .where('isCompleted', isEqualTo: true)
                    .get(),
              ]),
              builder: (context, AsyncSnapshot<List<QuerySnapshot>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListTile(
                    title: Text(courseData['title'] ?? 'Untitled Course'),
                    subtitle: const LinearProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return ListTile(
                    title: Text(courseData['title'] ?? 'Untitled Course'),
                    subtitle: const Text('Error loading progress'),
                  );
                }

                final lessonsQuery = snapshot.data![0];
                final progressQuery = snapshot.data![1];

                final totalLessons = lessonsQuery.docs.length;
                final completedLessons = progressQuery.docs.length;
                final progress = totalLessons == 0 ? 0 : (completedLessons / totalLessons * 100).round();

                return ListTile(
                  title: Text(courseData['title'] ?? 'Untitled Course'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$progress% completed ($completedLessons/$totalLessons lessons)'),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: progress / 100,
                        backgroundColor: Colors.grey[200],
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildRecentLessons(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('lesson_progress')
          .where('userID', isEqualTo: userId)
          .where('isCompleted', isEqualTo: true)
          .orderBy('completedAt', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, progressSnapshot) {
        if (progressSnapshot.hasError) {
          return Text('Error: ${progressSnapshot.error}');
        }

        if (progressSnapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final progressDocs = progressSnapshot.data!.docs;
        if (progressDocs.isEmpty) {
          return const Text('No recently completed lessons.');
        }

        final lessonIds = progressDocs.map((doc) => doc['lessonID'] as String).toList();

        return FutureBuilder<QuerySnapshot>(
          future: _firestore.collection('lessons')
              .where(FieldPath.documentId, whereIn: lessonIds)
              .get(),
          builder: (context, lessonsSnapshot) {
            if (lessonsSnapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (lessonsSnapshot.hasError) {
              return Text('Error: ${lessonsSnapshot.error}');
            }

            final lessons = lessonsSnapshot.data!.docs;
            final lessonMap = { for (var l in lessons) l.id: l.data() as Map<String, dynamic> };

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: progressDocs.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final progressDoc = progressDocs[index];
                final lessonId = progressDoc['lessonID'] as String;
                final lessonData = lessonMap[lessonId];
                final completedAt = progressDoc['completedAt'] as Timestamp;

                return ListTile(
                  title: Text(lessonData?['title'] ?? 'Unknown Lesson'),
                  subtitle: Text(
                    DateFormat.yMMMd().add_jm().format(completedAt.toDate()),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  trailing: Icon(Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary),
                );
              },
            );
          },
        );
      },
    );
  }
}