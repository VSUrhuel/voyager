// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:voyager/src/features/admin/controllers/course_mentor_controller.dart';
import 'package:voyager/src/features/admin/models/course_mentor_model.dart';
import 'package:voyager/src/features/admin/screens/mentors/mentor_list.dart';
import 'package:voyager/src/features/admin/screens/mentors/mentor_profile.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentee/model/course_model.dart';
import 'package:voyager/src/features/mentee/widgets/pick_mentor_card.dart';
import 'package:voyager/src/features/mentor/model/mentor_model.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';

class MenteesOfMentor {
  final List<UserModel> mentees;
  final String courseMentorId; // The junction table ID
  final UserModel mentorUser; // The actual user data

  MenteesOfMentor({
    required this.mentees,
    required this.courseMentorId,
    required this.mentorUser,
  });
}

class CourseDetails extends StatefulWidget {
  final CourseModel courseModel;
  final List<CourseMentorModel> courseMentors;

  const CourseDetails({
    super.key,
    required this.courseModel,
    required this.courseMentors,
  });

  @override
  State<CourseDetails> createState() => _CourseDetailsState();
}

class _CourseDetailsState extends State<CourseDetails> {
  final FirestoreInstance firestoreInstance = FirestoreInstance();
  bool isLoading = false;
  List<UserModel> allCourseMentees = [];
  List<MenteesOfMentor> menteesByMentor = [];

  List<UserModel> fetchedUsers = [];
  String? selectedMentorId;

  // @override
  // void initState() {
  //   super.initState();
  //   _loadData();
  // }

  Future<List<PickMentorCard>> fetchMentorsWithDetails() async {
    try {
      List<UserModel> users =
          await firestoreInstance.getCourseMentors(widget.courseModel.docId);
      List<MentorModel> mentorDetails = await Future.wait(users.map((user) =>
          firestoreInstance.getMentorThroughAccId(user.accountApiID)));
      allCourseMentees = await firestoreInstance.getMenteeAccountsForCourse(
          widget.courseModel.docId, 'accepted');
      fetchedUsers = users;
      // setState(() {

      // });

      return List.generate(users.length, (index) {
        return PickMentorCard(
          mentorModel: mentorDetails[index],
          user: users[index],
          isSelected: selectedMentorId == users[index].accountApiID,
          onTap: () {
            _showCustomDialog(context, mentorDetails[index], users[index],
                widget.courseModel.docId);
          },
        );
      });
    } catch (e) {
      return [];
    }
  }

  Future<void> _showCustomDialog(BuildContext context, MentorModel mentor,
      UserModel user, String courseId) async {
    final courseMentor = widget.courseMentors.firstWhere(
        (cm) => cm.mentorId == mentor.mentorId && cm.courseId == courseId);
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Mentor Options',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'What would you like to do with this mentor?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 24),

