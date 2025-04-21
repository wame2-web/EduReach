import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class FlashcardList extends StatelessWidget {
  final String courseId;

  const FlashcardList({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('flashcards')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FeatherIcons.alertCircle,
                  size: 48,
                  color: Colors.red[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading flashcards',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
              color: Theme.of(context).primaryColor,
              size: 60,
            ),
          );
        }

        final flashcards = snapshot.data!.docs;

        if (flashcards.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FeatherIcons.layers,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                const Text(
                  'No flashcards available',
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
          itemCount: flashcards.length,
          itemBuilder: (context, index) {
            final flashcard = flashcards[index].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Icon(
                  FeatherIcons.layers,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text(
                  flashcard['frontText'] ?? 'Untitled Flashcard',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(flashcard['backText'] ?? 'No back text'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Chip(
                          label: Text(flashcard['difficulty'] ?? 'Easy'),
                          backgroundColor: Colors.grey[200],
                        ),
                        const SizedBox(width: 8),
                        if (flashcard['tags'] != null)
                          Wrap(
                            spacing: 4,
                            children: (flashcard['tags'] as List<dynamic>)
                                .map((tag) => Chip(
                              label: Text(tag.toString()),
                              backgroundColor: Colors.blue[50],
                            ))
                                .toList(),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}