import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';

class AddLessonDialog extends StatefulWidget {
  final String courseId;

  const AddLessonDialog({super.key, required this.courseId});

  @override
  State<AddLessonDialog> createState() => _AddLessonDialogState();
}

class _AddLessonDialogState extends State<AddLessonDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _orderController = TextEditingController();
  final TextEditingController _videoController = TextEditingController();
  final TextEditingController _pdfController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Lesson'),
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
                controller: _orderController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Order',
                  prefixIcon: Icon(FeatherIcons.list, color: Colors.grey[500]),
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _videoController,
                decoration: InputDecoration(
                  labelText: 'Video URL',
                  prefixIcon: Icon(FeatherIcons.video, color: Colors.grey[500]),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pdfController,
                decoration: InputDecoration(
                  labelText: 'PDF URL',
                  prefixIcon: Icon(FeatherIcons.file, color: Colors.grey[500]),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: 'Text Content',
                  prefixIcon: Icon(FeatherIcons.fileText, color: Colors.grey[500]),
                ),
                maxLines: 3,
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
          onPressed: _saveLesson,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _saveLesson() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('lessons').add({
        'courseID': widget.courseId,
        'title': _titleController.text,
        'order': int.parse(_orderController.text),
        'videoURL': _videoController.text,
        'pdfURL': _pdfController.text,
        'textContent': _contentController.text,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      Navigator.pop(context);
    }
  }
}