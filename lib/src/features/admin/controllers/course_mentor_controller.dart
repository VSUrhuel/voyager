
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voyager/src/features/admin/models/course_mentor_model.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';

class CourseMentorController extends GetxController {
  static CourseMentorController get instance => Get.find();

final courseId = TextEditingController();
  final mentorId = TextEditingController();

Future<void> createInitialCourseMentor() async {
    FirestoreInstance firestoreInstance = FirestoreInstance();
    await firestoreInstance.setInitCourseMentor(courseId.text, mentorId.text);
    courseId.clear();
    mentorId.clear();
}

Future<void> createCourseMentor(String courseId, String mentorId) async {
    FirestoreInstance firestoreInstance = FirestoreInstance();
    await firestoreInstance.setCourseMentor(courseId, mentorId);
  }

Future<void> updateCourseMentor(String courseMentorId) async {
    FirestoreInstance firestoreInstance = FirestoreInstance();
    await firestoreInstance.updateCourseMentor(
        courseMentorId, courseId.text, mentorId.text);
    courseId.clear();
    mentorId.clear();
}

Future<CourseMentorModel> findCourseMentorByMentorId(String mentorId) async {
    FirestoreInstance firestoreInstance = FirestoreInstance();
    CourseMentorModel? courseMentor =
        await firestoreInstance.getCourseMentorThroughMentor(mentorId);
    return courseMentor!;
  }

Future<List<CourseMentorModel>> getCourseMentors(String courseId) async {
    FirestoreInstance firestoreInstance = FirestoreInstance();
    List<CourseMentorModel> courseMentors =
        await firestoreInstance.getCourseMentorsThroughCourseId(courseId);
    return courseMentors;
  }

Future<bool> removeMentorFromCourse(
      String courseMentorId, String mentorId) async {
    FirestoreInstance firestoreInstance = FirestoreInstance();
    try {
      await firestoreInstance.softDeleteCourseMentor(courseMentorId);
      await firestoreInstance.softDeleteCourseAllocatedMentee(courseMentorId);
      await firestoreInstance.updateMentorStatus(mentorId, 'archived');
      return true;
    } catch (e) {
      return false;
    }
 

}

}
