import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';

class LessonCard extends StatelessWidget {
  final String lessonId;
  final String title;
  final String? description;
  final int order;
  final VoidCallback onTap;

  const LessonCard({
    super.key,
    required this.lessonId,
    required this.title,
    this.description,
    required this.order,
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
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Text(
                  '$order',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
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
                    if (description != null && description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          description!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(FeatherIcons.moreVertical),
                onPressed: () => _showLessonOptions(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLessonOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(FeatherIcons.edit),
            title: const Text('Edit Lesson'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement edit functionality
            },
          ),
          ListTile(
            leading: const Icon(FeatherIcons.trash2, color: Colors.red),
            title: const Text('Delete Lesson', style: TextStyle(color: Colors.red)),
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
        title: const Text('Delete Lesson'),
        content: const Text('Are you sure you want to delete this lesson?'),
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