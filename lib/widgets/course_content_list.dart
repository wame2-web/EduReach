import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CourseContentWidget extends StatelessWidget {
  final String courseTitle;
  final String totalDuration;
  final int totalLessons;
  final int completedLessons;
  final List<Reference> lessonMaterials;
  final VoidCallback onEnrollPressed;
  final VoidCallback? onMaterialTap;
  final Color primaryColor;

  const CourseContentWidget({
    super.key,
    required this.courseTitle,
    required this.totalDuration,
    required this.totalLessons,
    required this.completedLessons,
    required this.lessonMaterials,
    required this.onEnrollPressed,
    this.onMaterialTap,
    this.primaryColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Header
          Text(
            courseTitle,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 24),

          // Progress Indicators
          _buildProgressIndicators(),
          const Divider(height: 40),

          // Lessons Header
          Text(
            'Lessons Material',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Description • Feedback',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),

          // Lesson Materials List
          _buildMaterialsList(),
          const SizedBox(height: 32),

          // Enroll Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onEnrollPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Enroll',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildProgressItem(
          icon: Icons.timer,
          label: 'Duration',
          value: totalDuration,
          isCompleted: false,
        ),
        _buildProgressItem(
          icon: Icons.menu_book,
          label: 'Lessons',
          value: '$completedLessons/$totalLessons completed',
          isCompleted: completedLessons == totalLessons,
        ),
      ],
    );
  }

  Widget _buildProgressItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isCompleted,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isCompleted ? Colors.green : Colors.grey[700],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? Colors.green : Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialsList() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: lessonMaterials.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final material = lessonMaterials[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getFileIcon(material.name),
              color: primaryColor,
            ),
          ),
          title: Text(
            material.name,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: IconButton(
            icon: Icon(Icons.download, color: primaryColor),
            onPressed: () => _downloadFile(context, material),
          ),
          onTap: onMaterialTap ?? () => _downloadFile(context, material),
        );
      },
    );
  }

  IconData _getFileIcon(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      default:
        return Icons.insert_drive_file;
    }
  }

  Future<void> _downloadFile(BuildContext context, Reference file) async {
    try {
      final downloadUrl = await file.getDownloadURL();

      // Show download started message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloading ${file.name}...'),
          duration: const Duration(seconds: 2),
        ),
      );

      // Here you would typically:
      // 1. Download the file using a package like flutter_downloader
      // 2. Save to device storage
      // 3. Optionally open the file

      // For a complete implementation, you would need to add:
      // flutter_downloader: ^1.10.2
      // permission_handler: ^10.2.0
      // and implement proper download handling
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}