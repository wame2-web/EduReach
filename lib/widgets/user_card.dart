import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart'; // For image handling

class UserCard extends StatelessWidget {
  final String userId;
  final String displayName;
  final String userRole;
  final String? photoUrl;
  final VoidCallback? onTap;
  final Color cardColor;
  final bool showRole;

  const UserCard({
    super.key,
    required this.userId,
    required this.displayName,
    this.userRole = 'Student',
    this.photoUrl,
    this.onTap,
    this.cardColor = Colors.white,
    this.showRole = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // User Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey[200],
                backgroundImage: photoUrl != null
                    ? CachedNetworkImageProvider(photoUrl!)
                    : null,
                child: photoUrl == null
                    ? Text(
                  displayName.isNotEmpty ? displayName[0] : '?',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black54,
                  ),
                )
                    : null,
              ),
              const SizedBox(width: 16),
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (showRole) ...[
                      const SizedBox(height: 4),
                      Text(
                        userRole,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Optional action icon
              if (onTap != null)
                const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}