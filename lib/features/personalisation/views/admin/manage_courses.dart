import 'package:edureach/widgets/search_input_text.dart';
import 'package:flutter/material.dart';

class ManageCourses extends StatefulWidget {
  const ManageCourses({super.key});

  @override
  State<ManageCourses> createState() => _ManageCoursesState();
}

class _ManageCoursesState extends State<ManageCourses> {

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [

          SearchTextField(
            controller: _searchController,
            hintText: 'Search users...',
            onChanged: (value) {
              // Handle search as user types
              print('Searching for: $value');
            },
            onSearchPressed: () {
              // Handle explicit search button press
              print('Search pressed for: ${_searchController.text}');
            },
          ),

        ],
      ),

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
