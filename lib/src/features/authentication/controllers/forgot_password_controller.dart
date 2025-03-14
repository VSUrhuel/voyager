import 'package:voyager/src/features/authentication/screens/login_screen/login_screen.dart';
import 'package:voyager/src/repository/authentication-repository/supabase_auth_repository.dart';
import 'package:voyager/src/repository/exceptions/authentication_exceptions.dart';
import 'package:voyager/src/widgets/custom_page_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart'
    show AwesomeSnackbarContent, ContentType;

class ForgotPasswordController extends GetxController {
  static ForgotPasswordController get instance => Get.find();

  final email = TextEditingController();
  final isLoading = false.obs;

  String convertCodeToTitle(String code) {
    return code.replaceAll('_', ' ').split(' ').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  void sendPasswordResetEmail(String email) async {
    try {
      if (email.isEmpty) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: AwesomeSnackbarContent(
              title: 'Oh Snap!',
              message: 'Please fill in all fields',
              contentType: ContentType.failure,
              color: Colors.red,
            ),
            width: MediaQuery.of(Get.context!).size.width,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent, // Makes it seamless
            elevation: 0,
          ),
        );

        return;
      }
      isLoading.value = true;
      await AuthenticationRepository.instance.sendPasswordResetEmail(email);
      isLoading.value = false;
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: AwesomeSnackbarContent(
            title: 'Check your email',
            message: 'Password reset email sent',
            contentType: ContentType.help,
            color: Colors.blue,
          ),
          width: MediaQuery.of(Get.context!).size.width,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent, // Makes it seamless
          elevation: 0,
        ),
      );
      Navigator.push(
          Get.context!,
          CustomPageRoute(
            page: LoginScreen(),
            direction: AxisDirection.left,
          ));
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      final ex = AuthenticationExceptions.code(e.code);
      AwesomeSnackbarContent(
        title: convertCodeToTitle(e.toString()),
        message: ex.message,
        contentType: ContentType.failure,
        color: Colors.red,
      );
    } catch (e) {
      isLoading.value = false;
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: AwesomeSnackbarContent(
            title: 'Error sending email!',
            message:
                'Make sure you have a stable internet connection and you type it correctly',
            contentType: ContentType.failure,
            color: Colors.red,
          ),
          width: MediaQuery.of(Get.context!).size.width,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent, // Makes it seamless
          elevation: 0,
        ),
      );
    }
  }
}
