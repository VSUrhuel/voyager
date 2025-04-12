import 'dart:io';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:voyager/src/features/admin/screens/admin_dashboard.dart';

import 'package:voyager/src/features/authentication/controllers/user_role_enum.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/authentication/screens/email_verification/email_verification.dart';
import 'package:voyager/src/repository/authentication_repository_firebase/authentication_repository.dart';
import 'package:voyager/src/repository/authentication_repository_firebase/exceptions/authentication_exceptions.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voyager/src/repository/supabase_repository/supabase_instance.dart';


class CreateMentorController extends GetxController {
  static CreateMentorController get instance => Get.find();

  final studentID = TextEditingController();
  final fullName = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  XFile? profileImage;

  final auth = Get.put(FirebaseAuthenticationRepository());

  final isLoading = false.obs;



  Future<bool> registerUser() async {
    try {
      if (email.text.isEmpty ||
          password.text.isEmpty ||
          fullName.text.isEmpty ||
          studentID.text.isEmpty) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: AwesomeSnackbarContent(
              title: 'Missing Fields!',
              message: 'Please fill in all fields',
              contentType: ContentType.failure,
            ),
            width: MediaQuery.of(Get.context!).size.width,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent, // Makes it seamless
            elevation: 0,
          ),
        );

        return false;
      }
      isLoading.value = true;
      // final firestore = FirestoreInstance();
      if(profileImage!=null){
        final File file = File(profileImage!.path);
        SupabaseInstance supabase = SupabaseInstance(Supabase.instance.client);
        final url = await supabase.uploadProfileImage(file);
        await auth.createUserWithoutSignIn(email.text, password.text, studentID.text, fullName.text, url);
        profileImage = null;
      }else{
        await auth.createUserWithoutSignIn(email.text, password.text, studentID.text, fullName.text, '');
      }
 
      isLoading.value = false;
      return true;
    } on AuthenticationExceptions catch (e) {
      isLoading.value = false;
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: AwesomeSnackbarContent(
              title: 'Registration Error',
              message: e.message,
              contentType: ContentType.failure,
              color: Colors.red),
          width: MediaQuery.of(Get.context!).size.width,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent, // Makes it seamless
          elevation: 0,
        ),
      );
      return false;
    } finally {
      isLoading.value = false;

    }
  }


  Future<void> updateMentorStatus(String mentorId, String status) async {
    try {
      isLoading.value = true;
      final firestore = FirestoreInstance();
      await firestore.updateMentorStatus(mentorId, status);
      Get.snackbar("Success", "Mentor status updated successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to update mentor status: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> deleteMentor(String mentorId) async {
    try {
      isLoading.value = true;
      final firestore = FirestoreInstance();
      await firestore.deleteMentor(mentorId);
      Get.snackbar("Success", "Mentor deleted successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to delete mentor: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

}