import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:voyager/src/features/mentee/model/course_model.dart';

class AdminCourseCard extends StatelessWidget {
  final CourseModel course;
  const AdminCourseCard({
    super.key,
    required this.course,
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
                      image: AssetImage(
                          'assets/images/application_images/code.jpg'), // Use AssetImage
                      fit: BoxFit
                          .fitHeight, // Or BoxFit.contain, or other BoxFit options
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10), // Top left corner
                      bottomLeft: Radius.circular(10), // Bottom left corner
                    ),
                    color: Colors.black,
                  ),
                  width: screenWidth * 0.3,
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
                                  "3 Mentors",
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
                    onPressed: () {}, 
                    constraints: BoxConstraints(
                      minWidth: 0, 
                      minHeight: screenWidth * 0.5, 
                    ),
                    icon: Icon(Icons.more_vert),
                    ),
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
