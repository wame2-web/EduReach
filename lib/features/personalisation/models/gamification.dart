import 'package:cloud_firestore/cloud_firestore.dart';

class UserProgress {
  final String userId;
  final int xp;
  final int level;
  final int currentStreak;
  final int longestStreak;
  final DateTime lastActiveDate;
  final List<String> badges;
  final List<LearningGoal> learningGoals;
  final Map<String, double> skills;

  UserProgress({
    required this.userId,
    required this.xp,
    required this.level,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastActiveDate,
    required this.badges,
    required this.learningGoals,
    required this.skills,
  });

  factory UserProgress.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProgress(
      userId: doc.id,
      xp: data['xp'] ?? 0,
      level: data['level'] ?? 1,
      currentStreak: data['currentStreak'] ?? 0,
      longestStreak: data['longestStreak'] ?? 0,
      lastActiveDate: (data['lastActiveDate'] as Timestamp).toDate(),
      badges: List<String>.from(data['badges'] ?? []),
      learningGoals: List<Map<String, dynamic>>.from(data['learningGoals'] ?? [])
          .map((goal) => LearningGoal.fromMap(goal))
          .toList(),
      skills: Map<String, double>.from(data['skills'] ?? {}),
    );
  }
}

class LearningGoal {
  final String id;
  final String description;
  final int target;
  final int progress;
  final DateTime deadline;
  final bool isCompleted;
  final int xpReward;

  LearningGoal({
    required this.id,
    required this.description,
    required this.target,
    required this.progress,
    required this.deadline,
    required this.isCompleted,
    required this.xpReward,
  });

  factory LearningGoal.fromMap(Map<String, dynamic> map) {
    return LearningGoal(
      id: map['id'],
      description: map['description'],
      target: map['target'],
      progress: map['progress'],
      deadline: (map['deadline'] as Timestamp).toDate(),
      isCompleted: map['isCompleted'],
      xpReward: map['xpReward'],
    );
  }
}

class Badges {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int xpReward;
  final String criteria;

  Badges({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.xpReward,
    required this.criteria,
  });

  factory Badges.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Badges(
      id: doc.id,
      name: data['name'],
      description: data['description'],
      imageUrl: data['imageUrl'],
      xpReward: data['xpReward'],
      criteria: data['criteria'],
    );
  }
}