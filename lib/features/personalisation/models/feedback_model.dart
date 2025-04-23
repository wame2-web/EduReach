import 'package:cloud_firestore/cloud_firestore.dart';

class CourseFeedback {
  final String id;
  final String userId;
  final String courseId;
  final String feedbackText;
  final int rating;
  final DateTime createdAt;

  CourseFeedback({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.feedbackText,
    required this.rating,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'courseId': courseId,
      'feedbackText': feedbackText,
      'rating': rating,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory CourseFeedback.fromMap(String id, Map<String, dynamic> map) {
    return CourseFeedback(
      id: id,
      userId: map['userId'],
      courseId: map['courseId'],
      feedbackText: map['feedbackText'],
      rating: map['rating'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}