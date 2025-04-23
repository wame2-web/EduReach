import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

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
  final TextEditingController _contentController = TextEditingController();

  File? _selectedFile;
  bool _isUploading = false;
  String? _uploadError;

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _uploadError = null;
        });
      }
    } catch (e) {
      setState(() {
        _uploadError = 'Failed to pick PDF file: ${e.toString()}';
      });
    }
  }

  Future<String?> _uploadFile() async {
    if (_selectedFile == null) return null;

    setState(() {
      _isUploading = true;
    });

    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${_selectedFile!.path.split('/').last}';
      final storageRef = FirebaseStorage.instance.ref()
          .child('course_documents')
          .child(widget.courseId)
          .child(fileName);

      final uploadTask = storageRef.putFile(
        _selectedFile!,
        SettableMetadata(contentType: 'application/pdf'),
      );

      final snapshot = await uploadTask.whenComplete(() {});
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      setState(() {
        _uploadError = 'PDF upload failed: ${e.toString()}';
      });
      return null;
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _saveLesson() async {
    if (!_formKey.currentState!.validate()) return;

    final downloadUrl = await _uploadFile();
    if (_selectedFile != null && downloadUrl == null) {
      // Upload failed but user selected a file
      return;
    }

    await FirebaseFirestore.instance.collection('lessons').add({
      'courseID': widget.courseId,
      'title': _titleController.text,
      'order': int.parse(_orderController.text),
      'videoURL': _videoController.text,
      'textContent': _contentController.text,
      'documentURL': downloadUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (mounted) Navigator.pop(context);
  }

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
              _buildFileUploadSection(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: 'Text Content',
                  prefixIcon: Icon(FeatherIcons.fileText, color: Colors.grey[500]),
                ),
                maxLines: 3,
              ),
              if (_uploadError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _uploadError!,
                    style: const TextStyle(color: Colors.red),
                  ),
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
          onPressed: _isUploading ? null : _saveLesson,
          child: _isUploading
              ? const CircularProgressIndicator()
              : const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildFileUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lesson PDF Document',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        OutlinedButton(
          onPressed: _isUploading ? null : _pickFile,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(FeatherIcons.upload, size: 16),
              const SizedBox(width: 8),
              Text(_selectedFile?.path.split('/').last ?? 'Select PDF File'),
            ],
          ),
        ),
        if (_selectedFile != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Selected: ${_selectedFile!.path.split('/').last}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
      ],
    );
  }
}