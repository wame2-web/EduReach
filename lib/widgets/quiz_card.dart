import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';

class QuizCard extends StatelessWidget {
  final String quizId;
  final String title;
  final int questionCount;
  final dynamic timeLimit;
  final VoidCallback onTap;

  const QuizCard({
    super.key,
    required this.quizId,
    required this.title,
    required this.questionCount,
    this.timeLimit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.green.withOpacity(0.1),
                child: Icon(
                  FeatherIcons.checkSquare,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '$questionCount questions',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        if (timeLimit != null) ...[
                          const SizedBox(width: 16),
                          Text(
                            '$timeLimit mins',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(FeatherIcons.moreVertical),
                onPressed: () => _showQuizOptions(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuizOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(FeatherIcons.edit),
            title: const Text('Edit Quiz'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement edit functionality
            },
          ),
          ListTile(
            leading: const Icon(FeatherIcons.trash2, color: Colors.red),
            title: const Text('Delete Quiz', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirmation(context);
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Quiz'),
        content: const Text('Are you sure you want to delete this quiz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement delete functionality
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}