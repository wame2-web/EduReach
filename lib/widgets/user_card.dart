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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Colored role indicator
              Container(
                width: 15,
                decoration: BoxDecoration(
                  color: userRole.toUpperCase() == 'STUDENT'
                      ? const Color(0xFF00ADAE)
                      : Colors.red,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 10),

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
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
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
              ),

              // Action icon
              if (onTap != null)
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Icon(Icons.delete, color: Color(0xFF414141)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
