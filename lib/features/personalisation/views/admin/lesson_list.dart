import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edureach/widgets/lesson_card.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';


class LessonList extends StatelessWidget {
  final String courseId;

  const LessonList({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('lessons')
          .where('courseID', isEqualTo: courseId)
          .orderBy('order')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
              color: Theme.of(context).primaryColor,
              size: 60,
            ),
          );
        }

        final lessons = snapshot.data!.docs;

        if (lessons.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FeatherIcons.bookOpen,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                const Text(
                  'No lessons available',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: lessons.length,
          itemBuilder: (context, index) {
            final lesson = lessons[index].data() as Map<String, dynamic>;
            return LessonCard(
              lessonId: lessons[index].id,
              title: lesson['title'] ?? 'Untitled Lesson',
              description: lesson['description'],
              order: lesson['order'] ?? 0,
              onTap: () {
                // TODO: Implement lesson detail view
              },
            );
          },
        );
      },
    );
  }
}