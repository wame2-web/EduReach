import 'package:edureach/widgets/student_drawer.dart';
import 'package:flutter/material.dart';

class Downloads extends StatefulWidget {
  const Downloads({super.key});

  @override
  State<Downloads> createState() => _DownloadsState();
}

class _DownloadsState extends State<Downloads> with SingleTickerProviderStateMixin {

  // Tab bar view controller
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();

    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Downloads"),
        centerTitle: true,
      ),
      drawer: StudentDrawer(),
      body: Column(
        children: [

          // Tab bar
          TabBar(
            controller: _tabController,
            indicatorColor:  const Color(0xFF00ADAE),
            labelColor: const Color(0xFF00ADAE),
            unselectedLabelColor: Colors.black,
            tabs: const [
              Tab(text: "PDF's"),
              Tab(text: "Videos"),
            ],
          ),

          SizedBox(height: 16,),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [

                // All downloaded pdfs
                Center(child: Text("List of pdfs")),

                // All downloaded videos
                Center(child: Text("List of videos")),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
