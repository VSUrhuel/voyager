import 'package:flutter/material.dart';
import 'package:voyager/src/features/admin/widgets/admin_course_card.dart';

class ActiveCourse extends StatelessWidget {
  // final String status;
  final int trialSize;
  const ActiveCourse({
    super.key,
    // this.status = 'active',  
    required this.trialSize,
    });

  @override
  Widget build(BuildContext context) {
    return Column(
        children:[
          for (int i = 0; i < trialSize; i++) 
            AdminCourseCard(),
        ]
      
    );
  }
}