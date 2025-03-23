import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:voyager/src/features/authentication/controllers/user_role_enum.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/authentication/screens/email_verification/email_verification.dart';
import 'package:voyager/src/repository/authentication_repository_firebase/authentication_repository.dart';
import 'package:voyager/src/repository/authentication_repository_firebase/exceptions/authentication_exceptions.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:voyager/src/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupController extends GetxController {
  static SignupController get instance => Get.find();

  final studentID = TextEditingController();
  final fullName = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  final auth = Get.put(FirebaseAuthenticationRepository());

  final isGoogleLoading = false.obs;
  final isLoading = false.obs;

  void registerUser(String email, String password) async {
    try {
      if (email.isEmpty ||
          password.isEmpty ||
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

        return;
      }
      isLoading.value = true;
      final firestore = FirestoreInstance();
      await auth.createUserWithEmailandPassword(email, password);

      if (auth.firebaseUser.value == null) {
        isLoading.value = false;
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: AwesomeSnackbarContent(
              title: 'Registration Error',
              message: 'User registration failed. Please try again.',
              contentType: ContentType.failure,
            ),
            width: MediaQuery.of(Get.context!).size.width,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent, // Makes it seamless
            elevation: 0,
          ),
        );
        return;
      }

      UserModel user = UserModel(
        accountApiID:
            auth.firebaseUser.value?.uid ?? "", // Use empty string if null
        accountApiEmail:
            auth.firebaseUser.value?.email ?? "", // Provide a default
        accountApiName: fullName.text,
        accountApiPhoto:
            auth.firebaseUser.value?.photoURL ?? "", // Handle null safely
        accountPassword: '',
        accountUsername: auth.firebaseUser.value?.displayName ??
            "Unknown", // Provide default username
        accountRole: UserRoleEnum.mentee,
        accountStudentId: studentID.text,
        accountCreatedTimestamp: DateTime.now(),
        accountModifiedTimestamp: DateTime.now(),
        accountSoftDeleted: false,
      );

      firestore.setUser(user);
      Get.offAll(() => EmailVerification());
      isLoading.value = false;
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
    } catch (e) {
      Get.snackbar('Error', e.toString());
      isLoading.value = false;
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: AwesomeSnackbarContent(
              title: 'Unexpected Error',
              message: 'An unexpected error occurred. Please try again.',
              contentType: ContentType.failure,
              color: Colors.red),
          width: MediaQuery.of(Get.context!).size.width,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent, // Makes it seamless
          elevation: 0,
        ),
      );
    }
  }

  Future<void> googleSignUp() async {
    try {
      isGoogleLoading.value = true;
      await auth.sigInWithGoogle();
      final firestore = FirestoreInstance();
      if (auth.firebaseUser.value == null) {
        Get.snackbar('Error', "User is null");
        return;
      }
      await firestore.setUserFromGoogle(Rx<User>(auth.firebaseUser.value!));
      Get.offAllNamed(MRoutes.splash);
      isGoogleLoading.value = false;
    } catch (e) {
      isGoogleLoading.value = false;
    }
  }
}
