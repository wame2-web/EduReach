import 'package:edureach/widgets/student_drawer.dart';
import 'package:flutter/material.dart';

class Reports extends StatefulWidget {
  const Reports({super.key});

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reports"),
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
