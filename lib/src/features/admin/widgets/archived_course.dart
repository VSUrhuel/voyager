import 'package:flutter/material.dart';
import 'package:voyager/src/features/admin/widgets/admin_course_card.dart';

class ArchivedCourse extends StatelessWidget {
  final int trialSize;
  const ArchivedCourse({
    super.key,
    required this.trialSize,
    });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < trialSize; i++) 
          AdminCourseCard(),
      ]
    );
  }
}