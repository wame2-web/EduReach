import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edureach/widgets/quiz_card.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';


class QuizList extends StatelessWidget {
  final String courseId;

  const QuizList({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('quizzes')
          .where('courseID', isEqualTo: courseId)
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

        final quizzes = snapshot.data!.docs;

        if (quizzes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FeatherIcons.checkSquare,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                const Text(
                  'No quizzes available',
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
          itemCount: quizzes.length,
          itemBuilder: (context, index) {
            final quiz = quizzes[index].data() as Map<String, dynamic>;
            return QuizCard(
              quizId: quizzes[index].id,
              title: quiz['title'] ?? 'Untitled Quiz',
              questionCount: (quiz['questions'] as List?)?.length ?? 0,
              timeLimit: quiz['quizTime'],
              onTap: () {
                // TODO: Implement quiz detail view
              },
            );
          },
        );
      },
    );
  }
}