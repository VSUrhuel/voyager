// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
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
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = FirebaseAuth.instance.currentUser;
    final startDate =
        DateFormat('MMM dd').format(courseModel.courseCreatedTimestamp);

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
          return Center();
        }

        final totalMentor = snapshot.data ?? 0;

        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              if (currentUser == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please sign in to enroll')),
                );
                return;
              }
              firestoreInstance
                  .getUserDocIdThroughEmail(currentUser.email!)
                  .then((userId) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EnrollCourse(
                      courseModel: courseModel,
                      userId: userId,
                    ),
                  ),
                );
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child:
                              const Center(child: Icon(Icons.image, size: 40)),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Course Title
                  Text(
                    '${courseModel.courseCode} - ${courseModel.courseName}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Stats Row
                  Row(
                    children: [
                      Icon(Icons.people,
                          size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Text('$totalMentor', style: theme.textTheme.bodySmall),
                      const SizedBox(width: 12),
                      Icon(Icons.calendar_today,
                          size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Text('Modified on $startDate',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          )),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Enroll Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        if (currentUser == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please sign in to enroll')),
                          );
                          return;
                        }
                        firestoreInstance
                            .getUserDocIdThroughEmail(currentUser.email!)
                            .then((userId) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EnrollCourse(
                                courseModel: courseModel,
                                userId: userId,
                              ),
                            ),
                          );
                        });
                      },
                      child: const Text('Enroll Now'),
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
}
