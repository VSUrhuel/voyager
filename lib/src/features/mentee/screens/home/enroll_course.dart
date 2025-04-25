import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:lottie/lottie.dart';
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

  List<UserModel> fetchedUsers = [];

  Future<List<PickMentorCard>> fetchMentorsWithDetails() async {
    try {
      List<UserModel> users =
          await firestoreInstance.getCourseMentors(widget.courseModel.docId);
      List<MentorModel> mentorDetails = await Future.wait(users.map((user) =>
          firestoreInstance.getMentorThroughAccId(user.accountApiID)));

      fetchedUsers = users;

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
      final createdTimestamp = Timestamp.now();

      final courseMentorQuery = await firestore
          .collection('courseMentor')
          .where('courseId', isEqualTo: widget.courseModel.docId)
          .where('courseMentorSoftDeleted', isEqualTo: false)
          .limit(1)
          .get();

      if (courseMentorQuery.docs.isEmpty) {
        throw 'Course is not available for enrollment';
      }
      final courseMentorId = courseMentorQuery.docs.first.id;

      final menteeQuery = await firestore
          .collection('mentee')
          .where('accountId', isEqualTo: widget.userId)
          .where('menteeSoftDelete', isEqualTo: false)
          .limit(1)
          .get();

      final menteeRef = menteeQuery.docs.isNotEmpty
          ? menteeQuery.docs.first.reference
          : await firestore.collection('mentee').add({
              'accountId': widget.userId,
              'menteeMcaId': [],
              'menteeSoftDelete': false,
            });

      final menteeId = menteeQuery.docs.isNotEmpty
          ? menteeQuery.docs.first.id
          : menteeRef.id;

      final existingAllocQuery = await firestore
          .collection('menteeCourseAlloc')
          .where('courseMentorId', isEqualTo: courseMentorId)
          .where('menteeId', isEqualTo: menteeId)
          .where('mcaSoftDeleted', isEqualTo: false)
          .limit(1)
          .get();

      if (existingAllocQuery.docs.isNotEmpty) {
        await existingAllocQuery.docs.first.reference.update({
          'mcaAllocStatus': 'pending',
          'mcaModifiedTimestamp': createdTimestamp,
        });
      } else {
        final newAllocRef =
            await firestore.collection('menteeCourseAlloc').add({
          'courseMentorId': courseMentorId,
          'mcaAllocStatus': 'pending',
          'mcaCreatedTimestamp': createdTimestamp,
          'mcaModifiedTimestamp': createdTimestamp,
          'mcaSoftDeleted': false,
          'menteeId': menteeId,
        });

        await menteeRef.update({
          'menteeMcaId': FieldValue.arrayUnion([newAllocRef.id])
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Course enrollment processed successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
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
    final courseName = widget.courseModel.courseName;
    return SafeArea(
        bottom: true,
        top: false,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1.0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              courseName,
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
              : FutureBuilder<List<PickMentorCard>>(
                  future: fetchMentorsWithDetails(),
                  builder: (context, mentorCardSnapshot) {
                    if (mentorCardSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final mentorCards = mentorCardSnapshot.data ?? [];

                    return SingleChildScrollView(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                  : Image.network(imageUrl, fit: BoxFit.cover),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 16, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.07),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: FutureBuilder<int>(
                              future: firestoreInstance.getTotalMenteeForCourse(
                                  widget.courseModel.docId),
                              builder: (context, menteeSnapshot) {
                                final totalMentee = menteeSnapshot.data ?? 0;

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _infoItem(Icons.access_time, '1 Semester',
                                    screenHeight),
                                _infoItem(
                                    Icons.groups,
                                    "${fetchedUsers.length} ${fetchedUsers.length == 1 ? 'Mentor' : 'Mentors'}",
                                    screenHeight),
                                _infoItem(
                                    Icons.people,
                                    "$totalMentee ${totalMentee == 1 ? 'Mentee' : 'Mentees'}",
                                    screenHeight),
                              ],
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
                          for (final deliverable
                              in widget.courseModel.courseDeliverables)
                            _bulletPoint(deliverable, screenHeight),
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
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      mentorCards.isEmpty
                          ? const Center(child: Text('No mentors available'))
                          : Column(children: mentorCards),
                      SizedBox(height: screenHeight * 0.02),
                    ],
                  ),
                );
              },
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
                ? Lottie.asset(
                    'assets/images/loading.json',
                    fit: BoxFit.cover,
                    width: screenHeight * 0.08,
                    height: screenWidth * 0.04,
                    repeat: true,
                ? Lottie.asset(
                    'assets/images/loading.json',
                    fit: BoxFit.cover,
                    width: screenHeight * 0.08,
                    height: screenWidth * 0.04,
                    repeat: true,
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
}
