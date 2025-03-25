import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:file_icon/file_icon.dart';

class FileCard extends StatelessWidget {
  final String fileName;
  final Reference fileReference;
  final VoidCallback? onTap;
  final String? fileSize;
  final String? uploadDate;
  final Color cardColor;

  const FileCard({
    super.key,
    required this.fileName,
    required this.fileReference,
    this.onTap,
    this.fileSize,
    this.uploadDate,
    this.cardColor = Colors.white,
  });

  String _getFileExtension() {
    return fileName.split('.').last.toLowerCase();
  }

  IconData _getFileIcon() {
    final ext = _getFileExtension();
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'mp4':
      case 'mov':
      case 'avi':
        return Icons.videocam;
      case 'mp3':
      case 'wav':
        return Icons.audiotrack;
      default:
        return Icons.insert_drive_file;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap ?? () => _downloadFile(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // File Icon with type-based color
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getFileColor().withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getFileIcon(),
                  color: _getFileColor(),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // File Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                    ),
                    if (fileSize != null || uploadDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          [fileSize, uploadDate].where((e) => e != null).join(' • '),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Download/View Button
              IconButton(
                icon: const Icon(Icons.download, color: Colors.blue),
                onPressed: () => _downloadFile(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getFileColor() {
    final ext = _getFileExtension();
    switch (ext) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      case 'ppt':
      case 'pptx':
        return Colors.orange;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Colors.purple;
      case 'mp4':
      case 'mov':
      case 'avi':
        return Colors.indigo;
      case 'mp3':
      case 'wav':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  Future<void> _downloadFile(BuildContext context) async {
    try {
      final snackBar = ScaffoldMessenger.of(context);
      final downloadUrl = await fileReference.getDownloadURL();

      // Download and cache the file
      final file = await DefaultCacheManager().getSingleFile(downloadUrl);

      snackBar.showSnackBar(
        SnackBar(
          content: Text('Downloaded ${fileReference.name}'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // You could use the 'open_file' package to open the file:
      // OpenFile.open(file.path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}