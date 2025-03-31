import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edureach/widgets/course_card.dart';
import 'package:edureach/widgets/search_input_text.dart';
import 'package:flutter/material.dart';

class StudentContent extends StatefulWidget {
  const StudentContent({super.key});

  @override
  State<StudentContent> createState() => _StudentContentState();
}

class _StudentContentState extends State<StudentContent> {

  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';


  @override
  Widget build(BuildContext context) {

    // Get Device Screen Size
    final double screenSizeWidth = MediaQuery.of(context).size.width;
    final double screenSizeHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 16),

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

            // In Progress container text
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // In progress text
                Text(
                  "In Progress",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                // Enroll in courses text
                Container(
                  width: screenSizeWidth ,
                  height: screenSizeHeight * 0.05,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    "Enroll in courses to keep track of your progress.",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Assessments text
            Text(
              "Assessments",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 5,),

            // Quiz, Exams,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                // Quiz
                Container(
                  width: screenSizeWidth * 0.25,
                  height: screenSizeHeight * 0.15,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),

                  child: Text("Quiz"),
                ),

                // Exams
                Container(
                  width: screenSizeWidth * 0.25,
                  height: screenSizeHeight * 0.15,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),

                  child: Text("Exams"),
                ),

                // Flashcards
                Container(
                  width: screenSizeWidth * 0.25,
                  height: screenSizeHeight * 0.15,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),

                  child: Text("Flashcards"),
                ),

              ],
            ),

            const SizedBox(height: 10),

            // My Courses text
            Text(
                "My Courses",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),


            SizedBox(height: 5,),

            // Courses Grid
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
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

                  // List of courses
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
            ),

          ],
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
    Navigator.pushNamed(context, '/course-details', arguments: courseId);
  }
}
