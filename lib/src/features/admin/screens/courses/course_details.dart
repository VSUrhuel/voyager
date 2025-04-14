import 'package:flutter/material.dart';
import 'package:voyager/src/features/admin/models/course_mentor_model.dart';
import 'package:voyager/src/features/admin/screens/mentors/mentor_list.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentee/model/course_model.dart';
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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      // 1. Get all mentees for this course (accepted status)
      final menteeList = await firestoreInstance.getMenteeAccountsForCourse(
          widget.courseModel.docId, 'accepted');
      
      // 2. For each courseMentor, get their specific mentees
      List<MenteesOfMentor> mentorMenteesList = [];
      
      for (var courseMentor in widget.courseMentors) {
        // Get the mentor's user data
        final mentorAccountId = await firestoreInstance.getMentorAccountId(courseMentor.mentorId);
        final mentorUser = await firestoreInstance.getUserThroughAccId(mentorAccountId);
        
        // Get mentees assigned to this specific courseMentor relationship
        final mentees = await firestoreInstance.getMenteesThroughCourseMentor(courseMentor.courseMentorId);
        
        mentorMenteesList.add(MenteesOfMentor(
          mentees: mentees,
          courseMentorId: courseMentor.courseMentorId,
          mentorUser: mentorUser,
        ));
      }
      setState(() {
        allCourseMentees = menteeList;
        menteesByMentor = mentorMenteesList;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print('Error loading data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
          'Course Details',
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
                        image: widget.courseModel.courseImgUrl.isEmpty
                            ? AssetImage(
                                    'assets/images/application_images/code.jpg')
                                as ImageProvider
                            : NetworkImage(widget.courseModel.courseImgUrl),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _infoItem(Icons.access_time, '1 Semester', screenHeight),
                        _infoItem(
                            Icons.groups,
                            "${widget.courseMentors.length} Mentor(s)",
                            screenHeight),
                        _infoItem(Icons.people, "${allCourseMentees.length} Mentee(s)",
                            screenHeight),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Text(
                    "Course Title",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenHeight * 0.022,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Text(
                    "${widget.courseModel.courseCode}: ${widget.courseModel.courseName}",
                    style: TextStyle(fontSize: screenHeight * 0.018),
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
                    "What Mentees will Learn:",
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
                        _bulletPoint(
                            widget.courseModel.courseDeliverables[i], screenHeight),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Assigned Mentors",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenHeight * 0.022,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => MentorList(),
                          ));
                        },
                        child: Text(
                          "Edit Mentors",
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
                  SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: screenWidth * 0.05,
                        right: screenWidth * 0.05,
                      ),
                      child: Column(
                        children: [
                          if (widget.courseMentors.isEmpty)
                            const Text('No mentors available')
                          else
                            for (var mentorData in menteesByMentor)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Mentor: ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: screenHeight * 0.017,
                                        ),
                                      ),
                                      Text(
                                        mentorData.mentorUser.accountApiName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: screenHeight * 0.017,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: screenHeight * 0.005),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Mentees:",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: screenHeight * 0.017,
                                        ),
                                      ),
                                      if (mentorData.mentees.isEmpty)
                                        Text(
                                          'No mentees assigned',
                                          style: TextStyle(fontSize: screenHeight * 0.017),
                                        )
                                      else
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            for (var mentee in mentorData.mentees)
                                              _bulletPoint(mentee.accountApiName, screenHeight),
                                          ],
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: screenHeight * 0.02),
                                ],
                              ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                ],
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