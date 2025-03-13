import 'package:edureach/widgets/profile_input_field.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [

          // User image
          CircleAvatar(
            backgroundColor: Colors.black,
            radius: 50,
            // backgroundImage: AssetImage("assets/user_avatar.jpeg"),
          ),

          SizedBox(height: 15,),

          // User Name
          ProfileInputField(
            label: "Username",
            controller: _usernameController,
            icon: Icons.edit,
          ),

          SizedBox(height: 16,),

          // User email
          ProfileInputField(
            label: "Email",
            controller: _emailController,
            icon: Icons.edit,
          ),

          // User password
          ProfileInputField(
            label: "Password",
            controller: _emailController,
            icon: Icons.remove_red_eye,
          ),


        ],
      ),
    );
  }
}
