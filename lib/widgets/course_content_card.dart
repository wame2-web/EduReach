import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CourseContentCard extends StatelessWidget {

  final String title;
  final int lessonNumber;


  const CourseContentCard({
    super.key,
    required this.title,
    required this.lessonNumber,
  });

  @override
  Widget build(BuildContext context) {

    // Get Device Screen Size
    final double screenSizeWidth = MediaQuery.of(context).size.width;
    final double screenSizeHeight = MediaQuery.of(context).size.height;


    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.only(top: 10, bottom: 10,),
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
            padding: EdgeInsets.only(top: 15, bottom: 15, left: 20, right: 20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                width: 1,
                color: const Color(0xFF00ADAE),
              )
            ),
            child: Text(
              "$lessonNumber",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          // Lesson pdf name
          Center(
            child: Column(
              children: [
                Text(
                  title.length > 24 ? "${title.substring(0, 24)}..." : title,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),

              ],
            ),
          ),



          // View pdf
          // Icon(
          //     CupertinoIcons.eye,
          // ),

          // Download pdf
          Icon(
            CupertinoIcons.eye,
            color: const Color(0xFF00ADAE),
          ),

        ],
      ),
    );
  }
}
