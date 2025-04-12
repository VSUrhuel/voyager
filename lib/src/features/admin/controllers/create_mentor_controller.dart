import 'dart:io';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:voyager/src/repository/authentication_repository_firebase/authentication_repository.dart';
import 'package:voyager/src/repository/authentication_repository_firebase/exceptions/authentication_exceptions.dart';

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
      if (profileImage != null) {
        final File file = File(profileImage!.path);
        SupabaseInstance supabase = SupabaseInstance(Supabase.instance.client);
        final url = await supabase.uploadProfileImage(file);
        await auth.createUserWithoutSignIn(
            email.text, password.text, studentID.text, fullName.text, url);
        profileImage = null;
      } else {
        await auth.createUserWithoutSignIn(
            email.text, password.text, studentID.text, fullName.text, '');
      }

      // if (auth.firebaseUser.value == null) {
      //   isLoading.value = false;
      //   ScaffoldMessenger.of(Get.context!).showSnackBar(
      //     SnackBar(
      //       content: AwesomeSnackbarContent(
      //         title: 'Registration Error',
      //         message: 'User registration failed. Please try again.',
      //         contentType: ContentType.failure,
      //       ),
      //       width: MediaQuery.of(Get.context!).size.width,
      //       behavior: SnackBarBehavior.floating,
      //       backgroundColor: Colors.transparent, // Makes it seamless
      //       elevation: 0,
      //     ),
      //   );
      //   return;
      // }

      // UserModel user = UserModel(
      //   accountApiID:
      //       auth.firebaseUser.value?.uid ?? "", // Use empty string if null
      //   accountApiEmail:
      //       auth.firebaseUser.value?.email ?? "", // Provide a default
      //   accountApiName: fullName.text,
      //   accountApiPhoto:
      //       auth.firebaseUser.value?.photoURL ?? "", // Handle null safely
      //   accountPassword: password,
      //   accountUsername: auth.firebaseUser.value?.displayName ??
      //       "Unknown", // Provide default username
      //   accountRole: UserRoleEnum.mentor,
      //   accountStudentId: studentID.text,
      //   accountCreatedTimestamp: DateTime.now(),
      //   accountModifiedTimestamp: DateTime.now(),
      //   accountSoftDeleted: false,
      // );

      // firestore.setUser(user);
      // Get.offAll(() => EmailVerification());
      //  Get.offAll(() => AdminDashboard());
      isLoading.value = false;
      // studentID.clear();
      // fullName.clear();
      // email.clear();
      // password.clear();
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
}
