import 'package:flutter/material.dart';

class ManageCourses extends StatefulWidget {
  const ManageCourses({super.key});

  @override
  State<ManageCourses> createState() => _ManageCoursesState();
}

class _ManageCoursesState extends State<ManageCourses> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Dashboard Content"),),

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF00ADAE),
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
