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

  // Service Instances
  final _firestore = FirestoreInstance();
  final _supabase = SupabaseInstance(Supabase.instance.client);

  // Reactive state variables
  final activeCourses = <CourseModel>[].obs;
  final archivedCourses = <CourseModel>[].obs;
  final allCourses = <CourseModel>[].obs;
  final isLoading = false.obs;
  XFile? courseImage;

  // Text editing controllers for the form
  final courseCode = TextEditingController();
  final courseDeliverables = <String>[].obs;
  final courseDescription = TextEditingController();
  final courseName = TextEditingController();

  @override
  void onClose() {
    // Dispose controllers to prevent memory leaks
    courseCode.dispose();
    courseDescription.dispose();
    courseName.dispose();
    super.onClose();
  }

  void addCourseDeliverable(String deliverable) {
    if (deliverable.isNotEmpty) {
      courseDeliverables.add(deliverable);
    }
  }

  void removeCourseDeliverable(String deliverable) {
    if (courseDeliverables.contains(deliverable)) {
      courseDeliverables.remove(deliverable);
    } else {
      Get.snackbar("Error", "Deliverable not found.");
    }
  }

Future<void> createCourse() async {
    try {
      isLoading.value = true;
      String imageUrl = '';

      if (courseImage != null) {
        final file = File(courseImage!.path);
        imageUrl = await _supabase.uploadCourseImage(file) as String;
      }

      final newCourse = CourseModel(
        docId: '', // Firestore will generate this
        courseCode: courseCode.text,
        courseCreatedTimestamp: DateTime.now(),
        courseDeliverables: courseDeliverables.toList(),
        courseDescription: courseDescription.text,
        courseImgUrl: imageUrl,
        courseModifiedTimestamp: DateTime.now(),
        courseName: courseName.text,
        courseSoftDelete: false,
        courseStatus: 'active',
      );

      // Call the void function without trying to assign its result.
      await _firestore.setCourse(newCourse);

      // Re-fetch all courses from the server to get the updated list,
      // including the newly created course with its correct docId.
      await fetchAllCourses();

      Get.back();
      Get.snackbar("Success", "Course created successfully.");
    } catch (e) {
      Get.snackbar("Error", "Failed to create course: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  // Optimized to use a single database read
  Future<void> fetchAllCourses() async {
    try {
      isLoading.value = true;
      final courses = await _firestore.getCourses();
      allCourses.assignAll(courses);

      // Populate other lists from the main list in memory
      activeCourses.assignAll(
          courses.where((course) => course.courseStatus == 'active').toList());
      archivedCourses.assignAll(courses
          .where((course) => course.courseStatus == 'archived')
          .toList());
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch courses: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> archiveCourse(String courseId) async {
    try {
      isLoading.value = true;
      await _firestore.archiveCourse(courseId);

      // Update local state without re-fetching from the database
      final courseIndex = allCourses.indexWhere((c) => c.docId == courseId);
      if (courseIndex != -1) {
        final course = allCourses[courseIndex];
        course.courseStatus = 'archived';
        allCourses[courseIndex] = course; // Trigger update
        activeCourses.removeWhere((c) => c.docId == courseId);
        archivedCourses.insert(0, course);
      }

      Get.snackbar("Success", "Course archived successfully.");
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
      await _firestore.unarchiveCourse(courseId);

      // Update local state without re-fetching
      final courseIndex = allCourses.indexWhere((c) => c.docId == courseId);
      if (courseIndex != -1) {
        final course = allCourses[courseIndex];
        course.courseStatus = 'active';
        allCourses[courseIndex] = course; // Trigger update
        archivedCourses.removeWhere((c) => c.docId == courseId);
        activeCourses.insert(0, course);
      }

      Get.snackbar("Success", "Course restored successfully.");
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
      await _firestore.deleteCourse(courseId);

      // Update local state without re-fetching
      allCourses.removeWhere((c) => c.docId == courseId);
      activeCourses.removeWhere((c) => c.docId == courseId);
      archivedCourses.removeWhere((c) => c.docId == courseId);

      Get.snackbar("Success", "Course deleted successfully.");
      return true;
    } catch (e) {
      Get.snackbar("Error", "Failed to delete course: ${e.toString()}");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void clearForm() {
    courseCode.clear();
    courseDeliverables.clear();
    courseDescription.clear();
    courseName.clear();
    courseImage = null;
  }
}
