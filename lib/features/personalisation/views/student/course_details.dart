import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CourseDetails extends StatefulWidget {
  const CourseDetails({super.key});

  @override
  State<CourseDetails> createState() => _CourseDetailsState();
}

class _CourseDetailsState extends State<CourseDetails> with SingleTickerProviderStateMixin {

  // Tab bar view controller
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // Get Device Screen Size
    final double screenSizeWidth = MediaQuery.of(context).size.width;
    final double screenSizeHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Course Details",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // image container
              Container(
                width: screenSizeWidth * 0.9,
                height: screenSizeHeight * 0.3,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // Subject Title
              Text(
                "Physics",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,

                ),
              ),

              // lesson details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [

                  // Duration
                  Row(
                    children: [

                      // clock icon
                      Icon(
                        CupertinoIcons.clock_fill,
                      ),

                      // Duration text
                      Text(
                        "20h 5min",
                        style: TextStyle(
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),

                  // Number of lessons
                  Row(
                    children: [

                      // document icon
                      Icon(
                        CupertinoIcons.doc_plaintext,
                      ),

                      // Lesson text
                      Text(
                        "12 Lessons",
                        style: TextStyle(
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),

                  // Number of Quizzes
                  Row(
                    children: [

                      // Quiz icon
                      Icon(
                        Icons.quiz,
                      ),

                      // Quiz text
                      Text(
                        "5 Quizzes",
                        style: TextStyle(
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),

                ],
              ),

              SizedBox(height: 10,),

              // Subject Description
              Text(
                "This is a subject for registered secondary school students.",
                style: TextStyle(
                  color: Colors.grey.shade600
                ),
              ),

              SizedBox(height: 8,),

              // Tab bar
              TabBar(
                controller: _tabController,
                indicatorColor:  const Color(0xFFFF8E00),
                labelColor: const Color(0xFFFF8E00),
                unselectedLabelColor: const Color(0xFF414141),
                tabs: const [
                  Tab(text: "Lessons"),
                  Tab(text: "Material"),
                  Tab(text: "Quizzes"),
                  Tab(text: "Feedback"),
                ],
              ),

              // TODO: FETCH FROM DATABASE
              // All courses details
              SizedBox(
                height: screenSizeHeight * 0.3,
                child: TabBarView(
                  controller: _tabController,
                  children: [

                    // Subject Lessons
                    Center(child: Text("List of lessons pdfs")),

                    // Subject Material
                    Center(child: Text("List of lessons pdf Materials")),


                    // Subject Quizzes
                    Center(child: Text("List of lessons quizzes")),

                    // Subject Feedback
                    Center(child: Text("List of lessons feedbacks")),

                  ],
                ),
              ),

              SizedBox(height: 16,),

              // TODO: ADD STUDENT TO SUBJECT
              // Enroll Button
              Center(
                child: Container(
                  width: screenSizeWidth * 0.5,
                  height: screenSizeHeight * 0.07,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color:  const Color(0xFF00ADAE),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    "Enroll",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16,),


            ],
          ),
        ),
      ),
    );
  }
}
