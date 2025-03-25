import 'package:flutter/material.dart';

class CourseCard extends StatelessWidget {
  final String courseName;
  final int studentCount;
  final VoidCallback onViewPressed;
  final Color cardColor;
  final Color textColor;

  const CourseCard({
    super.key,
    required this.courseName,
    required this.studentCount,
    required this.onViewPressed,
    this.cardColor = Colors.blue,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              courseName,
              style: TextStyle(
                color: textColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$studentCount Students',
              style: TextStyle(
                color: textColor.withOpacity(0.9),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: onViewPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: textColor,
                  foregroundColor: cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('View'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}