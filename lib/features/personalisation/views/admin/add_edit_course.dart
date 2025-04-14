import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';

class AddEditCourse extends StatefulWidget {
  final String? courseId;

  const AddEditCourse({super.key, this.courseId});

  @override
  State<AddEditCourse> createState() => _AddEditCourseState();
}

class _AddEditCourseState extends State<AddEditCourse> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  String _selectedCategory = 'Science';
  bool _isLoading = false;

  final List<String> _categories = [
    'Science',
    'Mathematics',
    'Technology',
    'Humanities',
    'Arts',
    'Business'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.courseId != null) {
      _loadCourseData();
    }
  }

  Future<void> _loadCourseData() async {
    setState(() => _isLoading = true);
    final doc = await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      _titleController.text = data['title'] ?? '';
      _descriptionController.text = data['description'] ?? '';
      _durationController.text = data['duration'] ?? '';
      _selectedCategory = data['category'] ?? 'Science';
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.courseId == null ? 'Add New Course' : 'Edit Course'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Course Title',
                  prefixIcon: Icon(FeatherIcons.book, color: Colors.grey[500]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(FeatherIcons.fileText, color: Colors.grey[500]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
              TextFormField(
                controller: _durationController,
                decoration: InputDecoration(
                  labelText: 'Duration (e.g., 4 weeks)',
                  prefixIcon: Icon(FeatherIcons.clock, color: Colors.grey[500]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter course duration';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(FeatherIcons.tag, color: Colors.grey[500]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  }
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
          onPressed: _saveCourse,
          child: Text(widget.courseId == null ? 'Create' : 'Update'),
        ),
      ],
    );
  }

  Future<void> _saveCourse() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final data = {
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'duration': _durationController.text.trim(),
          'category': _selectedCategory,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (widget.courseId == null) {
          data['createdAt'] = FieldValue.serverTimestamp();
          data['userID'] = [];
          await FirebaseFirestore.instance.collection('courses').add(data);
        } else {
          await FirebaseFirestore.instance
              .collection('courses')
              .doc(widget.courseId)
              .update(data);
        }

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.courseId == null
                    ? 'Course created successfully!'
                    : 'Course updated successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }
}