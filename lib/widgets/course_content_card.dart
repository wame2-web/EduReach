import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CourseContentCard extends StatelessWidget {
  const CourseContentCard({super.key});

  @override
  Widget build(BuildContext context) {

    // Get Device Screen Size
    final double screenSizeWidth = MediaQuery.of(context).size.width;
    final double screenSizeHeight = MediaQuery.of(context).size.height;


    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFB7E8E9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [

          // Lesson number
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFB7E8E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "1",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          // Lesson pdf name
          Text(
            "Lesson_1_paper.pdf",
          ),

          // View pdf
          Icon(
              CupertinoIcons.eye,
          ),

          // Download pdf
          Icon(
            Icons.download,
          ),

        ],
      ),
    );
  }
}
