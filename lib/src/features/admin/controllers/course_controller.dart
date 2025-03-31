import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CourseController extends GetxController {
  static CourseController get instance => Get.find();

  final courseCode = TextEditingController();
  final courseCreatedTimestamp = TextEditingController();
  final courseDeliverables = TextEditingController();
  final courseDescription = TextEditingController();
  final courseImgUrl = TextEditingController();
  final courseModifiedTimestamp = TextEditingController();
  final courseName = TextEditingController();
  final courseSoftDeleted = TextEditingController();
  final courseStatus = TextEditingController();
}
