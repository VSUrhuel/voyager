import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:voyager/src/repository/authentication_repository_firebase/authentication_repository.dart';
import 'package:voyager/src/routing/routes.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:flutter/material.dart';

class EmailVerificationController extends GetxController {
  late Timer _timer;
  // Get an instance of the repository.
  final _authRepo = Get.find<FirebaseAuthenticationRepository>();

  @override
  void onInit() {
    super.onInit();
    // Show a notification to the user that an email has been sent.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: AwesomeSnackbarContent(
            title: 'Check Your Inbox!',
            message: 'A verification link has been sent to your email.',
            contentType: ContentType.help,
          ),
          // Completed styling for consistency
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      );
    });
    setTimerForAutoRedirect();
  }

  /// Called when the controller is removed from memory.
  /// This is CRUCIAL to prevent memory leaks from the timer.
  @override
  void onClose() {
    _timer.cancel();
    super.onClose();
  }

  /// Sends another verification email, typically used for a "Resend Email" button.
  Future<void> sendVerificationEmail() async {
    try {
      await _authRepo.sendEmailVerification();
      // Show a success message
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: AwesomeSnackbarContent(
            title: 'Email Sent!',
            message: 'A new verification link has been sent to your inbox.',
            contentType: ContentType.success,
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      );
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase errors, like "too-many-requests"
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: AwesomeSnackbarContent(
            title: 'Oh Snap!',
            message: e.message ?? 'An error occurred. Please try again later.',
            contentType: ContentType.failure,
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error: $e');
    }
  }

  /// Sets a periodic timer to check the email verification status automatically.
  void setTimerForAutoRedirect() {
    // Increased duration to 5 seconds to avoid "too-many-requests" errors from Firebase.
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      // The reload() method must be awaited to get the latest user data.
      await FirebaseAuth.instance.currentUser?.reload();

      final user = FirebaseAuth.instance.currentUser;
      // Check if the user's email has been verified.
      if (user?.emailVerified ?? false) {
        timer.cancel(); // Stop the timer.
        // Redirect to splash screen to trigger auth middleware for correct routing.
        Get.offAllNamed(MRoutes.splash);
      }
    });
  }

  /// Manually checks the verification status, typically via a button press.
  Future<void> manuallyCheckEmailVerificationStatus() async {
    // The reload() method must be awaited.
    await FirebaseAuth.instance.currentUser?.reload();

    final user = FirebaseAuth.instance.currentUser;
    if (user?.emailVerified ?? false) {
      Get.offAllNamed(MRoutes.splash);
    } else {
      // Notify user that the email is still not verified.
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: AwesomeSnackbarContent(
              title: 'Not Verified',
              message:
                  "Please check your inbox and click the verification link.",
              contentType: ContentType.failure,
              color: Colors.red),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      );
    }
  }

  /// Signs the user out and navigates to the Welcome screen.
  /// Useful if the user wants to sign in with a different account.
  Future<void> signOut() async {
    await _authRepo.logout();
    Get.offAllNamed(MRoutes.welcome);
  }
}
