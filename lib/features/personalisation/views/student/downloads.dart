import 'package:edureach/widgets/student_drawer.dart';
import 'package:flutter/material.dart';

class Downloads extends StatefulWidget {
  const Downloads({super.key});

  @override
  State<Downloads> createState() => _DownloadsState();
}

class _DownloadsState extends State<Downloads> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<DownloadItem> _pdfDownloads = [
    DownloadItem(
      title: "Introduction to Calculus",
      fileSize: "2.4 MB",
      date: "Jan 12, 2023",
      progress: 1.0,
      icon: Icons.picture_as_pdf_rounded,
      color: Colors.red,
    ),
    DownloadItem(
      title: "Biology Chapter 5 Notes",
      fileSize: "1.8 MB",
      date: "Feb 3, 2023",
      progress: 1.0,
      icon: Icons.picture_as_pdf_rounded,
      color: Colors.red,
    ),
    DownloadItem(
      title: "Chemistry Formulas",
      fileSize: "3.2 MB",
      date: "Mar 8, 2023",
      progress: 0.65,
      icon: Icons.picture_as_pdf_rounded,
      color: Colors.red,
    ),
  ];

  final List<DownloadItem> _videoDownloads = [
    DownloadItem(
      title: "Linear Algebra Lecture",
      fileSize: "156 MB",
      date: "Jan 15, 2023",
      progress: 1.0,
      icon: Icons.video_library_rounded,
      color: Colors.blue,
    ),
    DownloadItem(
      title: "Physics Experiment Demo",
      fileSize: "89 MB",
      date: "Feb 22, 2023",
      progress: 1.0,
      icon: Icons.video_library_rounded,
      color: Colors.blue,
    ),
    DownloadItem(
      title: "History Documentary",
      fileSize: "245 MB",
      date: "Mar 5, 2023",
      progress: 0.3,
      icon: Icons.video_library_rounded,
      color: Colors.blue,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Downloads",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      drawer: const StudentDrawer(),
      body: Column(
        children: [
          // Custom Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: theme.colorScheme.primary,
              ),
              labelColor: Colors.white,
              unselectedLabelColor: isDarkMode ? Colors.white70 : Colors.black87,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: "PDF Documents"),
                Tab(text: "Video Lectures"),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // PDF Downloads Tab
                _buildDownloadsList(_pdfDownloads, theme, isDarkMode),

                // Video Downloads Tab
                _buildDownloadsList(_videoDownloads, theme, isDarkMode),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadsList(List<DownloadItem> items, ThemeData theme, bool isDarkMode) {
    return items.isEmpty
        ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.download_rounded,
            size: 64,
            color: theme.colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            "No downloads available",
            style: TextStyle(
              fontSize: 18,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Downloaded files will appear here",
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    )
        : ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildDownloadItem(item, theme, isDarkMode);
      },
    );
  }

  Widget _buildDownloadItem(DownloadItem item, ThemeData theme, bool isDarkMode) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Handle item tap
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.icon,
                      color: item.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${item.fileSize} • ${item.date}",
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? Colors.white60 : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color: isDarkMode ? Colors.white54 : Colors.grey[600],
                    ),
                    onPressed: () {
                      _showItemOptions(item);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (item.progress < 1.0)
                LinearProgressIndicator(
                  value: item.progress,
                  backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                  color: theme.colorScheme.primary,
                  minHeight: 4,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showItemOptions(DownloadItem item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.open_in_new_rounded),
                title: const Text("Open"),
                onTap: () {
                  Navigator.pop(context);
                  // Handle open action
                },
              ),
              ListTile(
                leading: const Icon(Icons.share_rounded),
                title: const Text("Share"),
                onTap: () {
                  Navigator.pop(context);
                  // Handle share action
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_rounded, color: Colors.red),
                title: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Handle delete action
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class DownloadItem {
  final String title;
  final String fileSize;
  final String date;
  final double progress;
  final IconData icon;
  final Color color;

  DownloadItem({
    required this.title,
    required this.fileSize,
    required this.date,
    required this.progress,
    required this.icon,
    required this.color,
  });
}