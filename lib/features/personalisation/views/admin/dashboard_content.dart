import 'package:edureach/widgets/search_input_text.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Add this package
import 'package:intl/intl.dart'; // For date formatting

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dashboard Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Dashboard Overview',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                    onPressed: () {
                      // Refresh data
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Stat Cards Row
              Row(
                children: [
                  _buildStatCard(
                    'Total Students',
                    '1,248',
                    Icons.people,
                    Colors.blue.shade700,
                    '+12% this month',
                  ),
                  const SizedBox(width: 16),
                  _buildStatCard(
                    'Active Courses',
                    '36',
                    Icons.book,
                    Colors.green.shade700,
                    '4 new this week',
                  ),
                  const SizedBox(width: 16),
                  _buildStatCard(
                    'Quiz Completion',
                    '78%',
                    Icons.quiz,
                    Colors.orange.shade700,
                    '↑ 5% from last month',
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Search Input
              SearchTextField(
                controller: _searchController,
                hintText: 'Search courses...',
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),

              const SizedBox(height: 24),

              // Charts Section
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course Engagement Chart
                  Expanded(
                    flex: 2,
                    child: _buildChartCard(
                      'Course Engagement',
                      SizedBox(
                        height: 200,
                        child: LineChart(
                          _courseEngagementData(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Category Distribution
                  Expanded(
                    flex: 1,
                    child: _buildChartCard(
                      'Course Categories',
                      SizedBox(
                        height: 200,
                        child: PieChart(
                          _courseCategoryData(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Recent Activity & Quick Actions
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recent Activity
                  Expanded(
                    flex: 2,
                    child: _buildRecentActivityCard(),
                  ),
                  const SizedBox(width: 16),
                  // Quick Actions
                  Expanded(
                    flex: 1,
                    child: _buildQuickActionsCard(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Stat Card Widget
  Widget _buildStatCard(
      String title, String value, IconData icon, Color color, String subtitle) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Chart Card Widget
  Widget _buildChartCard(String title, Widget chart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          chart,
        ],
      ),
    );
  }

  // Recent Activity Card
  Widget _buildRecentActivityCard() {
    final activities = [
      {
        'user': 'John Doe',
        'action': 'completed Science 101',
        'time': '2 hours ago'
      },
      {
        'user': 'Maria Garcia',
        'action': 'enrolled in Math for Beginners',
        'time': '3 hours ago'
      },
      {
        'user': 'Alex Smith',
        'action': 'submitted quiz: Physics Basics',
        'time': '5 hours ago'
      },
      {
        'user': 'Emma Wilson',
        'action': 'created new flashcards',
        'time': 'Yesterday'
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // View all activities
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...activities.map((activity) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.primaries[
                          activities.indexOf(activity) %
                              Colors.primaries.length],
                      child: Text(
                        activity['user']!.substring(0, 1),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style,
                              children: [
                                TextSpan(
                                  text: activity['user']! + ' ',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: activity['action']!),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            activity['time']!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // Quick Actions Card
  Widget _buildQuickActionsCard() {
    final actions = [
      {
        'title': 'Add New Course',
        'icon': Icons.add_circle,
        'color': Colors.blue
      },
      {'title': 'Create Quiz', 'icon': Icons.quiz, 'color': Colors.orange},
      {'title': 'View Reports', 'icon': Icons.bar_chart, 'color': Colors.green},
      {'title': 'Manage Users', 'icon': Icons.people, 'color': Colors.purple},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...actions.map((action) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: InkWell(
                  onTap: () {
                    // Action handler
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: action['color'] as Color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          action['icon'] as IconData,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          action['title'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  // Chart Data Methods
  LineChartData _courseEngagementData() {
    return LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              const titles = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
              if (value.toInt() < 0 || value.toInt() >= titles.length) {
                return const Text('');
              }
              return Text(
                titles[value.toInt()],
                style: const TextStyle(fontSize: 10),
              );
            },
            reservedSize: 22,
          ),
        ),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3),
            FlSpot(1, 1),
            FlSpot(2, 4),
            FlSpot(3, 2),
            FlSpot(4, 5),
            FlSpot(5, 3),
          ],
          isCurved: true,
          color: Colors.blue,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.blue.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  PieChartData _courseCategoryData() {
    return PieChartData(
      sections: [
        PieChartSectionData(
          value: 35,
          color: Colors.blue,
          title: 'Science',
          radius: 80,
          titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        PieChartSectionData(
          value: 25,
          color: Colors.green,
          title: 'Math',
          radius: 80,
          titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        PieChartSectionData(
          value: 20,
          color: Colors.orange,
          title: 'Language',
          radius: 80,
          titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        PieChartSectionData(
          value: 20,
          color: Colors.purple,
          title: 'Others',
          radius: 80,
          titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
      sectionsSpace: 0,
      centerSpaceRadius: 40,
    );
  }
}
