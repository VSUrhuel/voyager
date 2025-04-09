import 'package:voyager/src/features/mentee/model/course_model.dart';
import 'package:voyager/src/features/mentee/widgets/normal_search_bar.dart';
import 'package:voyager/src/features/mentee/widgets/small_course_card.dart';
import 'package:flutter/material.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';

class CourseOffered extends StatelessWidget {
  const CourseOffered({super.key});

  Future<List<CourseModel>> fetchCoursesWithDetails() async {
    FirestoreInstance firestoreInstance = FirestoreInstance();
    List<CourseModel> courses = await firestoreInstance.getCourses();
    return courses;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
          NormalSearchbar(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                    left: screenWidth * 0.05, right: screenWidth * 0.05),
                child: Center(
                  child: FutureBuilder<List<CourseModel>>(
                    future: fetchCoursesWithDetails(),
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
