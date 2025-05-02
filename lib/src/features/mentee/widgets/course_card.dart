import 'package:cloud_firestore/cloud_firestore.dart';
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
  late Future<int> totalMenteeFuture;
  late Future<String> userIdFuture;
  late String imageUrl;

  @override
  void initState() {
    super.initState();
    totalMentorsFuture = fetchTotalMentors();
    totalMenteeFuture =
        firestoreInstance.getTotalMenteeForCourse(widget.courseModel.docId);
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
    final screenHeight = MediaQuery.of(context).size.height;

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
                minHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image section
                  Flexible(
                    flex: 6,
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
                    flex: 6,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 16.0, left: 16.0, right: 16.0, bottom: 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    label:
                                        totalMentor > 1 ? 'Mentors' : 'Mentor',
                                    theme: theme,
                                  ),
                                  FutureBuilder<int>(
                                    future: totalMenteeFuture,
                                    builder: (context, menteeSnapshot) {
                                      final menteeCount =
                                          menteeSnapshot.data ?? 0;
                                      return _buildStatItem(
                                        icon: FontAwesomeIcons.users,
                                        value: '$menteeCount',
                                        label: menteeCount > 1
                                            ? 'Mentees'
                                            : 'Mentee',
                                        theme: theme,
                                      );
                                    },
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
