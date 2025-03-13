import 'package:flutter/material.dart';

class ManageUsers extends StatefulWidget {
  const ManageUsers({super.key});

  @override
  State<ManageUsers> createState() => _ManageUsersState();
}

class _ManageUsersState extends State<ManageUsers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Users"),
      ),

      floatingActionButton: FloatingActionButton(
          onPressed: () {},
        backgroundColor: Colors.green,
        child: Icon(
            Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
