import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edureach/features/personalisation/views/student/course_details.dart';
import 'package:edureach/widgets/course_card.dart';
import 'package:edureach/widgets/search_input_text.dart';
import 'package:edureach/widgets/student_drawer.dart';
import 'package:flutter/material.dart';

class StudentCourses extends StatefulWidget {
  const StudentCourses({super.key});

  @override
  State<StudentCourses> createState() => _StudentCoursesState();
}

class _StudentCoursesState extends State<StudentCourses>  with SingleTickerProviderStateMixin {

  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';

  // Tab bar view controller
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Courses"),
          centerTitle: true,
        ),
        drawer: StudentDrawer(),
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
                indicatorColor:  const Color(0xFF00ADAE),
                labelColor: const Color(0xFF00ADAE),
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: "All Courses"),
                  Tab(text: "My Courses"),
                ],
              ),

              SizedBox(height: 16,),

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
                              crossAxisCount: 2, // Two columns
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.7, // Adjust card aspect ratio
                            ),
                            itemCount: courses.length,
                            itemBuilder: (context, index) {
                              final course = courses[index];
                              final data = course.data() as Map<String, dynamic>;
                              final studentCount = (data['userID'] as List?)?.length ?? 0;
                
                              // Define colors based on category
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
                      Center(child: Text("List of user courses")),
                
                    ],
                ),
              ),


            ],
          ),
        ),
      ),
    );
  }

  // Helper function to get colors based on course category
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
    // Navigate to course details screen
    Navigator.push(context, MaterialPageRoute(builder: (context) => CourseDetails(courseId: courseId,)));
  }
}
