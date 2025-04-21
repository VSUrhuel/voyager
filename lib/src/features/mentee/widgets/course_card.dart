import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentee/model/course_model.dart';
import 'package:voyager/src/features/mentee/screens/home/enroll_course.dart';
import 'package:intl/intl.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CourseCard extends StatefulWidget {
  final CourseModel courseModel;

  const CourseCard({super.key, required this.courseModel});

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  final FirestoreInstance firestoreInstance = FirestoreInstance();
  late Future<int> totalMentorsFuture;
  late Future<String> userIdFuture;
  late String imageUrl;

  @override
  void initState() {
    super.initState();
    totalMentorsFuture = fetchTotalMentors();
    userIdFuture = getUserId();

    final supabase = Supabase.instance.client;
    imageUrl = (widget.courseModel.courseImgUrl.isNotEmpty)
        ? (widget.courseModel.courseImgUrl.startsWith('http')
            ? widget.courseModel.courseImgUrl
            : supabase.storage
                .from('course-picture')
                .getPublicUrl(widget.courseModel.courseImgUrl))
        : 'https://zyqxnzxudwofrlvdzbvf.supabase.co/storage/v1/object/public/course-picture/linear-algebra.png';
  }

  Future<int> fetchTotalMentors() async {
    try {
      List<UserModel> users =
          await firestoreInstance.getCourseMentors(widget.courseModel.docId);
      return users.length;
    } catch (e) {
      print("Error fetching mentors: $e");
      return 0;
    }
  }

  Future<String> getUserId() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userEmail = currentUser?.email ?? '';
    return await firestoreInstance.getUserDocIdThroughEmail(userEmail);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = FirebaseAuth.instance.currentUser;
    final screenHeight = MediaQuery.of(context).size.height;

    final startDate = DateFormat('MMM dd yy')
        .format(widget.courseModel.courseCreatedTimestamp);
    final endDate = DateFormat('MMM dd, yyyy')
        .format(widget.courseModel.courseModifiedTimestamp);

    return FutureBuilder<int>(
      future: totalMentorsFuture,
      builder: (context, snapshot) {
        final totalMentor = snapshot.data ?? 0;

        return GestureDetector(
          onTap: () {
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please sign in to enroll')),
              );
              return;
            }
            userIdFuture.then((resolvedUserId) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EnrollCourse(
                    courseModel: widget.courseModel,
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
          child: Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9,
                minHeight: MediaQuery.of(context).size.height *
                    0.5, // Increased height
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image section - now takes more space
                  Flexible(
                    flex: 6, // Increased from 5 to give more space to image
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child:
                              Center(child: Icon(Icons.broken_image, size: 40)),
                        ),
                      ),
                    ),
                  ),

                  // Content section
                  Flexible(
                    flex: 6, // Adjusted from 4 to balance the increased height
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 16.0, left: 16.0, right: 16.0, bottom: 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment
                            .spaceBetween, // Better space distribution
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Course Title
                              Text(
                                '${widget.courseModel.courseCode} - ${widget.courseModel.courseName}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),

                              // Stats Section
                              Wrap(
                                spacing: 24,
                                runSpacing: 12,
                                children: [
                                  _buildStatItem(
                                    icon: Icons.group,
                                    value: '$totalMentor',
                                    label: 'Mentors',
                                    theme: theme,
                                  ),
                                  _buildStatItem(
                                    icon: FontAwesomeIcons.users,
                                    value:
                                        totalMentor > 0 ? '$totalMentor' : '0',
                                    label: 'Mentee',
                                    theme: theme,
                                  ),
                                  _buildStatItem(
                                    icon: FontAwesomeIcons.calendar,
                                    value: '1',
                                    label: 'Semester',
                                    theme: theme,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: screenHeight * 0.02,
                              ),

                              Text(
                                'This course was modified on $endDate',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: screenHeight * 0.015,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),

                          // Enroll Button
                          // SizedBox(
                          //   width: double.infinity,
                          //   child: ElevatedButton(
                          //     style: ElevatedButton.styleFrom(
                          //       backgroundColor: theme.colorScheme.primary,
                          //       foregroundColor: theme.colorScheme.onPrimary,
                          //       shape: RoundedRectangleBorder(
                          //         borderRadius: BorderRadius.circular(8),
                          //       ),
                          //     ),
                          //     onPressed: () {
                          //       if (currentUser == null) {
                          //         ScaffoldMessenger.of(context).showSnackBar(
                          //           const SnackBar(
                          //             content: Text('Please sign in to enroll'),
                          //           ),
                          //         );
                          //         return;
                          //       }
                          //       userIdFuture.then((resolvedUserId) {
                          //         Navigator.push(
                          //           context,
                          //           MaterialPageRoute(
                          //             builder: (context) => EnrollCourse(
                          //               courseModel: widget.courseModel,
                          //               userId: resolvedUserId,
                          //             ),
                          //           ),
                          //         );
                          //       }).catchError((error) {
                          //         ScaffoldMessenger.of(context).showSnackBar(
                          //           SnackBar(content: Text('Error: $error')),
                          //         );
                          //       });
                          //     },
                          //     child: const Text('Enroll Now'),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Icon(icon, size: 15, color: theme.colorScheme.primary),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:voyager/src/features/authentication/models/user_model.dart';
// import 'package:voyager/src/features/mentee/model/course_model.dart';
// import 'package:voyager/src/features/mentee/screens/home/enroll_course.dart';
// import 'package:intl/intl.dart';
// import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class CourseCard extends StatefulWidget {
//   final CourseModel courseModel;

//   const CourseCard({super.key, required this.courseModel});

//   @override
//   State<CourseCard> createState() => _CourseCardState();
// }

// class _CourseCardState extends State<CourseCard> {
//   final FirestoreInstance firestoreInstance = FirestoreInstance();
//   late Future<int> totalMentorsFuture;
//   late Future<String> userIdFuture;
//   late String imageUrl;

//   @override
//   void initState() {
//     super.initState();
//     totalMentorsFuture = fetchTotalMentors();
//     userIdFuture = getUserId();

//     final supabase = Supabase.instance.client;
//     imageUrl = (widget.courseModel.courseImgUrl.isNotEmpty)
//         ? (widget.courseModel.courseImgUrl.startsWith('http')
//             ? widget.courseModel.courseImgUrl
//             : supabase.storage
//                 .from('course-picture')
//                 .getPublicUrl(widget.courseModel.courseImgUrl))
//         : 'https://zyqxnzxudwofrlvdzbvf.supabase.co/storage/v1/object/public/course-picture/linear-algebra.png';
//   }

//   Future<int> fetchTotalMentors() async {
//     try {
//       List<UserModel> users =
//           await firestoreInstance.getCourseMentors(widget.courseModel.docId);
//       return users.length;
//     } catch (e) {
//       print("Error fetching mentors: $e");
//       return 0;
//     }
//   }

//   Future<String> getUserId() async {
//     final currentUser = FirebaseAuth.instance.currentUser;
//     final userEmail = currentUser?.email ?? '';
//     return await firestoreInstance.getUserDocIdThroughEmail(userEmail);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     final currentUser = FirebaseAuth.instance.currentUser;
//     final userEmail = currentUser?.email ?? '';

//     final startDate =
//         DateFormat('MMM dd').format(widget.courseModel.courseCreatedTimestamp);
//     final endDate =
//         DateFormat('MMM dd').format(widget.courseModel.courseModifiedTimestamp);

//     return FutureBuilder<int>(
//       future: totalMentorsFuture,
//       builder: (context, snapshot) {
//         final totalMentor = snapshot.data ?? 0;

//         return Card(
//           color: Colors.white,
//           elevation: 2,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.all(Radius.circular(10)),
//           ),
//           child: Padding(
//             padding: EdgeInsets.all(4.0),
//             child: Column(
//               children: [
//                 // Top: image + course info
//                 Row(
//                   children: [
//                     // Image
//                     Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(10),
//                           bottomLeft: Radius.circular(10),
//                         ),
//                         color: Colors.black,
//                       ),
//                       width: screenWidth * 0.3,
//                       height: screenHeight * 0.25,
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(10),
//                           bottomLeft: Radius.circular(10),
//                         ),
//                         child: Image.network(
//                           imageUrl,
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) =>
//                               Icon(Icons.broken_image, color: Colors.white),
//                         ),
//                       ),
//                     ),

//                     // Info
//                     Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.only(
//                           topRight: Radius.circular(10),
//                           bottomRight: Radius.circular(10),
//                         ),
//                         color: Colors.grey[800],
//                       ),
//                       width: screenWidth * 0.6,
//                       height: screenHeight * 0.25,
//                       child: Column(
//                         children: [
//                           // Course title
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(16.0),
//                                   child: Text(
//                                     '${widget.courseModel.courseCode} - ${widget.courseModel.courseName}',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 15,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           // Mentor and semester
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Row(
//                               children: [
//                                 SizedBox(width: screenWidth * 0.05),
//                                 Column(
//                                   children: [
//                                     Icon(
//                                       Icons.group,
//                                       color: Colors.white,
//                                       size: screenWidth * 0.08,
//                                     ),
//                                     Text(
//                                       "$totalMentor Mentors",
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 10,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 SizedBox(width: screenWidth * 0.05),
//                                 Column(
//                                   children: [
//                                     FaIcon(
//                                       FontAwesomeIcons.peopleGroup,
//                                       color: Colors.white,
//                                       size: screenWidth * 0.08,
//                                     ),
//                                     Text(
//                                       "1 Semester",
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 10,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),

//                 SizedBox(height: screenHeight * 0.01),

//                 // Bottom row: dates + enroll
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Padding(
//                       padding: EdgeInsets.only(left: 12.0),
//                       child: Text("Start on $startDate - $endDate"),
//                     ),
//                     SizedBox(width: screenWidth * 0.045),
//                     Padding(
//                       padding: EdgeInsets.only(right: 12.0),
//                       child: ElevatedButton(
//                         onPressed: () {
//                           final user = FirebaseAuth.instance.currentUser;
//                           if (user == null) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                   content: Text('Please sign in to enroll')),
//                             );
//                             return;
//                           }
//                           userIdFuture.then((resolvedUserId) {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => EnrollCourse(
//                                   courseModel: widget.courseModel,
//                                   userId: resolvedUserId,
//                                 ),
//                               ),
//                             );
//                           }).catchError((error) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(content: Text('Error: $error')),
//                             );
//                           });
//                         },
//                         child: Text("Enroll Now"),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
