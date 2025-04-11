//coursecontroller

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:googleapis/classroom/v1.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:voyager/src/features/mentee/model/course_model.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:voyager/src/repository/supabase_repository/supabase_instance.dart';

class CourseController extends GetxController {
  static CourseController get instance => Get.find();
  List<CourseModel> courses = [];
  bool isLoading = false;
  XFile? courseImage;


  final courseCode = TextEditingController();
  // final courseCreatedTimestamp = TextEditingController();
  final courseDeliverables = <String>[].obs;
  final courseDescription = TextEditingController();
  final courseImgUrl = TextEditingController();
  // final courseModifiedTimestamp = TextEditingController();
  final courseName = TextEditingController();
  // final courseSoftDeleted = TextEditingController();
  final courseStatus = TextEditingController();

void addCourseDeliverable(String deliverable) {
      courseDeliverables.add(deliverable);
  }

void removeCourseDeliverable(String deliverable) {
  if(courseDeliverables.isNotEmpty){
    courseDeliverables.remove(deliverable);
  }
  else{
    Get.snackbar("Error", "No deliverables to remove");
  }
}

  Future<void> createCourse() async {
    String? url = '';
    FirestoreInstance firestoreInstance = FirestoreInstance();
    if(courseImage != null){
    final File file = File(courseImage!.path);
    SupabaseInstance supabase = SupabaseInstance(Supabase.instance.client);
     url = await supabase.uploadCourseImage(file);
    }

    CourseModel course = CourseModel(
      docId: '',
      courseCode: courseCode.text,
      courseCreatedTimestamp: DateTime.now(),
      courseDeliverables: courseDeliverables.toList(),
      courseDescription: courseDescription.text,
      courseImgUrl: url?? '',
      courseModifiedTimestamp: DateTime.now(),
      courseName: courseName.text,
      courseSoftDelete: false,
      courseStatus: 'active',
    );
    await firestoreInstance.setCourse(course);
  }

  Future<List<CourseModel>> fetchActiveCourses() async {
    FirestoreInstance firestoreInstance = FirestoreInstance();
    
    if(courses.isNotEmpty){
      return courses;
    }else{
    isLoading = true;
    courses = await firestoreInstance.getActiveCourses();
    isLoading = false;
    return courses;
    }
  }

    Future<List<CourseModel>> fetchArchivedCourses() async {
    FirestoreInstance firestoreInstance = FirestoreInstance();
  
    if(courses.isNotEmpty){
      return courses;
    }else{
      isLoading = true;
      courses = await firestoreInstance.getArchivedCourses();
      isLoading = false;
      return courses;
    }
  }

    Future<List<CourseModel>> fetchAllCourses() async {
    FirestoreInstance firestoreInstance = FirestoreInstance();
  
    if(courses.isNotEmpty){
      return courses;
    }else{
      isLoading=true;
     courses = await firestoreInstance.getCourses();
     isLoading=false;
     return courses;
    }
  }

}
