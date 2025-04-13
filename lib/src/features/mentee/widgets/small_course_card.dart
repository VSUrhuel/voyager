import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentee/model/course_model.dart';
import 'package:voyager/src/features/mentee/screens/home/enroll_course.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';

class SmallCourseCard extends StatelessWidget {
  final CourseModel courseModel;
  final FirestoreInstance firestoreInstance = FirestoreInstance();

  SmallCourseCard({super.key, required this.courseModel});

  Future<int> fetchTotalMentors() async {
    try {
      List<UserModel> users =
          await firestoreInstance.getCourseMentors(courseModel.docId);
      return users.length;
    } catch (e) {
      print("Error fetching mentors: $e");
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final startDate =
        DateFormat('MMM dd').format(courseModel.courseCreatedTimestamp);
    final endDate =
        DateFormat('MMM dd').format(courseModel.courseModifiedTimestamp);

    final currentUser = FirebaseAuth.instance.currentUser;
    final userEmail = currentUser?.email ?? '';
    final userId = firestoreInstance.getUserDocIdThroughEmail(userEmail);

    final supabase = Supabase.instance.client;
    final imageUrl = (courseModel.courseImgUrl.isNotEmpty)
        ? (courseModel.courseImgUrl.startsWith('http')
            ? courseModel.courseImgUrl
            : supabase.storage
                .from('course-picture')
                .getPublicUrl(courseModel.courseImgUrl))
        : 'https://zyqxnzxudwofrlvdzbvf.supabase.co/storage/v1/object/public/course-picture/linear-algebra.png';

    return FutureBuilder<int>(
      future: fetchTotalMentors(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final totalMentor = snapshot.data ?? 0;

        return Card(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(4.0),
            child: Column(
              children: [
                // Display
                Row(
                  children: [
                    // Left Half (Image)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                        color: Colors.black,
                      ),
                      width: screenWidth * 0.25,
                      height: screenHeight * 0.22,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.broken_image, color: Colors.white),
                        ),
                      ),
                    ),

                    // Right Half
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                        color: Colors.grey[800],
                      ),
                      width: screenWidth * 0.6,
                      height: screenHeight * 0.22,
                      child: Column(
                        children: [
                          // Header
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    "${courseModel.courseCode} - ${courseModel.courseName}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Details
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
                                          color: Colors.white, fontSize: 10),
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
                                          color: Colors.white, fontSize: 10),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: screenHeight * 0.01),
                // Bottom section
                Row(
                  children: [
                    Text("Start on $startDate - $endDate"),
                    SizedBox(width: screenWidth * 0.03),
                    ElevatedButton(
                      onPressed: () {
                        if (userEmail.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please sign in to enroll')),
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
