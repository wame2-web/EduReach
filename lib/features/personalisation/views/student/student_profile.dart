import 'package:flutter/material.dart';

class StudentProfile extends StatefulWidget {
  const StudentProfile({super.key});

  @override
  State<StudentProfile> createState() => _StudentProfileState();
}

class _StudentProfileState extends State<StudentProfile> {

  late TextEditingController _genderController;
  late TextEditingController _emailController;
  late TextEditingController _schoolLevelController;
  late TextEditingController _schoolNameController;
  late TextEditingController _nationalityController;

  @override
  void initState() {
    super.initState();

    // Initialize TextEditingControllers
    _genderController = TextEditingController();
    _emailController = TextEditingController();
    _schoolLevelController = TextEditingController();
    _schoolNameController = TextEditingController();
    _nationalityController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();

    _genderController.dispose();
    _emailController.dispose();
    _schoolLevelController.dispose();
    _schoolNameController.dispose();
    _nationalityController.dispose();

  }

  @override
  Widget build(BuildContext context) {

    // Get Device Screen Size
    final double screenSizeWidth = MediaQuery.of(context).size.width;
    final double screenSizeHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
        
            // User Image
            Container(
              width: screenSizeWidth,
              height: screenSizeHeight * 0.4,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey,
        
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
        
                  // user photo
                  CircleAvatar(
                    backgroundColor: Colors.black,
                    radius: 80,
                    // backgroundImage: AssetImage("assets/user_avatar.jpeg"),
                  ),
        
                  // User Name
                  Text(
                    "John Doe",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                    ),
                  )
                ],
              ),
            ),
        
            SizedBox(height: 16,),
        
            // User Details
            ProfileInputField(
              label: "Email",
              controller: _emailController,
              icon: Icons.edit,
            ),

            // Gender
            ProfileInputField(
              label: "Gender",
              controller: _genderController,
              icon: Icons.edit,
            ),

            // School Level
            ProfileInputField(
              label: "School Level",
              controller: _schoolLevelController,
              icon: Icons.edit,
            ),

            // School Name
            ProfileInputField(
              label: "Name of School",
              controller: _schoolNameController,
              icon: Icons.edit,
            ),

            // Nationality
            ProfileInputField(
              label: "Nationality",
              controller: _nationalityController,
              icon: Icons.edit,
            ),
        
          ],
        ),
      ),
    );
  }
}

class ProfileInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;

  const ProfileInputField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 10, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty)
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  cursorColor: Color(0xFF00ADAE),
                  decoration: InputDecoration(
                    hintText: label,
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              Icon(icon, color: Color(0xFF00ADAE)),
            ],
          ),
          Divider(thickness: 1, color: Colors.grey[300]),
        ],
      ),
    );
  }
}