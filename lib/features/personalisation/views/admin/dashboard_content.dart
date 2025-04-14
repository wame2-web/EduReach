import 'package:edureach/features/personalisation/views/admin/manage_courses.dart';
import 'package:edureach/features/personalisation/views/admin/manage_users.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edureach/widgets/stats_card.dart';

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  // Firestore instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Statistics variables
  int totalUsers = 0;
  int activeCourses = 0;
  int totalLessons = 0;
  int totalQuizzes = 0;
  List<Map<String, dynamic>> recentActivities = [];

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    // Fetch counts in parallel
    final counts = await Future.wait([
      _firestore.collection('users').get(),
      _firestore.collection('courses').get(),
      _firestore.collection('lessons').get(),
      _firestore.collection('quizzes').get(),
    ]);

    // Get recent activities (last 5 created users and courses)
    final recentUsers = await _firestore.collection('users')
        .orderBy('createdAt', descending: true)
        .limit(2)
        .get();

    final recentCourses = await _firestore.collection('courses')
        .orderBy('createdAt', descending: true)
        .limit(3)
        .get();

    setState(() {
      totalUsers = counts[0].size;
      activeCourses = counts[1].size;
      totalLessons = counts[2].size;
      totalQuizzes = counts[3].size;

      // Prepare recent activities
      recentActivities = [
        ...recentUsers.docs.map((doc) => {
          'type': 'user',
          'data': doc.data(),
          'timestamp': doc['createdAt'],
        }),
        ...recentCourses.docs.map((doc) => {
          'type': 'course',
          'data': doc.data(),
          'timestamp': doc['createdAt'],
        }),
      ];

      // Sort activities by timestamp
      recentActivities.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
    });
  }

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final time = timestamp.toDate();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Header
          const Text(
            'Dashboard Overview',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Statistics Cards Row
          SizedBox(
            height: 130,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                StatsCard(
                  title: 'Total Users',
                  value: totalUsers.toString(),
                  icon: Icons.people,
                  color: Colors.blue,
                ),
                StatsCard(
                  title: 'Active Courses',
                  value: activeCourses.toString(),
                  icon: Icons.library_books,
                  color: Colors.green,
                ),
                StatsCard(
                  title: 'Total Lessons',
                  value: totalLessons.toString(),
                  icon: Icons.menu_book,
                  color: Colors.orange,
                ),
                StatsCard(
                  title: 'Quizzes',
                  value: totalQuizzes.toString(),
                  icon: Icons.quiz,
                  color: Colors.purple,
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Quick Actions Section
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          // Quick Actions buttons
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              _buildQuickActionButton('Manage Courses', Icons.library_add, Colors.blue, () {
                // Navigate to add course screen
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ManageCourses()));
              }),
              _buildQuickActionButton('Manage Users', Icons.people, Colors.green, () {
                // Navigate to manage users screen
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ManageUsers()));
              }),
              // _buildQuickActionButton('View Reports', Icons.analytics, Colors.orange, () {
              //   // Navigate to reports screen
              // }),
              // _buildQuickActionButton('System Settings', Icons.settings, Colors.purple, () {
              //   // Navigate to settings screen
              // }),
            ],
          ),

          const SizedBox(height: 20),

          // Recent Activities Section
          const Text(
            'Recent Activities',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          // Recent Activities list view card
          Card(
            elevation: 0,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: recentActivities.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                children: [
                  ...recentActivities.map((activity) {
                    if (activity['type'] == 'user') {
                      return Column(
                        children: [
                          _buildActivityItem(
                            'New registered user',
                            activity['data']['fullName'] ?? 'Unknown User',
                            Icons.person_add,
                            Colors.blue,
                            _formatTimestamp(activity['timestamp']),
                          ),
                          const Divider(),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          _buildActivityItem(
                            'New course added',
                            activity['data']['title'] ?? 'Untitled Course',
                            Icons.library_add,
                            Colors.green,
                            _formatTimestamp(activity['timestamp']),
                          ),
                          const Divider(),
                        ],
                      );
                    }
                  }),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

        ],
      ),
    );
  }

  Widget _buildActivityItem(
      String title, String subtitle, IconData icon, Color color, String time) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: Text(
        time,
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
    );
  }

  Widget _buildQuickActionButton(
      String text, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white),
      label: Text(text, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: onPressed,
    );
  }
}