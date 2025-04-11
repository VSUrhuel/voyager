import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentee/model/course_model.dart';
import 'package:voyager/src/features/mentee/widgets/pick_mentor_card.dart';
import 'package:voyager/src/features/mentor/model/mentor_model.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';

class EnrollCourse extends StatefulWidget {
  final CourseModel courseModel;
  final String userId;

  const EnrollCourse({
    super.key,
    required this.courseModel,
    required this.userId,
  });

  @override
  State<EnrollCourse> createState() => _EnrollCourseState();
}

class _EnrollCourseState extends State<EnrollCourse> {
  final FirestoreInstance firestoreInstance = FirestoreInstance();
  String? selectedMentorId;
  bool isLoading = false;

  Future<List<PickMentorCard>> fetchMentorsWithDetails() async {
    try {
      List<UserModel> users = await firestoreInstance.getMentors();
      List<MentorModel> mentorDetails = await Future.wait(users.map((user) =>
          firestoreInstance.getMentorThroughAccId(user.accountApiID)));

      return List.generate(users.length, (index) {
        return PickMentorCard(
          mentorModel: mentorDetails[index],
          user: users[index],
          isSelected: selectedMentorId == users[index].accountApiID,
          onTap: () {
            setState(() {
              selectedMentorId = users[index].accountApiID;
            });
          },
        );
      });
    } catch (e) {
      return [];
    }
  }

  Future<void> enrollThisCourse() async {
    if (selectedMentorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a mentor first')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final firestore = FirebaseFirestore.instance;
      final Timestamp createdTimestamp = Timestamp.now();

      // Step 1: Query courseMentor collection where courseId field matches
      final courseMentorQuery = firestore
          .collection('courseMentor')
          .where('courseId', isEqualTo: widget.courseModel.docId);

      final courseMentorSnapshot = await courseMentorQuery.get();
      print(widget.courseModel.docId);
      if (courseMentorSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Course is not available for enrollment')),
        );
        return;
      }

      // Step 2: Get the courseMentorId from the first matching document
      final courseMentorId = courseMentorSnapshot.docs.first.id;

      // Step 3: Add record to menteeCourseAlloc
      await firestore.collection('menteeCourseAlloc').add({
        'courseMentorId': courseMentorId,
        'mcaAllocStatus': 'accepted',
        'mcaCreatedTimestamp': createdTimestamp,
        'mcaSoftDeleted': false,
        'menteeId': widget.userId,
        'mentorId': selectedMentorId, // Use selected mentor
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully enrolled in the course!')),
      );

      if (mounted) {
        Navigator.pop(context); // Go back after successful enrollment
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Error enrolling in the course: $e $selectedMentorId')),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final supabase = Supabase.instance.client;
    final imageUrl = (widget.courseModel.courseImgUrl.isNotEmpty)
        ? (widget.courseModel.courseImgUrl.startsWith('http')
            ? widget.courseModel.courseImgUrl
            : supabase.storage
                .from('course-picture')
                .getPublicUrl(widget.courseModel.courseImgUrl))
        : 'https://zyqxnzxudwofrlvdzbvf.supabase.co/storage/v1/object/public/course-picture/linear-algebra.png';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Enroll Course',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 18.0,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: screenHeight * 0.25,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Container(
                    padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.015,
                        horizontal: screenWidth * 0.05),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: FutureBuilder<int>(
                      future: firestoreInstance
                          .getTotalMentorsForCourse(widget.courseModel.docId),
                      builder: (context, mentorSnapshot) {
                        if (mentorSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _InfoItemShimmer(),
                              _InfoItemShimmer(),
                              _InfoItemShimmer(),
                            ],
                          );
                        }
                        final totalMentor = mentorSnapshot.data ?? 0;

                        return FutureBuilder<int>(
                          future: firestoreInstance.getTotalMenteeForCourse(
                              widget.courseModel.docId),
                          builder: (context, menteeSnapshot) {
                            if (menteeSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _InfoItemShimmer(),
                                  _InfoItemShimmer(),
                                  _InfoItemShimmer(),
                                ],
                              );
                            }
                            final totalMentee = menteeSnapshot.data ?? 0;

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _infoItem(Icons.access_time, '1 Semester',
                                    screenHeight),
                                _infoItem(Icons.groups, "$totalMentor Mentors",
                                    screenHeight),
                                _infoItem(Icons.people, "$totalMentee Mentees",
                                    screenHeight),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Text(
                    "Description",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenHeight * 0.022,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Text(
                    widget.courseModel.courseDescription,
                    style: TextStyle(fontSize: screenHeight * 0.018),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Text(
                    "What You'll Learn:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenHeight * 0.022,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0;
                          widget.courseModel.courseDeliverables.length > i;
                          i++)
                        _bulletPoint(widget.courseModel.courseDeliverables[i],
                            screenHeight),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Pick your Mentor",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenHeight * 0.022,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to mentor selection
                        },
                        child: Text(
                          "View Mentors",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: screenHeight * 0.020,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  FutureBuilder<List<PickMentorCard>>(
                    future: fetchMentorsWithDetails(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final mentors = snapshot.data ?? [];

                      return SizedBox(
                        height: screenHeight * 0.4,
                        child: mentors.isEmpty
                            ? const Center(child: Text('No mentors available'))
                            : ListView.builder(
                                itemCount: mentors.length,
                                itemBuilder: (context, index) {
                                  return mentors[index];
                                },
                              ),
                      );
                    },
                  ),
                  SizedBox(height: screenHeight * 0.03),
                ],
              ),
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Colors.white,
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isLoading ? null : enrollThisCourse,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    "Enroll this Course",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _infoItem(IconData icon, String text, double screenHeight) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: screenHeight * 0.04),
        SizedBox(height: screenHeight * 0.005),
        Text(
          text,
          style: TextStyle(
            fontSize: screenHeight * 0.018,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _bulletPoint(String text, double screenHeight) {
    return Padding(
      padding: EdgeInsets.only(bottom: screenHeight * 0.005),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("\u2022 ", style: TextStyle(fontSize: screenHeight * 0.018)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: screenHeight * 0.018),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItemShimmer extends StatelessWidget {
  const _InfoItemShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          color: Colors.grey[200],
        ),
        const SizedBox(height: 4),
        Container(
          width: 60,
          height: 16,
          color: Colors.grey[200],
        ),
      ],
    );
  }
}
