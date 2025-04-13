import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:voyager/src/features/mentee/model/course_model.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:voyager/src/repository/supabase_repository/supabase_instance.dart';

class CourseController extends GetxController {
  static CourseController get instance => Get.find();

  // Reactive lists for courses
  final activeCourses = <CourseModel>[].obs;
  final archivedCourses = <CourseModel>[].obs;
  final allCourses = <CourseModel>[].obs;
  final isLoading = false.obs;
   XFile? courseImage;

  // Text controllers
  final courseCode = TextEditingController();
  final courseDeliverables = <String>[].obs;
  final courseDescription = TextEditingController();
  final courseImgUrl = TextEditingController();
  final courseName = TextEditingController();
  final courseStatus = TextEditingController();

  void addCourseDeliverable(String deliverable) {
    courseDeliverables.add(deliverable);
  }

  void removeCourseDeliverable(String deliverable) {
    if (courseDeliverables.isNotEmpty) {
      courseDeliverables.remove(deliverable);
    } else {
      Get.snackbar("Error", "No deliverables to remove");
    }
  }

  Future<void> createCourse() async {
    try {
      isLoading.value = true;
      String? url = '';
      
      if (courseImage != null) {
        final File file = File(courseImage!.path);
        final supabase = SupabaseInstance(Supabase.instance.client);
        url = await supabase.uploadCourseImage(file);
      }

      final course = CourseModel(
        docId: '',
        courseCode: courseCode.text,
        courseCreatedTimestamp: DateTime.now(),
        courseDeliverables: courseDeliverables.toList(),
        courseDescription: courseDescription.text,
        courseImgUrl: url ?? '',
        courseModifiedTimestamp: DateTime.now(),
        courseName: courseName.text,
        courseSoftDelete: false,
        courseStatus: 'active',
      );

      final firestoreInstance = FirestoreInstance();
      await firestoreInstance.setCourse(course);
      
      // Refresh all course lists after creation
      await fetchAllCourses();
      Get.back(); // Close the add course screen
      Get.snackbar("Success", "Course created successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to create course: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchActiveCourses() async {
    try {
      isLoading.value = true;
      final firestoreInstance = FirestoreInstance();
      final courses = await firestoreInstance.getActiveCourses();
      activeCourses.assignAll(courses);
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch active courses: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchArchivedCourses() async {
    try {
      isLoading.value = true;
      final firestoreInstance = FirestoreInstance();
      final courses = await firestoreInstance.getArchivedCourses();
      archivedCourses.assignAll(courses);
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch archived courses: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAllCourses() async {
    try {
      isLoading.value = true;
      final firestoreInstance = FirestoreInstance();
      final courses = await firestoreInstance.getCourses();
      allCourses.assignAll(courses);
      
      // Also update active and archived courses
      await fetchActiveCourses();
      await fetchArchivedCourses();
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch courses: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> archiveCourse(String courseId) async {
    try {
      isLoading.value = true;
      final firestoreInstance = FirestoreInstance();
      await firestoreInstance.archiveCourse(courseId);
      await fetchAllCourses();
      Get.snackbar("Success", "Course archived successfully");
      return true;
    } catch (e) {
      Get.snackbar("Error", "Failed to archive course: ${e.toString()}");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> restoreCourse(String courseId) async {
    try {
      isLoading.value = true;
      final firestoreInstance = FirestoreInstance();
      await firestoreInstance.unarchiveCourse(courseId);
      await fetchAllCourses();
      Get.snackbar("Success", "Course restored successfully");
      return true;
    } catch (e) {
      Get.snackbar("Error", "Failed to restore course: ${e.toString()}");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteCourse(String courseId) async {
    try {
      isLoading.value = true;
      final firestoreInstance = FirestoreInstance();
      await firestoreInstance.deleteCourse(courseId);
      await fetchAllCourses();
      Get.snackbar("Success", "Course deleted successfully");
      return true;
    } catch (e) {
      Get.snackbar("Error", "Failed to delete course: ${e.toString()}");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Clear form fields
  void clearForm() {
    courseCode.clear();
    courseDeliverables.clear();
    courseDescription.clear();
    courseImgUrl.clear();
    courseName.clear();
    courseStatus.clear();
    courseImage = null;
  }

  @override
  void onClose() {
    courseCode.dispose();
    courseDescription.dispose();
    courseImgUrl.dispose();
    courseName.dispose();
    courseStatus.dispose();
    super.onClose();
  }
}