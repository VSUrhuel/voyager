import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:voyager/src/features/admin/controllers/course_controller.dart';
import 'package:voyager/src/features/admin/models/course_mentor_model.dart';
import 'package:voyager/src/features/admin/screens/courses/course_details.dart';
import 'package:voyager/src/features/admin/screens/courses/mentor_popup.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentee/model/course_model.dart';
import 'package:voyager/src/features/mentee/screens/session/upcoming_card.dart';

class AdminCourseCard extends StatelessWidget {
  final CourseModel course;
  final VoidCallback onUpdate;
  final List<CourseMentorModel> courseMentors;
  // final Future<List<UserModel>>? allCourseMentees;

  const AdminCourseCard({
    super.key,
    required this.course,
    required this.onUpdate,
    required this.courseMentors,
    // this.allCourseMentees,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    // final courseMentors = firestoreInstance.getMenteeAccountsForCourse(course.docId, 'accepted');

    return FutureBuilder<List<UserModel>>(
      future: firestoreInstance.getMenteeAccountsForCourse(course.docId, 'accepted'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Lottie.asset(
          'assets/images/loading.json',
          fit: BoxFit.cover,
          width: screenWidth * 0.6,
          height: screenWidth * 0.4,
          repeat: true,
        );
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading mentees'));
        }

        final mentees = snapshot.data!;
         return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.03,
        vertical: screenHeight * 0.01,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseDetails(
                courseModel: course,
                courseMentors: courseMentors,
              ),
            ),
          );
        },
        child: SizedBox(
          height: screenHeight * 0.18,
          child: Row(
            children: [
              // Course Image
              Container(
                width: screenWidth * 0.28,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  image: DecorationImage(
                    image: course.courseImgUrl.isEmpty
                        ? const AssetImage(
                                'assets/images/application_images/code.jpg')
                            as ImageProvider
                        : NetworkImage(course.courseImgUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Course Info
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(screenWidth * 0.03),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Course Name and Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              course.courseName,
                              style: TextStyle(
                                fontSize: screenWidth * 0.045,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (course.courseStatus == 'archived')
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Archived',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                        ],
                      ),

                      SizedBox(height: screenHeight * 0.01),

                      // Course Description (if available)
                      // if (course.courseDescription?.isNotEmpty ?? false)
                      //   Flexible(
                      //     child: Text(
                      //       course.courseDescription,
                      //       style: TextStyle(
                      //         fontSize: screenWidth * 0.030,
                      //       ),
                      //       maxLines: 2,
                      //       overflow: TextOverflow.ellipsis,

                      //     ),
                      //   ),

                      const Spacer(),

                      // Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            context,
                            icon: Icons.group,
                            value: '${courseMentors.length}',
                            label: 'Mentors',
                          ),
                          _buildStatItem(
                            context,
                            icon: FontAwesomeIcons.peopleGroup,
                            value: '${mentees.length}',
                            label: 'Mentees',
                          ),
                          _buildStatItem(
                            context,
                            icon: FontAwesomeIcons.calendar,
                            value: '1',
                            label: 'Sem',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Options Menu
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: theme.iconTheme.color,
                ),
                onSelected: (String value) async {
                  switch (value) {
                    case 'add':
                      await showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: MentorPopup(course: course.docId),
                        ),
                      );
                      onUpdate();
                      break;
                    case 'archive':
                      if (course.courseStatus == 'archived') {
                        await CourseController().restoreCourse(course.docId);
                      } else {
                        await CourseController().archiveCourse(course.docId);
                      }
                      onUpdate();
                      break;
                    case 'delete':
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirm Deletion'),
                          content: const Text(
                              'This will permanently delete the course. Are you sure?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
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
                    child: Text('Add Mentor'),
                  ),
                  PopupMenuItem<String>(
                    value: 'archive',
                    child: Text(
                      course.courseStatus == 'archived'
                          ? 'Restore Course'
                          : 'Archive Course',
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text(
                      'Delete Course',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
      },
    );

   
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}
