import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:voyager/src/features/mentor/screens/input_information/rest_pass.dart';
import 'package:voyager/src/repository/authentication_repository_firebase/authentication_repository.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:voyager/src/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  static LoginController get instance => Get.find();

  final email = TextEditingController();
  final password = TextEditingController();

  final auth = Get.put(FirebaseAuthenticationRepository());

  final isGoogleLoading = false.obs;
  final isLoading = false.obs;

  Future<void> logInUser(String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) {
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
      // If the user has a default password it will direct to the reset password page,wherein it will reset  the user password and re login the mentor to its input information page
      if (password == "mentor2025") {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        Navigator.push(
            Get.context!, MaterialPageRoute(builder: (context) => ResetPass()));
        isLoading.value = false;
        return;
      }
      await auth.loginUserWithEmailandPassword(email, password);

      isLoading.value = false;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: AwesomeSnackbarContent(
              title: 'Login Error',
              message: e.message!,
              contentType: ContentType.failure,
            ),
            width: MediaQuery.of(Get.context!).size.width,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent, // Makes it seamless
            elevation: 0,
          ),
        );
      }
    } catch (e) {
      isLoading.value = false;
    }
  }

  Future<void> googleSignIn() async {
    try {
      isGoogleLoading.value = true;
      await FirebaseAuth.instance.setLanguageCode('en');
      await auth.sigInWithGoogle();
      await Future.delayed(Duration(seconds: 3));
      final firestore = FirestoreInstance();
      final apiIDs = await firestore.getAPIId();

      if (auth.firebaseUser.value != null) {
        if (apiIDs.contains(auth.firebaseUser.value?.uid)) {
          Get.offAllNamed(MRoutes.splash);
          return;
        }
        await firestore.setUserFromGoogle(Rx<User>(auth.firebaseUser.value!));

        Get.offAllNamed(MRoutes.splash);
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: AwesomeSnackbarContent(
              title: 'Welcome back!',
              message: "You have sucessfully log in your Google account!",
              contentType: ContentType.success,
            ),
            width: MediaQuery.of(Get.context!).size.width,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent, // Makes it seamless
            elevation: 0,
          ),
        );
      } else {
        Get.snackbar('Error', "User is null");
      }

      isGoogleLoading.value = false;
    } catch (e) {
      isGoogleLoading.value = false;
    }
  }
}
