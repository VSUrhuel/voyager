import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:voyager/src/features/authentication/screens/welcome/welcome.dart';
import 'package:voyager/src/repository/authentication-repository/supabase_auth_repository.dart';
import 'package:voyager/src/repository/supabase_repository/supabase_instance.dart';
import 'package:voyager/src/routing/routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  static LoginController get instance => Get.find();

  final email = TextEditingController();
  final password = TextEditingController();

  final auth = Get.put(AuthenticationRepository());

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

      // If the user has a default password, direct them to the reset password page
      if (password == "mentor2025") {
        await auth.loginUserWithEmailandPassword(email, password);
        Navigator.push(
            Get.context!, MaterialPageRoute(builder: (context) => Welcome()));
        isLoading.value = false;
        return;
      }

      await auth.loginUserWithEmailandPassword(email, password);
      isLoading.value = false;
    } on AuthException catch (e) {
      isLoading.value = false;
      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: AwesomeSnackbarContent(
              title: 'Login Error',
              message: e.message,
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
      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: AwesomeSnackbarContent(
              title: 'Unexpected Error',
              message: 'An unexpected error occurred. Please try again.',
              contentType: ContentType.failure,
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

  Future<void> googleSignIn() async {
    try {
      isGoogleLoading.value = true;
      await auth.signInWithGoogle();
      await Future.delayed(Duration(seconds: 3));
      print('User: ${auth.supabaseUser.value}');
      final supabaseInstance = SupabaseInstance();
      final apiIDs = await supabaseInstance.getAPIId();

      if (auth.supabaseUser.value != null) {
        print('API IDs: $apiIDs');
        if (apiIDs.contains(auth.supabaseUser.value?.id)) {
          Get.offAllNamed(MRoutes.splash);
          return;
        }
        print('User ID: ${auth.supabaseUser.value?.id}');
        await supabaseInstance
            .setUserFromGoogle(Rx<User?>(auth.supabaseUser.value!));
        print('done');
        Get.offAllNamed(MRoutes.splash);

        if (Get.context != null) {
          ScaffoldMessenger.of(Get.context!).showSnackBar(
            SnackBar(
              content: AwesomeSnackbarContent(
                title: 'Welcome back!',
                message:
                    "You have successfully logged in with your Google account!",
                contentType: ContentType.success,
              ),
              width: MediaQuery.of(Get.context!).size.width,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent, // Makes it seamless
              elevation: 0,
            ),
          );
        }
      } else {
        Get.snackbar('Error', "User is null");
      }

      isGoogleLoading.value = false;
    } catch (e) {
      isGoogleLoading.value = false;
      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: AwesomeSnackbarContent(
              title: 'Google Sign-In Error',
              message: 'An error occurred while signing in with Google.',
              contentType: ContentType.failure,
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
}
