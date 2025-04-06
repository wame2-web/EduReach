import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:edureach/widgets/student_drawer.dart';

class FlashcardsView extends StatefulWidget {
  const FlashcardsView({super.key});

  @override
  State<FlashcardsView> createState() => _FlashcardsViewState();
}

class _FlashcardsViewState extends State<FlashcardsView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _selectedCourseId;
  List<Course> _availableCourses = [];
  bool _isLoadingCourses = true;
  bool _isFrontVisible = true;
  int _currentCardIndex = 0;
  List<Flashcard> _flashcards = [];
  bool _isLoadingFlashcards = false;

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

  Future<void> _loadFlashcards(String courseId) async {
    setState(() {
      _selectedCourseId = courseId;
      _isLoadingFlashcards = true;
      _flashcards = [];
      _currentCardIndex = 0;
      _isFrontVisible = true;
    });

    try {
      final snapshot = await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('flashcards')
          // .orderBy('createdAt')
          .get();

      setState(() {
        _flashcards = snapshot.docs.map((doc) => Flashcard.fromFirestore(doc)).toList();
        _isLoadingFlashcards = false;
      });
    } catch (e) {
      setState(() => _isLoadingFlashcards = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading flashcards: $e')),
      );
    }
  }

  Future<void> _markAsReviewed() async {
    if (_selectedCourseId == null || _flashcards.isEmpty) return;

    final flashcard = _flashcards[_currentCardIndex];
    await _firestore
        .collection('courses')
        .doc(_selectedCourseId)
        .collection('flashcards')
        .doc(flashcard.id)
        .update({
      'lastReviewed': FieldValue.serverTimestamp(),
    });
  }

  void _nextCard() {
    setState(() {
      _isFrontVisible = true;
      if (_currentCardIndex < _flashcards.length - 1) {
        _currentCardIndex++;
      } else {
        _currentCardIndex = 0; // Loop back to first card
      }
    });
  }

  void _previousCard() {
    setState(() {
      _isFrontVisible = true;
      if (_currentCardIndex > 0) {
        _currentCardIndex--;
      } else {
        _currentCardIndex = _flashcards.length - 1; // Loop to last card
      }
    });
  }

  void _toggleCardSide() {
    setState(() => _isFrontVisible = !_isFrontVisible);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Flashcards"),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (_selectedCourseId != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _loadFlashcards(_selectedCourseId!),
              tooltip: "Reload flashcards",
            ),
        ],
      ),
      // drawer: const StudentDrawer(),
      body: Column(
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
                    _loadFlashcards(courseId);
                  }
                },
              ),
            ),
          ),

          // Flashcards Content Area
          Expanded(
            child: _buildFlashcardContent(theme, isDarkMode),
          ),

          // Navigation Controls
          if (_flashcards.isNotEmpty) _buildNavigationControls(theme),
        ],
      ),
    );
  }

  Widget _buildFlashcardContent(ThemeData theme, bool isDarkMode) {
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

    if (_isLoadingFlashcards) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_selectedCourseId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_stories_rounded,
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
              "Choose a course to view its flashcards",
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      );
    }

    if (_flashcards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_add_rounded,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              "No flashcards available",
              style: TextStyle(
                fontSize: 18,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "This course doesn't have any flashcards yet",
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      );
    }

    final currentCard = _flashcards[_currentCardIndex];
    return GestureDetector(
      onTap: _toggleCardSide,
      child: Center(
        child: Card(
          elevation: 8,
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.6,
            padding: const EdgeInsets.all(24),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isFrontVisible
                  ? _buildCardSide(
                text: currentCard.frontText,
                icon: Icons.lightbulb_outline_rounded,
                color: theme.colorScheme.primary,
                isDarkMode: isDarkMode,
              )
                  : _buildCardSide(
                text: currentCard.backText,
                icon: Icons.lightbulb_rounded,
                color: theme.colorScheme.secondary,
                isDarkMode: isDarkMode,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardSide({
    required String text,
    required IconData icon,
    required Color color,
    required bool isDarkMode,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 48,
          color: color.withOpacity(0.7),
        ),
        const SizedBox(height: 24),
        Text(
          text,
          style: TextStyle(
            fontSize: 22,
            color: isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          _isFrontVisible ? "Tap to reveal answer" : "Tap to see question",
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? Colors.white70 : Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationControls(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: _previousCard,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(16),
              backgroundColor: theme.colorScheme.surface,
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              color: theme.colorScheme.onSurface,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _markAsReviewed();
              _nextCard();
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(16),
              backgroundColor: theme.colorScheme.primary,
            ),
            child: Icon(
              Icons.done_rounded,
              color: theme.colorScheme.onPrimary,
            ),
          ),
          ElevatedButton(
            onPressed: _nextCard,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(16),
              backgroundColor: theme.colorScheme.surface,
            ),
            child: Icon(
              Icons.arrow_forward_rounded,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
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

class Flashcard {
  final String id;
  final String frontText;
  final String backText;
  final List<String> tags;
  final String difficulty;
  final DateTime? lastReviewed;

  Flashcard({
    required this.id,
    required this.frontText,
    required this.backText,
    required this.tags,
    required this.difficulty,
    this.lastReviewed,
  });

  factory Flashcard.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Flashcard(
      id: doc.id,
      frontText: data['frontText'],
      backText: data['backText'],
      tags: List<String>.from(data['tags'] ?? []),
      difficulty: data['difficulty'] ?? 'medium',
      lastReviewed: data['lastReviewed']?.toDate(),
    );
  }
}