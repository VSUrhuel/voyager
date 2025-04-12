import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:voyager/src/features/admin/controllers/course_controller.dart';
import 'package:voyager/src/features/admin/models/course_mentor_model.dart';
import 'package:voyager/src/features/admin/screens/courses/mentor_popup.dart';
import 'package:voyager/src/features/mentee/model/course_model.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';

class AdminCourseCard extends StatelessWidget {
  final CourseModel course;
  final VoidCallback onUpdate;
  final List<CourseMentorModel> courseMentors ;
  const AdminCourseCard({
    super.key,
    required this.course,
    required this.onUpdate,
    required this.courseMentors,
  });



  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;


    return Card(
      color: Colors.white,
      elevation: 2,
      margin: EdgeInsets.only(bottom: screenWidth * 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.001),
        child: Column(
          children: [
            //Display
            Row(
              children: [
                //Left Half
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      // Use DecorationImage
                      image: course.courseImgUrl.isEmpty 
                          ? AssetImage('assets/images/application_images/code.jpg') as ImageProvider
                          : NetworkImage(course.courseImgUrl),
                      fit: BoxFit.fitHeight,// Or BoxFit.contain, or other BoxFit options
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10), // Top left corner
                      bottomLeft: Radius.circular(10), // Bottom left corner
                    ),
                    color: Colors.black,
                  ),
                  width: screenWidth * 0.28,
                  height: screenHeight * 0.20,
                ),
                //Right Half
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10), // Top left corner
                      bottomRight: Radius.circular(10), // Bottom left corner
                    ),
                    color: Colors.grey[800],
                  ),
                  width: screenWidth * 0.46,
                  height: screenHeight * 0.20,
                  child: Column(
                    children: [
                      //Header
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              // Add Padding here
                              padding: const EdgeInsets.all(
                                  16.0), // Adjust padding values as needed
                              child: Text(
                                course.courseName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      //Details
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            //semester details

                            //Mentors details
                            SizedBox(
                              width: screenWidth * 0.05,
                            ),
                            Column(
                              children: [
                                Icon(
                                  Icons.group,
                                  color: Colors.white,
                                  size: screenWidth *
                                      0.08, // Sets the icon color to white
                                ),
                                Text(
                                  courseMentors.length.toString() + " Mentor(s)",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: screenWidth * 0.05,
                            ),
                            //Mentes details
                            Column(
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.peopleGroup,
                                  color: Colors.white,
                                  size: screenWidth * 0.08,
                                ),
                                Text(
                                  "1 Semester",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Spacer(),
                IconButton(
                  constraints: BoxConstraints(
                    minWidth: 0, 
                    minHeight: screenWidth * 0.5, 
                  ),
                  icon: PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert),
                    onSelected: (String value) async {
                      switch (value) {
                        case 'add':
                          await showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              child: MentorPopup(course: course.docId),
                            ),
                          );
                          onUpdate();
                          break;
                        case 'archive':
                          // Example: Archive the course
                          if(course.courseStatus == 'archived'){
                            await CourseController().restoreCourse(course.docId);
                          }else{
                          await CourseController().archiveCourse(course.docId);
                          }
                          onUpdate(); 
                          break;
                        case 'delete':
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirm Course Delete'),
                              content: const Text('Are you sure you want to delete this course?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => 
                                  Navigator.pop(context, true),
                                  child: const Text('Confirm'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            await CourseController().deleteCourse(course.docId);
                            onUpdate(); 
                          }
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem<String>(
                        value: 'add',
                        child: Text('Add Course Mentor'),
                      ),
                      PopupMenuItem<String>(
                        value: 'archive',
                        child: Text(course.courseStatus == 'archived' ? 'Unarchive Course' : 'Archive Course'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Delete Course', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                  onPressed: null, 
                )
              ],
            ),
            SizedBox(
              height: screenHeight * 0.01,
            ),
            //Button Section

          ],
        ),
      ),
    );
  }
}
