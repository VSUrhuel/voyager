import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';

class AdminMentorController extends GetxController {
  static AdminMentorController get instance => Get.find();

  final mentorId = TextEditingController();
  final mentorName = TextEditingController();
  final mentorEmail = TextEditingController();
  final mentorPhone = TextEditingController();
  final mentorRegDay = TextEditingController();
  final mentorRegTime = TextEditingController();
  final mentorStatus = TextEditingController();

 Future<void> updateMentorStatus(String mentorId, String status) async{
  try{
    FirestoreInstance firestoreInstance = FirestoreInstance();
    await firestoreInstance.updateMentorStatus(mentorId, status);
  }catch (e){
    throw Exception('Failed to update mentor status: $e');
  }
 }

}