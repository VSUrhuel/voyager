import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:voyager/src/repository/authentication-repository/supabase_auth_repository.dart';
import 'package:voyager/src/routing/routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import 'package:get/get.dart';
import 'dart:async';
import 'package:flutter/material.dart';

class EmailVerificationController extends GetxController {
  late Timer _timer;
  final SupabaseClient supabase = Supabase.instance.client; // Supabase client

  @override
  void onInit() {
    super.onInit();
    sendVerificationEmail();
    setTimerForAutoRedirect();
  }

  Future<void> sendVerificationEmail() async {
    try {
      await AuthenticationRepository.instance.sendEmailVerification();
    } on Exception {
      rethrow;
    }
  }

  void setTimerForAutoRedirect() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      // Reload the user session in Supabase
      final session = supabase.auth.currentSession;
      final user = supabase.auth.currentUser;

      if (user != null && session != null && user.emailConfirmedAt != null) {
        // Email is verified
        _timer.cancel();
        Get.offAllNamed(MRoutes.splash);
      }
    });
  }

  void manuallyCheckEmailVerificationStatus() async {
    // Reload the user session in Supabase
    final session = supabase.auth.currentSession;
    final user = supabase.auth.currentUser;

    if (user != null && session != null && user.emailConfirmedAt != null) {
      // Email is verified
      Get.offAllNamed(MRoutes.splash);
    } else {
      // Email is not verified
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: AwesomeSnackbarContent(
              title: 'Email not verified',
              message: "Please verify your email to continue",
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
}
