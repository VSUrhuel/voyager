import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voyager/src/features/admin/models/course_mentor_model.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';

class CourseMentorController extends GetxController {
  static CourseMentorController get instance => Get.find();

  // Use a single, private instance for the repository.
  final _firestore = FirestoreInstance();

  final courseId = TextEditingController();
  final mentorId = TextEditingController();

  @override
  void onClose() {
    // Dispose controllers to prevent memory leaks.
    courseId.dispose();
    mentorId.dispose();
    super.onClose();
  }

  Future<void> createInitialCourseMentor() async {
    try {
      await _firestore.setInitCourseMentor(courseId.text, mentorId.text);
      courseId.clear();
      mentorId.clear();
    } catch (e) {
      // Allow the UI layer to handle the error.
      rethrow;
    }
  }

  Future<void> createCourseMentor(String courseId, String mentorId) async {
    try {
      await _firestore.setCourseMentor(courseId, mentorId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateCourseMentor(String courseMentorId) async {
    try {
      await _firestore.updateCourseMentor(
          courseMentorId, courseId.text, mentorId.text);
      courseId.clear();
      mentorId.clear();
    } catch (e) {
      rethrow;
    }
  }

  // Updated to return a nullable type for safety.
  Future<CourseMentorModel?> findCourseMentorByMentorId(String mentorId) async {
    try {
      // No "!" operator needed, the caller will handle the null case.
      return await _firestore.getCourseMentorThroughMentor(mentorId);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CourseMentorModel>> getCourseMentors(String courseId) async {
    try {
      return await _firestore.getCourseMentorsThroughCourseId(courseId);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> removeMentorFromCourse(
      String courseMentorId, String mentorId) async {
    try {
      // For production, these operations should ideally be wrapped
      // in a transaction or batched write in your repository layer
      // to ensure all succeed or all fail together.
      await _firestore.softDeleteCourseMentor(courseMentorId);
      await _firestore.softDeleteCourseAllocatedMentee(courseMentorId);
      await _firestore.updateMentorStatus(mentorId, 'archived');
      return true;
    } catch (e) {
      // Returning false on failure is a good pattern here.
      return false;
    }
  }
}
