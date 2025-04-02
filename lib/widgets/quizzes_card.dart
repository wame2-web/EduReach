import 'package:flutter/material.dart';

class QuizzesCard extends StatelessWidget {

  final String title;
  final int quizTime;


  const QuizzesCard({
    super.key,
    required this.title,
    required this.quizTime,
  });

  @override
  Widget build(BuildContext context) {
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
            padding: EdgeInsets.only(top: 15, bottom: 15, left: 15, right: 15),
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
              "$quizTime min",
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

          // Quiz icon
          Icon(
            Icons.quiz,
            color: const Color(0xFF00ADAE),
          ),

        ],
      ),
    );
  }
}
