import 'package:voyager/src/features/mentee/widgets/normal_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:voyager/src/features/admin/screens/courses/add_course.dart';
import 'package:voyager/src/features/admin/widgets/archived_course.dart';
import 'package:voyager/src/features/admin/widgets/active_course.dart';

class CourseList extends StatefulWidget {
  const CourseList({super.key});

  @override
  State<CourseList> createState() => _CourseListState();
}

class _CourseListState extends State<CourseList> {
  String show = '';

  @override
  void initState() {
    super.initState();
    show = 'active';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Course List',
          style: TextStyle(
            color: Colors.black,
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // NormalSearchbar widget
              SizedBox(
                height: screenHeight * 0.09,
                child: NormalSearchbar(),
              ),

              Padding(
                padding: EdgeInsets.only(
                    left: screenWidth * 0.05, right: screenWidth * 0.05),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Active Button
                    SizedBox(
                      height: screenHeight * 0.030,
                      width: screenWidth * 0.18,
                      child: Builder(
                        builder: (context) {
                          String bg = '0xFFa6a2a2';
                          String txt = '0xFF4A4A4A';

                          if (show == 'active') {
                            bg = '0xFF7eb3f7';
                            txt = '0xFF0765e0';
                          }
                          return OutlinedButton(
                            onPressed: () {
                              setState(() {
                                show = 'active';
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Color(int.parse(bg)),
                              padding: EdgeInsets.only(top: 5, bottom: 5),
                              textStyle: TextStyle(
                                fontSize: screenWidth * 0.03,
                                fontWeight: FontWeight.w600,
                              ),
                              foregroundColor: Color(int.parse(txt)),
                            ),
                            child: Text('Active'),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),

                    // Archived Button
                    SizedBox(
                      height: screenHeight * 0.030,
                      width: screenWidth * 0.18,
                      child: Builder(
                        builder: (context) {
                          String bg = '0xFFa6a2a2';
                          String txt = '0xFF4A4A4A';

                          if (show == 'archived') {
                            bg = '0xFF7eb3f7';
                            txt = '0xFF0765e0';
                          }
                          return OutlinedButton(
                            onPressed: () {
                              setState(() {
                                show = 'archived';
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Color(int.parse(bg)),
                              padding: EdgeInsets.only(top: 5, bottom: 5),
                              textStyle: TextStyle(
                                fontSize: screenWidth * 0.03,
                                fontWeight: FontWeight.w600,
                              ),
                              foregroundColor: Color(int.parse(txt)),
                            ),
                            child: Text('Archived'),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),

                    Spacer(),

                    // Add Mentor Button
                    SizedBox(
                      height: screenHeight * 0.035,
                      child: IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AddCourse()),
                          );
                        },
                        padding: EdgeInsets.all(0),
                        icon: Icon(Icons.add),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
          if (show == 'active')
            SizedBox(
                height: screenHeight * 0.70,
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                      left: screenWidth * 0.05, right: screenWidth * 0.05),
                  child: ActiveCourse(trialSize: 5),
                )),
          if (show == 'archived')
            SizedBox(
                height: screenHeight * 0.70,
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                      left: screenWidth * 0.05, right: screenWidth * 0.05),
                  child: ArchivedCourse(trialSize: 2),
                ))
        ],
      ),
    );
  }
}
