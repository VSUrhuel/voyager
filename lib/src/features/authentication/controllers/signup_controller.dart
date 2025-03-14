import 'dart:async';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:voyager/src/features/authentication/controllers/user_role_enum.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/authentication/screens/email_verification/email_verification.dart';
import 'package:voyager/src/repository/supabase_repository/supabase_instance.dart';
import 'package:voyager/src/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voyager/src/repository/authentication-repository/supabase_auth_repository.dart';

class SignupController extends GetxController {
  static SignupController get instance => Get.find();

  final studentID = TextEditingController();
  final fullName = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  final auth = Get.put(AuthenticationRepository());

  final isGoogleLoading = false.obs;
  final isLoading = false.obs;
  final supabase = SupabaseClient('https://zyqxnzxudwofrlvdzbvf.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp5cXhuenh1ZHdvZnJsdmR6YnZmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE3MDQ1NjEsImV4cCI6MjA1NzI4MDU2MX0.Sbj42rsklbYOk0ug5rjswXefwlksX8MwkjFq5T6DH0E');

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

      // Initialize Supabase client

      // Register user with Supabase
      final AuthResponse authResponse = await AuthenticationRepository.instance
          .createUserWithEmailandPassword(email, password);

      if (authResponse.user == null) {
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

      // Create user model
      UserModel user = UserModel(
        accountApiID: authResponse.user!.id, // Use Supabase user ID
        accountApiEmail: authResponse.user!.email ?? "", // Use Supabase email
        accountApiName: fullName.text,
        accountApiPhoto: "", // Supabase doesn't provide a photo URL by default
        accountPassword: '', // Password is managed by Supabase
        accountUsername: fullName.text, // Use full name as username
        accountRole: UserRoleEnum.mentee,
        accountStudentId: studentID.text,
        accountCreatedTimestamp: DateTime.now(),
        accountModifiedTimestamp: DateTime.now(),
        accountSoftDeleted: false,
      );

      // Insert user data into Supabase table
      await supabase
          .from('users') // Replace 'users' with your table name
          .insert(user.toJson()); // Convert user model to JSON

      // Navigate to email verification screen
      Get.offAll(() => EmailVerification());
      isLoading.value = false;
    } on AuthException catch (e) {
      // Handle Supabase auth exceptions
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
      isLoading.value = false;
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: AwesomeSnackbarContent(
              title: 'Unexpected Error',
              message: e.toString(),
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
      await auth.signInWithGoogle();
      if (auth.supabaseUser.value == null) {
        Get.snackbar('Error', "User is null");
        return;
      }
      final supabaseUser = Rx<User?>(Supabase.instance.client.auth.currentUser);
      await SupabaseInstance().setUserFromGoogle(supabaseUser);
      Get.offAllNamed(MRoutes.splash);
      isGoogleLoading.value = false;
    } catch (e) {
      isGoogleLoading.value = false;
    }
  }
}
