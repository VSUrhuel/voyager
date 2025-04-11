import 'package:flutter/material.dart';
import 'package:voyager/src/features/admin/widgets/admin_course_card.dart';
import 'package:voyager/src/features/mentee/model/course_model.dart';

class ActiveCourse extends StatelessWidget {
  // final String status;
  final List<CourseModel> courses;
  const ActiveCourse({
    super.key,
    // this.status = 'active',  
    required this.courses,
    });

  @override
  Widget build(BuildContext context) {
    return Column(
        children:[
          for (int i = 0; i < courses.length; i++) 
            AdminCourseCard(course: courses[i]),
        ]
      
    );
  }
}