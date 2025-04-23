import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:edureach/widgets/student_drawer.dart';

class QuizzesView extends StatefulWidget {
  const QuizzesView({super.key});

  @override
  State<QuizzesView> createState() => _QuizzesViewState();
}

class _QuizzesViewState extends State<QuizzesView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _selectedCourseId;
  List<Course> _availableCourses = [];
  bool _isLoadingCourses = true;
  List<Quiz> _quizzes = [];
  bool _isLoadingQuizzes = false;
  Quiz? _selectedQuiz;
  List<Question> _quizQuestions = [];
  bool _isTakingQuiz = false;
  int _currentQuestionIndex = 0;
  int? _selectedAnswerIndex;
  int _score = 0;
  bool _quizSubmitted = false;

  @override
  void initState() {
    super.initState();
    _loadAvailableCourses();
  }

  Future<void> _loadAvailableCourses() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final querySnapshot = await _firestore
          .collection('courses')
          .where('userID', arrayContains: userId)
          .get();

      setState(() {
        _availableCourses = querySnapshot.docs
            .map((doc) => Course.fromFirestore(doc))
            .toList();
        _isLoadingCourses = false;
      });
    } catch (e) {
      setState(() => _isLoadingCourses = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading courses: $e')),
      );
    }
  }

  Future<void> _loadQuizzes(String courseId) async {
    setState(() {
      _selectedCourseId = courseId;
      _isLoadingQuizzes = true;
      _quizzes = [];
      _selectedQuiz = null;
    });

    try {
      final snapshot = await _firestore
          .collection('quizzes')
          .where('courseID', isEqualTo: courseId)
          .get();

      setState(() {
        _quizzes = snapshot.docs.map((doc) => Quiz.fromFirestore(doc)).toList();
        _isLoadingQuizzes = false;
      });
    } catch (e) {
      setState(() => _isLoadingQuizzes = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading quizzes: $e')),
      );
    }
  }

  Future<void> _loadQuizQuestions(String quizId) async {
    setState(() {
      _isTakingQuiz = true;
      _quizQuestions = [];
      _currentQuestionIndex = 0;
      _selectedAnswerIndex = null;
      _score = 0;
      _quizSubmitted = false;
    });

    try {
      final snapshot = await _firestore
          .collection('quizzes')
          .doc(quizId)
          .collection('questions')
          .get();

      setState(() {
        _quizQuestions = snapshot.docs
            .map((doc) => Question.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading questions: $e')),
      );
      setState(() => _isTakingQuiz = false);
    }
  }

  void _selectAnswer(int index) {
    setState(() => _selectedAnswerIndex = index);
  }

  void _nextQuestion() {
    if (_selectedAnswerIndex != null) {
      // Check if answer is correct
      final currentQuestion = _quizQuestions[_currentQuestionIndex];
      if (_selectedAnswerIndex == currentQuestion.correctAnswer) {
        setState(() => _score += currentQuestion.points);
      }

      // Move to next question or finish quiz
      if (_currentQuestionIndex < _quizQuestions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _selectedAnswerIndex = null;
        });
      } else {
        _submitQuiz();
      }
    }
  }

  void _submitQuiz() {
    setState(() {
      _quizSubmitted = true;
    });
    // Here you would typically save the quiz results to Firestore
  }

  void _exitQuiz() {
    setState(() {
      _isTakingQuiz = false;
      _selectedQuiz = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isTakingQuiz ? 'Quiz: ${_selectedQuiz?.title}' : 'Quizzes'),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (_isTakingQuiz)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _exitQuiz,
              tooltip: "Exit quiz",
            ),
        ],
      ),
      drawer: const StudentDrawer(),
      body: _isTakingQuiz ? _buildQuizView(theme, isDarkMode) : _buildCourseSelectionView(theme, isDarkMode),
    );
  }

  Widget _buildCourseSelectionView(ThemeData theme, bool isDarkMode) {
    return Column(
      children: [
        // Course Selection Dropdown
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButton<String>(
              value: _selectedCourseId,
              hint: const Text("Select a course"),
              isExpanded: true,
              underline: const SizedBox(),
              items: _availableCourses.map((course) {
                return DropdownMenuItem<String>(
                  value: course.id,
                  child: Text(course.title),
                );
              }).toList(),
              onChanged: (courseId) {
                if (courseId != null) {
                  _loadQuizzes(courseId);
                }
              },
            ),
          ),
        ),

        // Quizzes List
        Expanded(
          child: _buildQuizzesContent(theme, isDarkMode),
        ),
      ],
    );
  }

  Widget _buildQuizzesContent(ThemeData theme, bool isDarkMode) {
    if (_isLoadingCourses) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_availableCourses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_rounded,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              "No available courses",
              style: TextStyle(
                fontSize: 18,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "You haven't been enrolled in any courses yet",
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      );
    }

    if (_isLoadingQuizzes) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_selectedCourseId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz_rounded,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              "Select a course",
              style: TextStyle(
                fontSize: 18,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Choose a course to view its quizzes",
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      );
    }

    if (_quizzes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              "No quizzes available",
              style: TextStyle(
                fontSize: 18,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "This course doesn't have any quizzes yet",
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _quizzes.length,
      itemBuilder: (context, index) {
        final quiz = _quizzes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              quiz.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  quiz.description,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Duration: ${quiz.quizTime} minutes",
                  style: TextStyle(
                    color: isDarkMode ? Colors.white60 : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded),
            onTap: () {
              setState(() => _selectedQuiz = quiz);
              _loadQuizQuestions(quiz.id);
            },
          ),
        );
      },
    );
  }

  Widget _buildQuizView(ThemeData theme, bool isDarkMode) {
    if (_quizQuestions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_quizSubmitted) {
      return _buildQuizResults(theme, isDarkMode);
    }

    final currentQuestion = _quizQuestions[_currentQuestionIndex];
    final totalQuestions = _quizQuestions.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / totalQuestions,
            backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
            color: theme.colorScheme.primary,
            minHeight: 8,
          ),
          const SizedBox(height: 16),

          // Question counter
          Text(
            "Question ${_currentQuestionIndex + 1} of $totalQuestions",
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),

          // Question text
          Text(
            currentQuestion.questionText,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 24),

          // Answer options
          Column(
            children: List.generate(
              currentQuestion.options.length,
                  (index) => _buildAnswerOption(
                option: currentQuestion.options[index],
                index: index,
                isSelected: _selectedAnswerIndex == index,
                isCorrect: index == currentQuestion.correctAnswer && _selectedAnswerIndex != null,
                isIncorrect: _selectedAnswerIndex == index && _selectedAnswerIndex != currentQuestion.correctAnswer,
                theme: theme,
                isDarkMode: isDarkMode,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Next button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedAnswerIndex != null ? _nextQuestion : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _currentQuestionIndex < totalQuestions - 1 ? "Next Question" : "Submit Quiz",
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOption({
    required String option,
    required int index,
    required bool isSelected,
    required bool isCorrect,
    required bool isIncorrect,
    required ThemeData theme,
    required bool isDarkMode,
  }) {
    Color backgroundColor = isDarkMode ? Colors.grey[800]! : Colors.grey[200]!;
    Color borderColor = Colors.transparent;

    if (isSelected) {
      backgroundColor = theme.colorScheme.primary.withOpacity(0.1);
      borderColor = theme.colorScheme.primary;
    }
    // if (isCorrect) {
    //   backgroundColor = Colors.green.withOpacity(0.1);
    //   borderColor = Colors.green;
    // }
    // if (isIncorrect) {
    //   backgroundColor = Colors.red.withOpacity(0.1);
    //   borderColor = Colors.red;
    // }

    return GestureDetector(
      onTap: () => _selectAnswer(index),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            color: borderColor,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          option,
          style: TextStyle(
            fontSize: 16,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildQuizResults(ThemeData theme, bool isDarkMode) {
    final totalPoints = _quizQuestions.fold(0, (sum, question) => sum + question.points);
    final percentage = (_score / totalPoints * 100).round();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Quiz Completed!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            CircularProgressIndicator(
              value: percentage / 100,
              strokeWidth: 10,
              backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
              color: percentage >= 70
                  ? Colors.green
                  : percentage >= 50
                  ? Colors.orange
                  : Colors.red,
            ),
            const SizedBox(height: 24),
            Text(
              "$percentage%",
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Score: $_score out of $totalPoints",
              style: TextStyle(
                fontSize: 18,
                color: isDarkMode ? Colors.white70 : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _exitQuiz,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Back to Quizzes"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Course {
  final String id;
  final String title;
  final String description;
  final String category;
  final String duration;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.duration,
  });

  factory Course.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Course(
      id: doc.id,
      title: data['title'],
      description: data['description'],
      category: data['category'],
      duration: data['duration'],
    );
  }
}

class Quiz {
  final String id;
  final String courseID;
  final String title;
  final String description;
  final int quizTime;

  Quiz({
    required this.id,
    required this.courseID,
    required this.title,
    required this.description,
    required this.quizTime,
  });

  factory Quiz.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Quiz(
      id: doc.id,
      courseID: data['courseID'],
      title: data['title'],
      description: data['description'],
      quizTime: data['quizTime'],
    );
  }
}

class Question {
  final String id;
  final String questionText;
  final List<String> options;
  final int correctAnswer;
  final String explanation;
  final int points;

  Question({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.points,
  });

  factory Question.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Question(
      id: doc.id,
      questionText: data['questionText'],
      options: List<String>.from(data['options']),
      correctAnswer: data['correctAnswer'],
      explanation: data['explanation'],
      points: data['points'],
    );
  }
}