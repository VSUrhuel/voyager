import 'package:app_links/app_links.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:voyager/src/features/authentication/screens/login_screen/login_screen.dart';
import 'package:voyager/src/repository/exceptions/authentication_exceptions.dart';
import 'package:voyager/src/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  Future<AuthResponse> createUserWithEmailandPassword(
      String email, String password) async {
    try {
      final response =
          await _supabase.auth.signUp(email: email, password: password);

      if (response.user == null) {
        throw AuthenticationExceptions("User creation failed.");
      }
      // Automatically log in the user after successful sign-up

      Get.offAllNamed(MRoutes.splash);
      return response;
    } on AuthException catch (e) {
      final ex = AuthenticationExceptions.code(e.message);
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: AwesomeSnackbarContent(
              title: convertCodeToTitle(e.message),
              message: ex.message,
              contentType: ContentType.failure,
              color: Colors.red),
          width: MediaQuery.of(Get.context!).size.width,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      );
      throw ex;
    } catch (e) {
      const ex = AuthenticationExceptions();
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: AwesomeSnackbarContent(
              title: 'Oh Snap!',
              message: ex.message,
              contentType: ContentType.failure,
              color: Colors.red),
          width: MediaQuery.of(Get.context!).size.width,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      );
      throw ex;
    }
  }

  Future<void> loginUserWithEmailandPassword(
      String email, String password) async {
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
      Get.offAllNamed(MRoutes.splash);
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: AwesomeSnackbarContent(
            title: 'Welcome Back!',
            message: "You have successfully logged in to your account!",
            contentType: ContentType.success,
          ),
          width: MediaQuery.of(Get.context!).size.width,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      );
    } on AuthException catch (e) {
      final ex = AuthenticationExceptions.code(e.message);
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: AwesomeSnackbarContent(
              title: convertCodeToTitle(e.message),
              message: ex.message,
              contentType: ContentType.failure,
              color: Colors.red),
          width: MediaQuery.of(Get.context!).size.width,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      );
      throw ex;
    } catch (e) {
      const ex = AuthenticationExceptions();
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: AwesomeSnackbarContent(
              title: 'Error!',
              message: "An unexpected error occurred. Please try again.",
              contentType: ContentType.failure,
              color: Colors.red),
          width: MediaQuery.of(Get.context!).size.width,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      );
      throw ex;
    }
  }

  Future<void> verifyEmailToken(String token) async {
    try {
      await Supabase.instance.client.auth.verifyOTP(
        token: token,
        type: OtpType.signup,
      );
      // Email verified successfully
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text('Email verified successfully!'),
        ),
      );
      // Navigate to the next screen
      Get.offAllNamed(MRoutes.splash);
    } catch (e) {
      // Handle verification error
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text('Failed to verify email: $e'),
        ),
      );
    }
  }

  Future<void> initDeepLinks() async {
    final appLinks = AppLinks();

    // Listen for deep links
    appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null && uri.host == 'verify') {
        final token = uri.queryParameters['token'];
        if (token != null) {
          verifyEmailToken(token);
        }
      }
    });
  }

  Future<void> sendEmailVerification() async {
    try {
      final user = _supabase.auth.currentUser;

      // Check if the user exists and their email is not already verified
      if (user != null && user.emailConfirmedAt == null) {
        // Resend the email verification
        await _supabase.auth.resend(
          type: OtpType.signup, // Use OtpType.signup for email verification
          email: user.email!, // Ensure email is not null
        );

        // Show success message
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: AwesomeSnackbarContent(
              title: 'Verify Account!',
              message:
                  "A verification email has been sent to your email address.",
              contentType: ContentType.help,
            ),
            width: MediaQuery.of(Get.context!).size.width,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        );
      } else {
        // Handle cases where the user is not found or already verified
        throw AuthenticationExceptions("User not found or already verified.");
      }
    } on AuthException catch (e) {
      // Handle Supabase-specific authentication errors
      final ex = AuthenticationExceptions.code(e.message);
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: AwesomeSnackbarContent(
            title: convertCodeToTitle(e.message),
            message: ex.message,
            contentType: ContentType.failure,
            color: Colors.red,
          ),
          width: MediaQuery.of(Get.context!).size.width,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      );
      throw ex;
    } catch (e) {
      // Handle generic errors
      const ex = AuthenticationExceptions();
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: AwesomeSnackbarContent(
            title: 'Oh Snap!',
            message:
                "Error sending verification email. Please try again later!",
            contentType: ContentType.failure,
            color: Colors.red,
          ),
          width: MediaQuery.of(Get.context!).size.width,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      );
      throw ex;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      // Step 1: Initialize Google Sign-In
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId:
            '736754036415-5vt3p9evbi1tavgcusq05gcfve6bv1sc.apps.googleusercontent.com', // iOS Client ID
        serverClientId:
            '736754036415-sau57flrlabvu50l899h54vc4ic844k7.apps.googleusercontent.com', // Web Client ID
      );

      // Step 2: Trigger Google Sign-In
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw 'Google Sign-In was canceled.';
      }

      // Step 3: Get authentication tokens
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      if (idToken == null || accessToken == null) {
        throw 'Failed to retrieve Google authentication tokens.';
      }

      // Step 4: Sign in with Supabase using the tokens
      final AuthResponse response =
          await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      // Step 5: Handle successful sign-in
      print('Signed in user: ${response.user?.email}');
    } on AuthException catch (e) {
      final ex = AuthenticationExceptions.code(e.message);
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: AwesomeSnackbarContent(
              title: "Error",
              message: ex.message,
              contentType: ContentType.failure,
              color: Colors.red),
          width: MediaQuery.of(Get.context!).size.width,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      );
      throw ex;
    } catch (e) {
      const ex = AuthenticationExceptions();
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: AwesomeSnackbarContent(
              title: 'Oh Snap!',
              message: e.toString(),
              contentType: ContentType.failure,
              color: Colors.red),
          width: MediaQuery.of(Get.context!).size.width,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      );
      throw ex;
    }
  }

  Future<void> logout() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId:
            '736754036415-5vt3p9evbi1tavgcusq05gcfve6bv1sc.apps.googleusercontent.com', // iOS Client ID
        serverClientId:
            '736754036415-sau57flrlabvu50l899h54vc4ic844k7.apps.googleusercontent.com', // Web Client ID
      );

      await _supabase.auth.signOut();

      // Sign out and disconnect from Google
      Get.offAllNamed(MRoutes.welcome);
      await googleSignIn.signOut();
      await googleSignIn.disconnect();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      Navigator.pushReplacement(
          Get.context!, MaterialPageRoute(builder: (context) => LoginScreen()));
    } on AuthException catch (e) {
      final ex = AuthenticationExceptions.code(e.message);
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: AwesomeSnackbarContent(
              title: convertCodeToTitle(e.message),
              message: ex.message,
              contentType: ContentType.failure,
              color: Colors.red),
          width: MediaQuery.of(Get.context!).size.width,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      );
      throw ex;
    } catch (e) {
      const ex = AuthenticationExceptions();
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: AwesomeSnackbarContent(
              title: 'Error sending email!',
              message:
                  "Please make sure you have internet connection and typed the right email!",
              contentType: ContentType.failure,
              color: Colors.red),
          width: MediaQuery.of(Get.context!).size.width,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      );
      throw ex;
    }
  }

  Future<void> resetMentorPassword(TextEditingController password) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        await _supabase.auth
            .updateUser(UserAttributes(password: password.text));
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: AwesomeSnackbarContent(
              title: 'Password Updated!',
              message: "You have successfully updated your password!",
              contentType: ContentType.success,
            ),
            width: MediaQuery.of(Get.context!).size.width,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        );
        Navigator.pushReplacement(Get.context!,
            MaterialPageRoute(builder: (context) => LoginScreen()));
      } else {
        throw AuthenticationExceptions("User not found.");
      }
    } on AuthException catch (e) {
      final ex = AuthenticationExceptions.code(e.message);
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: AwesomeSnackbarContent(
              title: convertCodeToTitle(e.message),
              message: ex.message,
              contentType: ContentType.failure,
              color: Colors.red),
          width: MediaQuery.of(Get.context!).size.width,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      );
      throw ex;
    } catch (e) {
      const ex = AuthenticationExceptions();
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: AwesomeSnackbarContent(
              title: 'Error!',
              message: e.toString(),
              contentType: ContentType.failure,
              color: Colors.red),
          width: MediaQuery.of(Get.context!).size.width,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      );
      throw ex;
    }
  }
}
