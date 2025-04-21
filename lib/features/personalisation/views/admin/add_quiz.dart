import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';

class AddQuizDialog extends StatefulWidget {
  final String courseId;

  const AddQuizDialog({super.key, required this.courseId});

  @override
  State<AddQuizDialog> createState() => _AddQuizDialogState();
}

class _AddQuizDialogState extends State<AddQuizDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Quiz'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  prefixIcon: Icon(FeatherIcons.book, color: Colors.grey[500]),
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(FeatherIcons.fileText, color: Colors.grey[500]),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _timeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Time Limit (minutes)',
                  prefixIcon: Icon(FeatherIcons.clock, color: Colors.grey[500]),
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
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
          onPressed: _saveQuiz,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _saveQuiz() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('quizzes').add({
        'courseID': widget.courseId,
        'title': _titleController.text,
        'description': _descController.text,
        'quizTime': int.parse(_timeController.text),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      Navigator.pop(context);
    }
  }
}