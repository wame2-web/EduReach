import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edureach/features/personalisation/views/admin/add_edit_course.dart';
import 'package:edureach/features/personalisation/views/admin/course_details.dart';
import 'package:edureach/widgets/admin_drawer.dart';
import 'package:edureach/widgets/course_card.dart';
import 'package:edureach/widgets/search_input_text.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ManageCourses extends StatefulWidget {
  const ManageCourses({super.key});

  @override
  State<ManageCourses> createState() => _ManageCoursesState();
}

class _ManageCoursesState extends State<ManageCourses> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Manage Courses",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).primaryColor,
      ),
      drawer: const AdminDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: SearchTextField(
              controller: _searchController,
              hintText: 'Search courses...',
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('courses').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FeatherIcons.alertCircle,
                          size: 48,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading courses',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: LoadingAnimationWidget.flickr(
                      leftDotColor: Theme.of(context).primaryColor,
                      rightDotColor: Colors.grey[400]!,
                      size: 100,
                    ),
                  );
                }

                final courses = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final title = data['title']?.toString().toLowerCase() ?? '';
                  final category = data['category']?.toString().toLowerCase() ?? '';
                  return title.contains(_searchQuery) || category.contains(_searchQuery);
                }).toList();

                if (courses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FeatherIcons.bookOpen,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No courses available'
                              : 'No matching courses',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    final data = course.data() as Map<String, dynamic>;
                    final studentCount = (data['userID'] as List?)?.length ?? 0;

                    final (cardColor, textColor) = _getCourseColors(data['category']);

                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CourseDetails(courseId: course.id),
                        ),
                      ),
                      child: Hero(
                        tag: 'course-${course.id}',
                        child: CourseCard(
                          courseName: data['title'] ?? 'Untitled Course',
                          // courseCategory: data['category'] ?? 'General',
                          studentCount: studentCount,
                          containerColor: cardColor,
                          textColor: textColor,
                          onViewPressed: () => _showCourseOptions(context, course.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AddEditCourse(),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Course',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _showCourseOptions(BuildContext context, String courseId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(FeatherIcons.edit, color: Colors.blue),
              title: const Text('Edit Course'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => AddEditCourse(courseId: courseId),
                );
              },
            ),
            ListTile(
              leading: const Icon(FeatherIcons.trash2, color: Colors.red),
              title: const Text('Delete Course'),
              onTap: () => _showDeleteConfirmation(context, courseId),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String courseId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this course?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _firestore.collection('courses').doc(courseId).delete();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Course deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting course: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color) _getCourseColors(String? category) {
    switch (category?.toLowerCase()) {
      case 'science':
        return (const Color(0xFF00ADAE), Colors.white);
      case 'mathematics':
        return (Colors.green, Colors.white);
      case 'technology':
        return (Colors.purple, Colors.white);
      case 'humanities':
        return (Colors.orange, Colors.black);
      case 'arts':
        return (Colors.pink, Colors.white);
      case 'business':
        return (Colors.blue, Colors.white);
      default:
        return (Colors.blueGrey, Colors.white);
    }
  }
}