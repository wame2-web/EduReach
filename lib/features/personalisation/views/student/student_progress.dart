import 'package:edureach/widgets/student_drawer.dart';
import 'package:flutter/material.dart';

class MyProgress extends StatefulWidget {
  const MyProgress({super.key});

  @override
  State<MyProgress> createState() => _MyProgressState();
}

class _MyProgressState extends State<MyProgress> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Progress"),
        centerTitle: true,
      ),
      drawer: StudentDrawer(),
      body: Column(
        children: [

        ],
      ),
    );
  }
}
