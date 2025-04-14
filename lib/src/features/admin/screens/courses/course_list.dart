import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:voyager/src/features/admin/controllers/course_controller.dart';
import 'package:voyager/src/features/admin/controllers/course_mentor_controller.dart';
import 'package:voyager/src/features/admin/models/course_mentor_model.dart';
import 'package:voyager/src/features/admin/screens/courses/add_course.dart';
import 'package:voyager/src/features/admin/widgets/admin_course_card.dart';
import 'package:voyager/src/features/admin/widgets/admin_search_bar.dart';
import 'package:voyager/src/features/mentee/model/course_model.dart';

class CourseList extends StatefulWidget {
  const CourseList({super.key});

  @override
  State<CourseList> createState() => _CourseListState();
}

class _CourseListState extends State<CourseList> {
  String show = 'active';
  String searchQuery = '';
  final CourseController courseController = Get.put(CourseController());

  @override
  void initState() {
    super.initState();
    courseController.fetchActiveCourses();
    courseController.fetchArchivedCourses();
  }

  void refreshCourses() {
    if (show == 'active') {
      courseController.fetchActiveCourses();
    } else {
      courseController.fetchArchivedCourses();
    }
  }

  List<CourseModel> _filterCourses(List<CourseModel> courses) {
    if (searchQuery.isEmpty) return courses;
    return courses
        .where((course) =>
            course.courseName
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            course.courseDescription
                .toLowerCase()
                .contains(searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Course List',
          style: TextStyle(
            color: Colors.black,
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              SizedBox(
                height: screenHeight * 0.09,
                child: AdminSearchbar(
                  onSearchChanged: (query) {
                    setState(() {
                      searchQuery = query;
                    });
                  },
                ),
              ),

              // Toggle buttons
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Row(
                  children: [
                    // Active Button
                    SizedBox(
                      height: screenHeight * 0.038,
                      width: screenWidth * 0.22,
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            show = 'active';
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: show == 'active'
                              ? const Color(0xFF7eb3f7)
                              : const Color(0xFFa6a2a2),
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          textStyle: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w600,
                          ),
                          side: BorderSide.none,
                          foregroundColor: show == 'active'
                              ? const Color(0xFF0765e0)
                              : const Color(0xFF4A4A4A),
                        ),
                        child: const Text('Active'),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),

                    // Archived Button
                    SizedBox(
                      height: screenHeight * 0.038,
                      width: screenWidth * 0.22,
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            show = 'archived';
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: show == 'archived'
                              ? const Color(0xFF7eb3f7)
                              : const Color(0xFFa6a2a2),
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          textStyle: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w600,
                          ),
                          side: BorderSide.none,
                          foregroundColor: show == 'archived'
                              ? const Color(0xFF0765e0)
                              : const Color(0xFF4A4A4A),
                        ),
                        child: const Text('Archived'),
                      ),
                    ),
                    const Spacer(),

                    // Add Course Button
                    SizedBox(
                      height: screenHeight * 0.035,
                      child: IconButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddCourse(),
                            ),
                          );
                          refreshCourses(); // Refresh after returning from AddCourse
                        },
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.add),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),

          // Course List Section
          Expanded(
            child: Obx(() {
              if (courseController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final courses = show == 'active'
                  ? courseController.activeCourses
                  : courseController.archivedCourses;

              final filteredCourses = _filterCourses(courses);

              return RefreshIndicator(
                onRefresh: () async => refreshCourses(),
                child: filteredCourses.isEmpty
                    ? SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: screenHeight * 0.8,
                          child: Center(child: Text('No $show courses found')),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.05,
                        ),
                        child: Column(
                          children: [
                            if (show == 'active')
                              ...filteredCourses.map((course) =>
                                  FutureBuilder<List<CourseMentorModel>>(
                                    future: CourseMentorController()
                                        .getCourseMentors(course.docId),
                                    builder: (context, snapshot) {
                                      // if (snapshot.connectionState == ConnectionState.waiting) {
                                      //   return const CircularProgressIndicator();
                                      // }
                                      if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
                                      }
                                      final mentors = snapshot.data ?? [];

                                      return AdminCourseCard(
                                        course: course,
                                        onUpdate: refreshCourses,
                                        courseMentors: mentors,
                                      );
                                    },
                                  )),
                            if (show == 'archived')
                              ...filteredCourses.map((course) =>
                                  FutureBuilder<List<CourseMentorModel>>(
                                    future: CourseMentorController()
                                        .getCourseMentors(course.docId),
                                    builder: (context, snapshot) {
                                      // if (snapshot.connectionState == ConnectionState.waiting) {
                                      //   return const CircularProgressIndicator();
                                      // }
                                      if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
                                      }
                                      final mentors = snapshot.data ?? [];

                                      return AdminCourseCard(
                                        course: course,
                                        onUpdate: refreshCourses,
                                        courseMentors: mentors,
                                      );
                                    },
                                  )),
                          ],
                        ),
                      ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
