import 'package:voyager/src/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  final _supabase = Supabase.instance.client;
  late final Rx<User?> supabaseUser;

  @override
  void onReady() {
    supabaseUser = Rx<User?>(_supabase.auth.currentUser);
    supabaseUser.bindStream(
        _supabase.auth.onAuthStateChange.map((event) => event.session?.user));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (supabaseUser.value != null) {
        Get.offAllNamed(MRoutes.splash);
      }
    });
  }

  String convertCodeToTitle(String code) {
    return code.replaceAll('-', ' ').split(' ').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
}
