import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edureach/features/personalisation/views/admin/course_details.dart';
import 'package:edureach/widgets/admin_drawer.dart';
import 'package:edureach/widgets/course_card.dart';
import 'package:edureach/widgets/search_input_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ManageCourses extends StatefulWidget {
  const ManageCourses({super.key});

  @override
  State<ManageCourses> createState() => _ManageCoursesState();
}

class _ManageCoursesState extends State<ManageCourses> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _searchQuery = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {

    // Get Device Screen Size
    final double screenSizeWidth = MediaQuery.of(context).size.width;
    final double screenSizeHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Courses"),
        centerTitle: true,
      ),
      drawer: AdminDrawer(),
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: Column(
          children: [
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
            const SizedBox(height: 16),

            // Tab bar
            TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF00ADAE),
              labelColor: const Color(0xFF00ADAE),
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: "All Courses"),
                Tab(text: "My Courses"),
              ],
            ),

            const SizedBox(height: 16),

            // All courses & My courses
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [

                  // All courses grid
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('courses').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // Filter courses based on search query
                      final courses = snapshot.data!.docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final title = data['title']?.toString().toLowerCase() ?? '';
                        return title.contains(_searchQuery);
                      }).toList();

                      if (courses.isEmpty) {
                        return const Center(child: Text('No courses found'));
                      }

                      return GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: courses.length,
                        itemBuilder: (context, index) {
                          final course = courses[index];
                          final data = course.data() as Map<String, dynamic>;
                          final studentCount = (data['userID'] as List?)?.length ?? 0;

                          final (cardColor, textColor) = _getCourseColors(data['category']);

                          return CourseCard(
                            courseName: data['title'] ?? 'Untitled Course',
                            studentCount: studentCount,
                            onViewPressed: () => _viewCourseDetails(course.id),
                            containerColor: cardColor,
                            textColor: textColor,
                          );
                        },
                      );
                    },
                  ),

                  // My courses grid
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('courses').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // Get current user ID
                      final currentUserId = _auth.currentUser?.uid;
                      if (currentUserId == null) {
                        return const Center(child: Text('Please sign in to view your courses'));
                      }

                      // Filter courses where userID array contains current user's ID
                      final myCourses = snapshot.data!.docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final userIds = data['userID'] as List? ?? [];
                        return userIds.contains(currentUserId);
                      }).toList();

                      // Additional search filtering if needed
                      final filteredCourses = myCourses.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final title = data['title']?.toString().toLowerCase() ?? '';
                        return title.contains(_searchQuery);
                      }).toList();

                      if (filteredCourses.isEmpty) {
                        return const Center(child: Text('You are not enrolled in any courses'));
                      }

                      return GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: filteredCourses.length,
                        itemBuilder: (context, index) {
                          final course = filteredCourses[index];
                          final data = course.data() as Map<String, dynamic>;
                          final studentCount = (data['userID'] as List?)?.length ?? 0;

                          final (cardColor, textColor) = _getCourseColors(data['category']);

                          return CourseCard(
                            courseName: data['title'] ?? 'Untitled Course',
                            studentCount: studentCount,
                            onViewPressed: () => _viewCourseDetails(course.id),
                            containerColor: cardColor,
                            textColor: textColor,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewCourse,
        backgroundColor: const Color(0xFF00ADAE),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// Helper function to get colors based on course category
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
      default:
        return (Colors.blueGrey, Colors.white);
    }
  }

  void _viewCourseDetails(String courseId) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => AdminCourseDetails(courseId: courseId)));
  }
  void _addNewCourse() {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _descriptionController = TextEditingController();
    String _selectedCategory = 'Science'; // Default category

    final List<String> categories = [
      'Science',
      'Mathematics',
      'Technology',
      'Humanities',
      'Arts',
      'Business'
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Course'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Course Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a course title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      _selectedCategory = newValue;
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  // Create new course document
                  await _firestore.collection('courses').add({
                    'title': _titleController.text.trim(),
                    'description': _descriptionController.text.trim(),
                    'category': _selectedCategory,
                    'userID': [], // Initialize with empty student list
                    'createdAt': FieldValue.serverTimestamp(),
                    'updatedAt': FieldValue.serverTimestamp(),
                  });

                  // Close both dialogs
                  Navigator.pop(context); // Loading dialog
                  Navigator.pop(context); // Add course dialog

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Course created successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  Navigator.pop(context); // Loading dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error creating course: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00ADAE),
            ),
            child: const Text(
              'Create',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}