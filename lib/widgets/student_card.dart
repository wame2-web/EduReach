import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';

class StudentCard extends StatelessWidget {
  final String studentId;
  final String name;
  final String email;
  final VoidCallback onRemove;

  const StudentCard({
    super.key,
    required this.studentId,
    required this.name,
    required this.email,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(
            FeatherIcons.user,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(email),
        trailing: IconButton(
          icon: const Icon(FeatherIcons.trash2, color: Colors.red),
          onPressed: onRemove,
        ),
      ),
    );
  }
}