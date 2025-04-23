import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('leaderboard')
            .orderBy('xp', descending: true)
            .limit(100)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentUserId = FirebaseAuth.instance.currentUser?.uid;
          final leaders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: leaders.length,
            itemBuilder: (context, index) {
              final leader = leaders[index];
              final data = leader.data() as Map<String, dynamic>;
              final isCurrentUser = data['userId'] == currentUserId;

              return Card(
                color: isCurrentUser ? Colors.blue[50] : null,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isCurrentUser
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[700],
                    ),
                  ),
                  title: Text(data['userName']),
                  subtitle: Text('Level ${data['level']}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${data['xp']} XP',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('${data['badgeCount']} badges'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}