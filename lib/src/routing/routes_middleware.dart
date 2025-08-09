import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voyager/src/features/admin/screens/admin_dashboard.dart';
import 'package:voyager/src/features/authentication/controllers/user_role_enum.dart';
import 'package:voyager/src/features/authentication/screens/email_verification/email_verification.dart';
import 'package:voyager/src/features/authentication/screens/welcome/welcome.dart';
import 'package:voyager/src/features/mentee/mentee_dashboard.dart';
import 'package:voyager/src/features/mentor/screens/input_information/mentor_info1.dart';
import 'package:voyager/src/features/mentor/screens/mentor_dashboard.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';

class MRouteMiddleware extends GetMiddleware {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirestoreInstance();

  /// NOTE: The `redirect` method is synchronous. Placing complex async logic here
  /// can lead to race conditions. This logic is better placed in a dedicated
  /// splash/loading screen controller. This revised code improves your existing
  /// structure but consider refactoring to a splash screen for better performance
  /// and stability.
  @override
  RouteSettings? redirect(String? route) {
    _initializeAndNavigate();
    return null; // The async method will handle the navigation.
  }

  Future<void> _initializeAndNavigate() async {
    try {
      final user = _auth.currentUser;

      // 1. If no user is logged in, go to Welcome screen.
      if (user == null) {
        Get.offAll(() => const Welcome());
        return;
      }

      // 2. Refresh user data to get the latest email verification status.
      await user.reload();
      final freshUser = _auth.currentUser;

      // After reload, user might be null (e.g., account deleted remotely).
      if (freshUser == null) {
        Get.offAll(() => const Welcome());
        return;
      }

      // 3. If email is not verified, go to the verification screen.
      if (!freshUser.emailVerified) {
        Get.offAll(() => const EmailVerification());
        return;
      }

      // 4. If logged in and verified, determine role and navigate.
      final userDetails = await _firestore.getUser(freshUser.uid);

      switch (userDetails.accountRole) {
        case UserRoleEnum.mentee:
          Get.offAll(() => const MenteeDashboard());
          break;
        case UserRoleEnum.mentor:
          final accountIDs = await _firestore.getMentorAPIIds();
          if (accountIDs.contains(freshUser.uid)) {
            Get.offAll(() => const MentorDashboard());
          } else {
            Get.offAll(() => const MentorInfo1());
          }
          break;
        case UserRoleEnum.admin:
          Get.offAll(() => const AdminDashboard());
          break;
        default:
          // **FIXED**: Handle unknown/null roles by signing out.
          // This is a security measure for invalid states.
          await _auth.signOut();
          Get.offAll(() => const Welcome());
      }
    } catch (e) {
      // **IMPROVED**: If any error occurs, sign the user out for safety
      // and navigate to the Welcome screen.
      await _auth.signOut();
      Get.offAll(() => const Welcome());
    }
  }
}