              // View Mentor Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, 'view'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'View Mentor Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Remove Mentor Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, 'remove'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.red[300]!),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Remove Mentor',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Cancel Button
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (choice != null) {
      if (choice == 'view') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                MentorProfile(mentorModel: mentor, user: user),
          ),
        );
      } else if (choice == 'remove') {
        // Show confirmation dialog
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Removal '),
            content: Text(
                'Are you sure you want to remove mentor ${user.accountApiName} to the course?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Confirm'),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          try {
            await CourseMentorController().removeMentorFromCourse(
                courseMentor.courseMentorId, mentor.mentorId);
            Navigator.pop(context);
          } catch (e) {
            throw Exception('Error removing mentor: $e');
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Course Details',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18.0,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(
              child: Lottie.asset(
                'assets/images/loading.json',
                fit: BoxFit.cover,
                width: screenHeight * 0.08,
                height: screenWidth * 0.04,
                repeat: true,
              ),
              )
          : FutureBuilder<List<PickMentorCard>>(
              future: fetchMentorsWithDetails(),
              builder: (context, mentorCardSnapshot) {
                if (mentorCardSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(
                      child: Lottie.asset(
                        'assets/images/loading.json',
                        fit: BoxFit.cover,
                        width: screenHeight * 0.08,
                        height: screenWidth * 0.04,
                        repeat: true,
                      ),
                      );
                }
                final mentorCards = mentorCardSnapshot.data ?? [];
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Course Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: screenHeight * 0.25,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                          ),
                          child: widget.courseModel.courseImgUrl.isEmpty
                              ? Image.asset(
                                  'assets/images/application_images/code.jpg',
                                  fit: BoxFit.cover)
                              : Image.network(widget.courseModel.courseImgUrl,
                                  fit: BoxFit.cover),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.025),

                      // Stats Card
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _infoItem(Icons.schedule_rounded, '1 Semester',
                                screenHeight),
                            _infoItem(
                                Icons.groups_rounded,
                                "${widget.courseMentors.length} ${widget.courseMentors.length > 1 ? 'Mentors' : 'Mentor'}",
                                screenHeight),
                            _infoItem(
                                Icons.people_alt_rounded,
                                "${allCourseMentees.length} ${allCourseMentees.length > 1 ? 'Mentees' : 'Mentee'}",
                                screenHeight),
                          ],
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.03),

                      // Course Title Section
                      _buildSectionTitle("Course Title"),
                      SizedBox(height: 8),
                      Text(
                        "${widget.courseModel.courseCode}: ${widget.courseModel.courseName}",
                        style: TextStyle(
                          fontSize: screenHeight * 0.018,
                          color: Colors.black87,
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.03),

                      // Description Section
                      _buildSectionTitle("Description"),
                      SizedBox(height: 8),
                      Text(
                        widget.courseModel.courseDescription,
                        style: TextStyle(
                          fontSize: screenHeight * 0.018,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.03),

                      // Learning Outcomes Section
                      _buildSectionTitle("What Mentees will Learn"),
                      SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (int i = 0;
                              i < widget.courseModel.courseDeliverables.length;
                              i++)
                            _bulletPoint(
                                widget.courseModel.courseDeliverables[i],
                                screenHeight),
                        ],
                      ),

                      SizedBox(height: screenHeight * 0.03),

                      // Mentors Section Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionTitle("Assigned Mentors"),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MentorList(),
                                  ));
                            },
                            child: Text(
                              "Edit Mentors",
                              style: TextStyle(
                                color: Colors.blue[600],
                                fontSize: screenHeight * 0.018,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: screenHeight * 0.02),

                      // Mentors List
                      mentorCards.isEmpty
                          ? Container(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  'No mentors available',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            )
                          : Column(children: mentorCards),
                    ],
                  ),
                );
              },
            ),
    )
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 18,
        color: Colors.black87,
      ),
    );
  }

  Widget _infoItem(IconData icon, String text, double screenHeight) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue[600], size: 24),
        SizedBox(height: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: screenHeight * 0.016,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _bulletPoint(String text, double screenHeight) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 4, right: 8),
            child: Icon(Icons.circle, size: 6, color: Colors.blue[600]),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: screenHeight * 0.018,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

//   Widget _infoItem(IconData icon, String text, double screenHeight) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(icon, size: screenHeight * 0.04),
//         SizedBox(height: screenHeight * 0.005),
//         Text(
//           text,
//           style: TextStyle(
//             fontSize: screenHeight * 0.018,
//             fontWeight: FontWeight.normal,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _bulletPoint(String text, double screenHeight) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: screenHeight * 0.005),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text("\u2022 ", style: TextStyle(fontSize: screenHeight * 0.018)),
//           Expanded(
//             child: Text(
//               text,
//               style: TextStyle(fontSize: screenHeight * 0.018),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _InfoItemShimmer extends StatelessWidget {
//   const _InfoItemShimmer();

  // @override
  // Widget build(BuildContext context) {
  //   return Column(
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       Container(
  //         width: 24,
  //         height: 24,
  //         color: Colors.grey[200],
  //       ),
  //       const SizedBox(height: 4),
  //       Container(
  //         width: 60,
  //         height: 16,
  //         color: Colors.grey[200],
  //       ),
  //     ],
  //   );
  // }
}
