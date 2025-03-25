import 'package:firebase_auth/firebase_auth.dart';
import 'package:voyager/src/features/admin/screens/admin_dashboard.dart';
// import 'package:voyager/src/features/admin/screens/admin_home.dart';
import 'package:voyager/src/features/authentication/screens/welcome/welcome.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voyager/src/features/authentication/controllers/user_role_enum.dart';
import 'package:voyager/src/features/authentication/screens/email_verification/email_verification.dart';
import 'package:voyager/src/features/mentee/mentee_dashboard.dart';
import 'package:voyager/src/features/mentor/screens/input_information/mentor_info1.dart';
import 'package:voyager/src/features/mentor/screens/mentor_dashboard.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';

class MRouteMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // Synchronously show a placeholder (e.g., splash screen) while processing async logic
    // Get.snackbar("Loading", Get.currentRoute.toString());
    // if (Get.currentRoute == MRoutes.welcome) {
    //   _loginUser();
    //   return null;
    // }
    _initializeUserNavigation();
    return null;
  }

  Future<void> _initializeUserNavigation() async {
    try {
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser;
      if (user == null) {
        Navigator.pushReplacement(
            Get.context!, MaterialPageRoute(builder: (context) => Welcome()));
        return;
      }
      if (user.emailVerified == false) {
        Get.offAll(() => EmailVerification());
        return;
      }
      final firestore = FirestoreInstance();
      // Check authentication state
      final userDetails = await firestore.getUser(user.uid);

      // Handle email verification

      // Navigate based on user role

      switch (userDetails.accountRole) {
        case UserRoleEnum.mentee:
          if (Get.context != null) {
            Navigator.pushReplacement(Get.context!,
                MaterialPageRoute(builder: (context) => MenteeDashboard()));
          }
          break;
        case UserRoleEnum.mentor:
          if (Get.context != null) {
            final accountIDs = await firestore.getMentorApPIIds();
            if (!accountIDs.contains(user.uid)) {
              Navigator.pushReplacement(Get.context!,
                  MaterialPageRoute(builder: (context) => MentorInfo1()));
            } else {
              Navigator.pushReplacement(Get.context!,
                  MaterialPageRoute(builder: (context) => MentorDashboard()));
            }
          }
          break;
        case UserRoleEnum.admin:
          if (Get.context != null) {
            Navigator.pushReplacement(Get.context!,
                MaterialPageRoute(builder: (context) => AdminDashboard()));
          }
          break;
        default:
          Get.offAll(() => EmailVerification());
      }
    } catch (e) {
      Get.snackbar("Errodddrs", e.toString());
    }
  }
}
