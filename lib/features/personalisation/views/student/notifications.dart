import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:edureach/widgets/student_drawer.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Stream<QuerySnapshot> _notificationsStream;

  @override
  void initState() {
    super.initState();
    _notificationsStream = _firestore
        .collection('notifications')
        .where('userId', isEqualTo: _auth.currentUser?.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> _markAsRead(String notificationId) async {
    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        centerTitle: true,
      ),
      drawer: const StudentDrawer(),
      body: StreamBuilder<QuerySnapshot>(
        stream: _notificationsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No notifications yet'));
          }

          // Separate notifications into read and unread
          final unreadNotifications = snapshot.data!.docs
              .where((doc) => doc['isRead'] == false)
              .toList();
          final readNotifications = snapshot.data!.docs
              .where((doc) => doc['isRead'] == true)
              .toList();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (unreadNotifications.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'New',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  ...unreadNotifications.map((doc) => _buildNotificationCard(doc, false)),
                ],
                if (readNotifications.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Earlier',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  ...readNotifications.map((doc) => _buildNotificationCard(doc, true)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(DocumentSnapshot doc, bool isRead) {
    final data = doc.data() as Map<String, dynamic>;
    final timestamp = data['createdAt'] as Timestamp;
    final dateTime = timestamp.toDate();
    final formattedDate = DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isRead ? Colors.grey[100] : Colors.blue[50],
      child: InkWell(
        onTap: () {
          if (!isRead) {
            _markAsRead(doc.id);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Notification message
              Text(
                data['message'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // Notification Date
              Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),

              // is the message read or not
              if (!isRead) ...[
                const SizedBox(height: 8),
                const Text(
                  'Unread',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}