// ignore_for_file: unused_field

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:voyager/src/features/mentee/model/course_model.dart';
import 'package:voyager/src/features/mentee/screens/session/upcoming_card.dart';
import 'package:voyager/src/features/mentee/widgets/normal_search_bar.dart';
import 'package:voyager/src/features/mentee/widgets/small_course_card.dart';
import 'package:flutter/material.dart';

class CourseOffered extends StatefulWidget {
  const CourseOffered({super.key});

  @override
  State<CourseOffered> createState() => _CourseOfferedState();
}

class _CourseOfferedState extends State<CourseOffered> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  bool _isSearching = false;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
        _isSearching = _searchText.isNotEmpty;
      });
    });
  }

  Future<String?> getUserIdThroughEmail(String email) async {
    try {
      final userSnapshot = await _db
          .collection('users')
          .where('accountApiEmail', isEqualTo: email)
          .get();

      if (userSnapshot.docs.isEmpty) {
        return null;
      }

      final userId = userSnapshot.docs.first.id;

      final menteeSnapshot = await _db
          .collection('mentee')
          .where('accountId', isEqualTo: userId)
          .get();

      if (menteeSnapshot.docs.isEmpty) {
        return null;
      }

      return menteeSnapshot.docs.first.id;
    } catch (e) {
      throw Exception("❌ Error in getUserIdThroughEmail: $e");
    }
  }

  Future<List<String>> getCourseMentorIdsForMentee(String menteeId) async {
    try {
      final allocations = await _db
          .collection('menteeCourseAlloc')
          .where('menteeId', isEqualTo: menteeId)
          .where('mcaSoftDeleted', isEqualTo: false)
          .get();

      return allocations.docs
          .map((doc) => doc.data()['courseMentorId'] as String)
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Fetch courses with details (similar to fetching mentors)
  Future<List<CourseModel>> fetchCoursesWithDetails(String userEmail) async {
    try {
      final menteeId = await getUserIdThroughEmail(userEmail);
      final List<CourseModel> allCourses = await firestoreInstance.getCourses();

      List<CourseModel> availableCourses;

      if (menteeId == null || menteeId.isEmpty) {
        // If no menteeId, return all active and non-soft-deleted courses
        availableCourses = allCourses.where((course) {
          return course.courseSoftDelete == false &&
              course.courseStatus == 'active';
        }).toList();
      } else {
        final enrolledCourseMentorIds =
            await getCourseMentorIdsForMentee(menteeId);

        List<CourseModel> enrolledCourses = [];
        for (String mentorId in enrolledCourseMentorIds) {
          final course =
              await firestoreInstance.getMentorCourseThroughId(mentorId);
          if (course != null) {
            enrolledCourses.add(course);
          }
        }

        final List<String> enrolledCourseNames =
            enrolledCourses.map((course) => course.courseName).toList();
        availableCourses = allCourses.where((course) {
          return !enrolledCourseNames.contains(course.courseName) &&
              course.courseSoftDelete == false &&
              course.courseStatus == 'active';
        }).toList();
      }
      return availableCourses;
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    User? user = FirebaseAuth.instance.currentUser;

    return SafeArea(
        bottom: true,
        top: false,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1.0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text(
              'Courses Offered',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.normal,
                fontSize: 18.0,
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              NormalSearchbar(searchController: _searchController),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: screenWidth * 0.05,
                        right: screenWidth * 0.05,
                        bottom: screenHeight * 0.04),
                    child: Center(
                      child: FutureBuilder<List<CourseModel>>(
                        future: fetchCoursesWithDetails(user?.email ?? ''),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
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
                          if (snapshot.hasError ||
                              !snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return SingleChildScrollView(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  top: 100.0,
                                  left: screenWidth * 0.05,
                                  right: screenWidth * 0.05,
                                ),
                                child: Center(
                                  child: Text(
                                    "No courses available",
                                    style: TextStyle(
                                        fontSize: 16.0, color: Colors.grey),
                                  ),
                                ),
                              ),
                            );
                          }

                          return Column(
                            children: List.generate(
                              snapshot.data!.length,
                              (index) => SmallCourseCard(
                                  courseModel: snapshot.data![index]),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
