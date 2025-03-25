import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileCard extends StatelessWidget {
  final String userId;
  final VoidCallback onBlockPressed;
  final VoidCallback onRemovePressed;
  final Color cardColor;

  const UserProfileCard({
    Key? key,
    required this.userId,
    required this.onBlockPressed,
    required this.onRemovePressed,
    this.cardColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading user data'));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('User not found'));
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;

        return Card(
          elevation: 4,
          color: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'User Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // User Profile Row
                _buildProfileRow(userData),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),

                // Personal Details Section
                _buildDetailItem('Name', userData['displayName'] ?? 'Not provided'),
                _buildDetailItem('Email', userData['email'] ?? 'Not provided'),
                _buildDetailItem('Gender', userData['gender'] ?? 'Not provided'),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),

                // Education Section
                _buildDetailItem('School Level', userData['schoolLevel'] ?? 'Not provided'),
                _buildDetailItem('Name of School', userData['schoolName'] ?? 'Not provided'),
                _buildDetailItem('Nationality', userData['nationality'] ?? 'Not provided'),
                const SizedBox(height: 30),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: onBlockPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Block'),
                    ),
                    ElevatedButton(
                      onPressed: onRemovePressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Remove'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileRow(Map<String, dynamic> userData) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: userData['photoUrl'] != null
              ? NetworkImage(userData['photoUrl'])
              : const AssetImage('assets/default_avatar.png') as ImageProvider,
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              userData['displayName'] ?? 'No name',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              userData['email'] ?? 'No email',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}