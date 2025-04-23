import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edureach/features/personalisation/models/gamification.dart';
import 'package:edureach/widgets/progress_indicator.dart';
import 'package:edureach/widgets/streak_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in to view achievements')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Achievements'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('user_progress')
            .doc(userId)
            .snapshots(),
        builder: (context, progressSnapshot) {
          if (!progressSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final progressData = progressSnapshot.data!.data() as Map<String, dynamic>;
          final badges = List<String>.from(progressData['badges'] ?? []);

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('badges').snapshots(),
            builder: (context, badgesSnapshot) {
              if (!badgesSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final allBadges = badgesSnapshot.data!.docs
                  .map((doc) => Badges.fromFirestore(doc))
                  .toList();

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // XP and Level
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Progress',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          XpProgressIndicator(
                            currentXp: progressData['xp'] ?? 0,
                            xpToNextLevel: (progressData['level'] ?? 1) * 1000,
                            level: progressData['level'] ?? 1,
                          ),
                          const SizedBox(height: 16),
                          StreakWidget(
                            currentStreak: progressData['currentStreak'] ?? 0,
                            longestStreak: progressData['longestStreak'] ?? 0,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Badges
                  const Text(
                    'Your Badges',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: allBadges.length,
                    itemBuilder: (context, index) {
                      final badge = allBadges[index];
                      final hasBadge = badges.contains(badge.id);

                      return BadgeWidget(
                        badge: badge,
                        earned: hasBadge,
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class BadgeWidget extends StatelessWidget {
  final Badges badge;
  final bool earned;

  const BadgeWidget({
    super.key,
    required this.badge,
    required this.earned,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: earned ? 4 : 2,
      color: earned ? Colors.white : Colors.grey[200],
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events,
              size: 40,
              color: earned ? Colors.amber : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              badge.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: earned ? Colors.black : Colors.grey,
              ),
            ),
            if (!earned) const SizedBox(height: 4),
            if (!earned)
              Text(
                'Locked',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
      ),
    );
  }
}