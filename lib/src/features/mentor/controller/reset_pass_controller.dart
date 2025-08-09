import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voyager/src/repository/authentication_repository_firebase/authentication_repository.dart';

class ResetPassController extends GetxController {
  static ResetPassController get instance => Get.find();

  final initialPassword = TextEditingController();
  final confirmedPassword = TextEditingController();

  final auth = Get.put(FirebaseAuthenticationRepository());

  final isLoading = false.obs;

  Future<void> resetPassword(String passwordText) async {
    try {
      if (initialPassword.text != confirmedPassword.text) {
        if (Get.context != null) {
          ScaffoldMessenger.of(Get.context!).showSnackBar(
            SnackBar(
              content: AwesomeSnackbarContent(
                title: 'Passwords do not match!',
                message: 'Please make sure the passwords match',
                contentType: ContentType.failure,
              ),
              width: MediaQuery.of(Get.context!).size.width,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent, // Makes it seamless
              elevation: 0,
            ),
          );
        }
        return;
      }
      if (passwordText.isEmpty) {
        if (Get.context != null) {
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
        }
        return;
      }
      isLoading.value = true;
      await auth.resetMentorPassword(confirmedPassword);

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
    }
  }

  @override
  void dispose() {
    initialPassword.dispose();
    confirmedPassword.dispose();
    super.dispose();
  }
}
