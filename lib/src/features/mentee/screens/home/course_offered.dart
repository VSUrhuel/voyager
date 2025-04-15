import 'package:firebase_auth/firebase_auth.dart';
import 'package:voyager/src/features/mentee/controller/notification_controller.dart';
import 'package:voyager/src/features/mentee/model/course_model.dart';
import 'package:voyager/src/features/mentee/widgets/course_card.dart';
import 'package:voyager/src/features/mentee/widgets/normal_search_bar.dart';
import 'package:voyager/src/features/mentee/widgets/small_course_card.dart';
import 'package:flutter/material.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';

class CourseOffered extends StatefulWidget {
  const CourseOffered({super.key});

  @override
  State<CourseOffered> createState() => _CourseOfferedState();
}

class _CourseOfferedState extends State<CourseOffered> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  bool _isSearching = false;

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

  Future<List<CourseModel>> fetchCoursesWithDetails(String userEmail) async {
    try {
      FirestoreInstance firestoreInstance = FirestoreInstance();
      final notificationController = NotificationController();
      final menteeId =
          await notificationController.getUserIdThroughEmail(userEmail);
      final enrolledCourseMentorIds =
          await notificationController.getCourseMentorIdsForMentee(menteeId);
      List<CourseModel> enrolledCourses = [];
      for (String mentorId in enrolledCourseMentorIds) {
        final course =
            await firestoreInstance.getMentorCourseThroughId(mentorId);
        if (course != null) {
          enrolledCourses.add(course);
        }
      }
      final List<CourseModel> allCourses = await firestoreInstance.getCourses();
      final List<String> enrolledCourseNames =
          enrolledCourses.map((course) => course.courseName).toList();

      List<CourseModel> availableCourses = allCourses.where((course) {
        return !enrolledCourseNames.contains(course.courseName) &&
            course.courseSoftDelete == false &&
            course.courseStatus == 'active';
      }).toList();

      if (_isSearching) {
        availableCourses = availableCourses.where((course) {
          return course.courseName
              .toLowerCase()
              .contains(_searchText.toLowerCase());
        }).toList();
      }

      return availableCourses;
    } catch (e) {
      print("❌ Error fetching courses with details: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    FirestoreInstance firestoreInstance = FirestoreInstance();
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
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
                    left: screenWidth * 0.05, right: screenWidth * 0.05),
                child: Center(
                  child: FutureBuilder<List<CourseModel>>(
                    future: fetchCoursesWithDetails(user?.email ?? ''),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError ||
                          !snapshot.hasData ||
                          snapshot.data!.isEmpty) {
                        return Center(child: Text("No courses available"));
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
    );
  }
}
