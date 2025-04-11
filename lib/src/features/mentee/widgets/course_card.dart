import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:voyager/src/features/mentee/model/course_model.dart';
import 'package:voyager/src/features/mentee/screens/home/enroll_course.dart';
import 'package:intl/intl.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CourseCard extends StatelessWidget {
  final CourseModel courseModel;
  final FirestoreInstance firestoreInstance = FirestoreInstance();

  CourseCard({super.key, required this.courseModel});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final currentUser = FirebaseAuth.instance.currentUser;
    final userEmail = currentUser?.email ?? '';
    final userId = firestoreInstance.getUserDocIdThroughEmail(userEmail);

    return FutureBuilder<int>(
      future: firestoreInstance.getTotalMentorsForCourse(courseModel.docId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final totalMentor = snapshot.data ?? 0;

        // Format dates
        final startDate =
            DateFormat('MMM dd').format(courseModel.courseCreatedTimestamp);
        final endDate =
            DateFormat('MMM dd').format(courseModel.courseModifiedTimestamp);

        return Card(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Padding(
            padding: EdgeInsets.all(4.0),
            child: Column(
              children: [
                // Image and course info
                Row(
                  children: [
                    // Image side
                    Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                              'assets/images/application_images/code.jpg'),
                          fit: BoxFit.fitHeight,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                        color: Colors.black,
                      ),
                      width: screenWidth * 0.3,
                      height: screenHeight * 0.25,
                    ),
                    // Course info side
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                        color: Colors.grey[800],
                      ),
                      width: screenWidth * 0.6,
                      height: screenHeight * 0.25,
                      child: Column(
                        children: [
                          // Course name
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    '${courseModel.courseCode} - ${courseModel.courseName}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Mentor and semester details
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                SizedBox(width: screenWidth * 0.05),
                                Column(
                                  children: [
                                    Icon(
                                      Icons.group,
                                      color: Colors.white,
                                      size: screenWidth * 0.08,
                                    ),
                                    Text(
                                      "$totalMentor Mentors",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: screenWidth * 0.05),
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
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.01),
                // Bottom section: start-end date and enroll button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 12.0),
                      child: Text("Start on $startDate - $endDate"),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 12.0),
                      child: ElevatedButton(
                        onPressed: () {
                          if (userEmail.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Please sign in to enroll')),
                            );
                            return;
                          }

                          userId.then((resolvedUserId) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EnrollCourse(
                                  courseModel: courseModel,
                                  userId: resolvedUserId,
                                ),
                              ),
                            );
                          }).catchError((error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $error')),
                            );
                          });
                        },
                        child: Text("Enroll Now"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
