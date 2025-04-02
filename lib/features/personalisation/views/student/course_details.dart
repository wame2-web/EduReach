import 'package:edureach/widgets/course_content_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CourseDetails extends StatefulWidget {
  final String courseId;

  const CourseDetails({
    super.key,
    required this.courseId,
  });

  @override
  State<CourseDetails> createState() => _CourseDetailsState();
}

class _CourseDetailsState extends State<CourseDetails> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenSizeWidth = MediaQuery.of(context).size.width;
    final double screenSizeHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Course Details",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('courses').doc(widget.courseId).snapshots(),
        builder: (context, courseSnapshot) {
          if (!courseSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final courseData = courseSnapshot.data!.data() as Map<String, dynamic>? ?? {};

          return StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('lessons').where('courseID', isEqualTo: widget.courseId).snapshots(),
            builder: (context, lessonsSnapshot) {
              final lessonsCount = lessonsSnapshot.hasData ? lessonsSnapshot.data!.docs.length : 0;

              return StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('quizzes').where('courseID', isEqualTo: widget.courseId).snapshots(),
                builder: (context, quizzesSnapshot) {
                  final quizzesCount = quizzesSnapshot.hasData ? quizzesSnapshot.data!.docs.length : 0;

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // image container
                          Container(
                            width: screenSizeWidth * 0.9,
                            height: screenSizeHeight * 0.3,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),

                          // Course Title
                          Text(
                            courseData['title'] ?? 'No Title',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                            ),
                          ),

                          // lesson details
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [

                              // Duration
                              Row(
                                children: [
                                  // clock icon
                                  const Icon(CupertinoIcons.clock_fill),
                                  // Duration text
                                  Text(
                                    courseData['duration'] ?? 'No Duration',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ],
                              ),

                              // Number of lessons
                              Row(
                                children: [
                                  // document icon
                                  const Icon(CupertinoIcons.doc_plaintext),
                                  // Lesson text
                                  Text(
                                    "$lessonsCount Lessons",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ],
                              ),

                              // Number of Quizzes
                              Row(
                                children: [
                                  // Quiz icon
                                  const Icon(Icons.quiz),
                                  // Quiz text
                                  Text(
                                    "$quizzesCount Quizzes",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Subject Description
                          Text(
                            courseData['description'] ?? 'No description available',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Tab bar
                          TabBar(
                            controller: _tabController,
                            indicatorColor: const Color(0xFFFF8E00),
                            labelColor: const Color(0xFFFF8E00),
                            unselectedLabelColor: const Color(0xFF414141),
                            tabs: const [
                              Tab(text: "Lessons"),
                              Tab(text: "Material"),
                              Tab(text: "Quizzes"),
                              Tab(text: "Feedback"),
                            ],
                          ),

                          // Tab content
                          SizedBox(
                            height: screenSizeHeight * 0.3,
                            child: TabBarView(
                              controller: _tabController,
                              children: [

                                // Lessons Tab
                                _buildLessonsTab(lessonsSnapshot),

                                // Material Tab
                                const Center(child: Text("List of lessons pdf Materials")),

                                // Quizzes Tab
                                _buildQuizzesTab(quizzesSnapshot),

                                // Feedback Tab
                                const Center(child: Text("List of lessons feedbacks")),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Enroll Button
                          Center(
                            child: Container(
                              width: screenSizeWidth * 0.5,
                              height: screenSizeHeight * 0.07,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFF00ADAE),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: const Text(
                                "Enroll",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLessonsTab(AsyncSnapshot<QuerySnapshot> snapshot) {
    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }

    final lessons = snapshot.data!.docs;

    if (lessons.isEmpty) {
      return const Center(child: Text("No lessons available"));
    }

    return ListView.builder(
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index].data() as Map<String, dynamic>;
        return CourseContentCard(
          title: lesson['title'] ?? 'No Title',
          lessonNumber: lesson['order'] ?? 0,

        );
      },
    );
  }

  Widget _buildQuizzesTab(AsyncSnapshot<QuerySnapshot> snapshot) {
    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }

    final quizzes = snapshot.data!.docs;

    if (quizzes.isEmpty) {
      return const Center(child: Text("No quizzes available"));
    }

    return ListView.builder(
      itemCount: quizzes.length,
      itemBuilder: (context, index) {
        final quiz = quizzes[index].data() as Map<String, dynamic>;
        return ListTile(
          title: Text(quiz['title'] ?? 'No Title'),
          subtitle: Text(quiz['description'] ?? 'No Description'),
          trailing: Text("${quiz['quizTime'] ?? '?'} min"),
        );
      },
    );
  }
}