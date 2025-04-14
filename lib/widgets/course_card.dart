import 'package:flutter/material.dart';

class CourseCard extends StatelessWidget {
  final String courseName;
  final int studentCount;
  final VoidCallback onViewPressed;
  final Color containerColor;
  final Color textColor;

  const CourseCard({
    super.key,
    required this.courseName,
    required this.studentCount,
    required this.onViewPressed,
    this.containerColor = const Color(0xFFF3F3F3),
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {

    // Get Device Screen Size
    final double screenSizeWidth = MediaQuery.of(context).size.width;
    final double screenSizeHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            // image card
            Container(
              width: 150,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
            ),

            // course details
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // course name
                Text(
                  courseName,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // number of students enrolled
                Text(
                  '$studentCount Students',
                  style: TextStyle(
                    color: textColor.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            // view button
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: onViewPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: textColor,
                  foregroundColor: containerColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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