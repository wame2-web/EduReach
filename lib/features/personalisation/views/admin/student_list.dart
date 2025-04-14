import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edureach/widgets/student_card.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';



class StudentList extends StatelessWidget {
  final String courseId;

  const StudentList({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('courses').doc(courseId).snapshots(),
      builder: (context, courseSnapshot) {
        if (!courseSnapshot.hasData) {
          return Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
              color: Theme.of(context).primaryColor,
              size: 60,
            ),
          );
        }

        final courseData = courseSnapshot.data!.data() as Map<String, dynamic>? ?? {};
        final studentIds = (courseData['userID'] as List?)?.cast<String>() ?? [];

        if (studentIds.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FeatherIcons.users,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                const Text(
                  'No students enrolled',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where(FieldPath.documentId, whereIn: studentIds)
              .snapshots(),
          builder: (context, studentsSnapshot) {
            if (!studentsSnapshot.hasData) {
              return Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: Theme.of(context).primaryColor,
                  size: 60,
                ),
              );
            }

            final students = studentsSnapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index].data() as Map<String, dynamic>;
                return StudentCard(
                  studentId: students[index].id,
                  name: student['fullName'] ?? 'Unknown Student',
                  email: student['email'] ?? 'No email',
                  onRemove: () => _removeStudent(context, students[index].id),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _removeStudent(BuildContext context, String studentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Student'),
        content: const Text('Are you sure you want to remove this student from the course?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance.collection('courses').doc(courseId).update({
          'userID': FieldValue.arrayRemove([studentId]),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student removed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing student: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}