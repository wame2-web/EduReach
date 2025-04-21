import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';

class AddFlashcardDialog extends StatefulWidget {
  final String courseId;

  const AddFlashcardDialog({super.key, required this.courseId});

  @override
  State<AddFlashcardDialog> createState() => _AddFlashcardDialogState();
}

class _AddFlashcardDialogState extends State<AddFlashcardDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _frontController = TextEditingController();
  final TextEditingController _backController = TextEditingController();
  String _difficulty = 'Easy';
  final List<String> _tags = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Flashcard'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _frontController,
                decoration: InputDecoration(
                  labelText: 'Front Text',
                  prefixIcon: Icon(FeatherIcons.fileText, color: Colors.grey[500]),
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _backController,
                decoration: InputDecoration(
                  labelText: 'Back Text',
                  prefixIcon: Icon(FeatherIcons.fileText, color: Colors.grey[500]),
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _difficulty,
                items: ['Easy', 'Medium', 'Hard'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _difficulty = value!),
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
          onPressed: _saveFlashcard,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _saveFlashcard() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('flashcards')
          .add({
        'frontText': _frontController.text,
        'backText': _backController.text,
        'difficulty': _difficulty,
        'tags': _tags,
        'lastReviewed': FieldValue.serverTimestamp(),
      });
      Navigator.pop(context);
    }
  }
}