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
      final Timestamp createdTimestamp = Timestamp.now();


      // 1. Get courseMentorId using courseId and mentorId
      final courseMentorSnapshot = await firestore
          .collection('courseMentor')
          .where('courseId', isEqualTo: widget.courseModel.docId)
          .where('courseMentorSoftDeleted', isEqualTo: false)
          .get();

      if (courseMentorSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Course is not available for enrollment')),
        );
        return;
      }

      final courseMentorId = courseMentorSnapshot.docs.first.id;

      // 2. Check if mentee already exists
      final existingMenteeSnapshot = await firestore
          .collection('mentee')
          .where('accountId', isEqualTo: widget.userId)
          .where('menteeSoftDelete', isEqualTo: false)
          .get();

      DocumentReference menteeRef;
      String menteeId;

      if (existingMenteeSnapshot.docs.isNotEmpty) {
        // Use existing mentee
        menteeRef = existingMenteeSnapshot.docs.first.reference;
        menteeId = existingMenteeSnapshot.docs.first.id;
      } else {
        // Create new mentee
        final newMentee = await firestore.collection('mentee').add({
          'accountId': widget.userId,
          'menteeMcaId': [],
          'menteeSoftDelete': false,
        });
        menteeRef = newMentee;
        menteeId = newMentee.id;
      }

      // 3. Add new menteeCourseAlloc document
      final menteeCourseAllocRef =
          await firestore.collection('menteeCourseAlloc').add({
        'courseMentorId': courseMentorId,
        'mcaAllocStatus': 'pending',
        'mcaCreatedTimestamp': createdTimestamp,
        'mcaSoftDeleted': false,
        'menteeId': menteeId,
      });

      // 4. Append the new menteeMcaId to the mentee document
      await menteeRef.update({
        'menteeMcaId': FieldValue.arrayUnion([menteeCourseAllocRef.id])

      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully enrolled in the course!')),
      );

      if (mounted) {

        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error enrolling in the course: $e')),
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
          : FutureBuilder<List<PickMentorCard>>(
              future: fetchMentorsWithDetails(),
              builder: (context, mentorCardSnapshot) {
                if (mentorCardSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final mentorCards = mentorCardSnapshot.data ?? [];

                return SingleChildScrollView(
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
                          horizontal: screenWidth * 0.05,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(16),
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
                                    "${fetchedUsers.length} Mentors",
                                    screenHeight),
                                _infoItem(Icons.people, "$totalMentee Mentees",
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
                          TextButton(
                            onPressed: () {},
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
                      mentorCards.isEmpty
                          ? const Center(child: Text('No mentors available'))
                          : Column(children: mentorCards),
                      SizedBox(height: screenHeight * 0.03),
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
