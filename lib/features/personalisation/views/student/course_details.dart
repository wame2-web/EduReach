import 'package:edureach/widgets/course_content_card.dart';
import 'package:edureach/widgets/quizzes_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edureach/features/personalisation/models/gamification.dart';


class CourseDetails extends StatefulWidget {
  final String courseId;

  const CourseDetails({
    super.key,
    required this.courseId,
  });

  @override
  State<CourseDetails> createState() => _CourseDetailsState();
}

class _CourseDetailsState extends State<CourseDetails>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isEnrolled = false;
  bool _isEnrolling = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _checkEnrollment();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkEnrollment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final courseDoc =
        await _firestore.collection('courses').doc(widget.courseId).get();
    final userIds = List<String>.from(courseDoc['userID'] ?? []);
    setState(() {
      _isEnrolled = userIds.contains(user.uid);
    });
  }

  Future<void> _handleEnrollment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _isEnrolling) return;

    setState(() => _isEnrolling = true);
    try {
      await _firestore.collection('courses').doc(widget.courseId).update({
        'userID': FieldValue.arrayUnion([user.uid])
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully enrolled in course!')),
      );
      _checkEnrollment();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enrollment failed: $e')),
      );
    } finally {
      setState(() => _isEnrolling = false);
    }
  }

  Future<void> _markLessonComplete(String lessonId, String courseId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // First check if this lesson was already marked complete
      final existingProgress = await _firestore
          .collection('lesson_progress')
          .where('userID', isEqualTo: user.uid)
          .where('courseID', isEqualTo: courseId)
          .where('lessonID', isEqualTo: lessonId)
          .limit(1)
          .get();

      if (existingProgress.docs.isEmpty) {
        await _firestore.collection('lesson_progress').add({
          'userID': user.uid,
          'courseID': courseId,
          'lessonID': lessonId,
          'isCompleted': true,
          'completedAt': FieldValue.serverTimestamp(),
        });

        // Award XP
        await _awardXp(user.uid, 50); // 50 XP per lesson

        // Update streak
        await _updateStreak(user.uid);

        // Check for badge achievements
        await _checkForBadges(user.uid);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lesson completed! +50 XP')),
        );

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You already completed this lesson')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error marking lesson complete: $e')),
      );
    }
  }

  String _getCourseImage(String? courseTitle) {
    final title = courseTitle?.toLowerCase() ?? '';

    if (title.contains('mathematics')) {
      return 'assets/maths_1.jpeg';
    } else if (title.contains('biology')) {
      return 'assets/bio_1.jpeg';
    } else if (title.contains('physics')) {
      return 'assets/physics.jpg';
    } else if (title.contains('chemistry')) {
      return 'assets/chem_2.jpeg';
    } else if (title.contains('english')) {
      return 'assets/english.jpeg';
    } else {
      return 'assets/phy.jpeg'; // Default image
    }
  }

  Future<void> _awardXp(String userId, int xp) async {
    final progressRef = _firestore.collection('user_progress').doc(userId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(progressRef);

      if (doc.exists) {
        final currentXp = doc['xp'] ?? 0;
        final currentLevel = doc['level'] ?? 1;
        final xpToNextLevel = currentLevel * 1000;
        final newXp = currentXp + xp;
        final newLevel = newXp >= xpToNextLevel ? currentLevel + 1 : currentLevel;

        transaction.update(progressRef, {
          'xp': newXp,
          'level': newLevel,
        });

        // Update leaderboard
        await _updateLeaderboard(userId, newXp, newLevel);
      } else {
        transaction.set(progressRef, {
          'userId': userId,
          'xp': xp,
          'level': 1,
          'currentStreak': 0,
          'longestStreak': 0,
          'lastActiveDate': FieldValue.serverTimestamp(),
          'badges': [],
          'learningGoals': [],
          'skills': {},
        });
      }
    });
  }

  Future<void> _updateStreak(String userId) async {
    final progressRef = _firestore.collection('user_progress').doc(userId);
    final now = DateTime.now();

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(progressRef);

      if (doc.exists) {
        final lastActiveDate = (doc['lastActiveDate'] as Timestamp).toDate();
        final currentStreak = doc['currentStreak'] ?? 0;
        final longestStreak = doc['longestStreak'] ?? 0;

        // Check if last activity was yesterday (maintain streak)
        final yesterday = DateTime(now.year, now.month, now.day - 1);
        final isConsecutiveDay = lastActiveDate.isAfter(yesterday);

        final newStreak = isConsecutiveDay ? currentStreak + 1 : 1;

        transaction.update(progressRef, {
          'currentStreak': newStreak,
          'longestStreak': newStreak > longestStreak ? newStreak : longestStreak,
          'lastActiveDate': FieldValue.serverTimestamp(),
        });

        // Award bonus XP for streaks
        if (newStreak % 3 == 0) { // Every 3 days
          await _awardXp(userId, 100);
        }
      }
    });
  }

  Future<void> _checkForBadges(String userId) async {
    final progressRef = _firestore.collection('user_progress').doc(userId);
    final badgesRef = _firestore.collection('badges');

    // Get user's completed lessons count
    final lessonsCompleted = await _firestore
        .collection('lesson_progress')
        .where('userID', isEqualTo: userId)
        .where('isCompleted', isEqualTo: true)
        .get();

    final completedCount = lessonsCompleted.docs.length;

    // Check for badges
    final badges = await badgesRef.get();

    for (final badgeDoc in badges.docs) {
      final badge = Badges.fromFirestore(badgeDoc);

      if (badge.criteria == 'complete_5_lessons' && completedCount >= 5) {
        // Award badge if not already earned
        await progressRef.update({
          'badges': FieldValue.arrayUnion([badge.id])
        });

        // Award XP for badge
        await _awardXp(userId, badge.xpReward);
      }
      // Add more badge criteria checks as needed
    }
  }

  Future<void> _updateLeaderboard(String userId, int xp, int level) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final userName = userDoc['fullName'] ?? 'Anonymous';
    final badgeCount = (await _firestore
        .collection('user_progress')
        .doc(userId)
        .get())['badges']?.length ?? 0;

    await _firestore.collection('leaderboard').doc(userId).set({
      'userId': userId,
      'userName': userName,
      'xp': xp,
      'level': level,
      'badgeCount': badgeCount,
    }, SetOptions(merge: true));
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
        stream:
            _firestore.collection('courses').doc(widget.courseId).snapshots(),
        builder: (context, courseSnapshot) {
          if (!courseSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final courseData =
              courseSnapshot.data!.data() as Map<String, dynamic>? ?? {};

          return StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('lessons')
                .where('courseID', isEqualTo: widget.courseId)
                .snapshots(),
            builder: (context, lessonsSnapshot) {
              final lessonsCount = lessonsSnapshot.hasData
                  ? lessonsSnapshot.data!.docs.length
                  : 0;

              return StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('quizzes')
                    .where('courseID', isEqualTo: widget.courseId)
                    .snapshots(),
                builder: (context, quizzesSnapshot) {
                  final quizzesCount = quizzesSnapshot.hasData
                      ? quizzesSnapshot.data!.docs.length
                      : 0;

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Updated image container with perfect fitting and enhanced styling
                          Container(
                            width: screenSizeWidth * 0.9,
                            height: screenSizeHeight * 0.3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16), // More rounded corners
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 2,
                                  spreadRadius: 1,
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  16), // Match container border radius
                              child: Image.asset(
                                _getCourseImage(courseData['title']),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.image_not_supported,
                                      size: 50),
                                ),
                              ),
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
                                        fontWeight: FontWeight.bold),
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
                                        fontWeight: FontWeight.bold),
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
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Subject Description
                          Text(
                            courseData['description'] ??
                                'No description available',
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
                                const Center(
                                    child:
                                        Text("List of lessons pdf Materials")),

                                // Quizzes Tab
                                _buildQuizzesTab(quizzesSnapshot),

                                // Feedback Tab
                                const Center(
                                    child: Text("List of lessons feedbacks")),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Enroll Button
                          Center(
                            child: GestureDetector(
                              onTap: _isEnrolled ? null : _handleEnrollment,
                              child: Container(
                                width: screenSizeWidth * 0.5,
                                height: screenSizeHeight * 0.07,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: _isEnrolled
                                      ? Colors.grey
                                      : const Color(0xFF00ADAE),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: _isEnrolling
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : Text(
                                        _isEnrolled ? "Enrolled" : "Enroll",
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
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
        final lessonDoc = lessons[index];
        final lesson = lessonDoc.data() as Map<String, dynamic>;
        return GestureDetector(
          onTap: () {
            if (_isEnrolled) {
              _markLessonComplete(lessonDoc.id, widget.courseId);
              // Navigate to lesson content here if needed
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Please enroll in the course first')),
              );
            }
          },
          child: CourseContentCard(
            title: lesson['title'] ?? 'No Title',
            lessonNumber: lesson['order'] ?? 0,
          ),
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
        return QuizzesCard(
          title: quiz['title'] ?? 'No Title',
          quizTime: quiz['quizTime'],
        );
      },
    );
  }
}
