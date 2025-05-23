import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:voyager/src/features/authentication/controllers/user_role_enum.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/authentication/screens/login_screen/login_screen.dart';
import 'package:voyager/src/repository/authentication_repository_firebase/exceptions/authentication_exceptions.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:voyager/src/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class GoogleHttpClient extends http.BaseClient {
  final Map<String, String>? _headers;
  final http.Client _client = http.Client();

  GoogleHttpClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers ?? {}));
  }
}

class FirebaseAuthenticationRepository extends GetxController {
  static FirebaseAuthenticationRepository get instance => Get.find();

  final _auth = FirebaseAuth.instance;
  late final Rx<User?> firebaseUser;

  @override
  void onReady() {
    firebaseUser = Rx<User?>(_auth.currentUser);
    firebaseUser.bindStream(_auth.userChanges());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (firebaseUser.value != null) {
        Get.offAllNamed(MRoutes.splash);
      }
    });

    //ever(firebaseUser, _setInitialScreen);
  }

  String convertCodeToTitle(String code) {
    return code.replaceAll('-', ' ').split(' ').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  Future<void> createUserWithEmailandPassword(
      String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      _auth.currentUser?.sendEmailVerification();
      Get.offAllNamed(MRoutes.splash);
    } on FirebaseAuthException catch (e) {
      final ex = AuthenticationExceptions.code(e.code);
      AwesomeSnackbarContent(
          title: convertCodeToTitle(e.code),
          message: ex.message,
          contentType: ContentType.failure,
          color: Colors.red);
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
          backgroundColor: Colors.transparent, // Makes it seamless
          elevation: 0,
        ),
      );

      throw ex;
    }
  }

  Future<void> loginUserWithEmailandPassword(
      String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      Get.offAllNamed(MRoutes.splash);
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: AwesomeSnackbarContent(
            title: 'Welcome Back!',
            message: "You have sucessfully log in your account!",
            contentType: ContentType.success,
          ),
          width: MediaQuery.of(Get.context!).size.width,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent, // Makes it seamless
          elevation: 0,
        ),
      );
    } on FirebaseAuthException catch (e) {
      final ex = AuthenticationExceptions.code(e.code);
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: AwesomeSnackbarContent(
              title: convertCodeToTitle(e.code),
              message: ex.message,
              contentType: ContentType.failure,
              color: Colors.red),
          width: MediaQuery.of(Get.context!).size.width,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent, // Makes it seamless
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
          backgroundColor: Colors.transparent, // Makes it seamless
          elevation: 0,
        ),
      );

      throw ex;
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.reload();
        if (!user.emailVerified) {
          await user.sendEmailVerification();
        } else {
          throw AuthenticationExceptions("Email already verified.");
        }

        // Check if context is still available before showing snackbar
        if (Get.context != null && Get.context!.mounted) {
          ScaffoldMessenger.of(Get.context!).showSnackBar(
            SnackBar(
              content: AwesomeSnackbarContent(
                title: 'Verify Account!',
                message:
                    "A verification email has been sent to your email address",
                contentType: ContentType.help,
              ),
              width: MediaQuery.of(Get.context!).size.width,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          );
        }
      } else {
        throw AuthenticationExceptions("User not found or already verified.");
      }
    } on FirebaseAuthException catch (e) {
      final ex = AuthenticationExceptions.code(e.code);
      if (Get.context != null && Get.context!.mounted) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: AwesomeSnackbarContent(
                title: convertCodeToTitle(e.code),
                message: ex.message,
                contentType: ContentType.failure,
                color: Colors.red),
            width: MediaQuery.of(Get.context!).size.width,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        );
      }
      throw ex;
    } catch (e) {
      const ex = AuthenticationExceptions();
      if (Get.context != null && Get.context!.mounted) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: AwesomeSnackbarContent(
                title: 'Oh Snap!',
                message:
                    "Error sending verification email. Please try again later!",
                contentType: ContentType.failure,
                color: Colors.red),
            width: MediaQuery.of(Get.context!).size.width,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        );
      }
      throw ex;
    }
  }

  Future<UserCredential?> sigInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // After Firebase authentication, call Google Calendar API

      return userCredential;
    } on FirebaseAuthException catch (e) {
      final ex = AuthenticationExceptions.code(e.code);
      AwesomeSnackbarContent(
          title: "Error",
          message: ex.message,
          contentType: ContentType.failure,
          color: Colors.red);

      throw ex;
    } catch (e) {
      final ex = AuthenticationExceptions.code(e.toString());

      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: AwesomeSnackbarContent(
              title: 'Oh Snap!',
              message: ex.message,
              contentType: ContentType.failure,
              color: Colors.red),
          width: MediaQuery.of(Get.context!).size.width,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent, // Makes it seamless
          elevation: 0,
        ),
      );

      throw ex;
    }
  }

  Future<void> logout() async {
    try {
      if (await GoogleSignIn().isSignedIn()) {
        await GoogleSignIn().signOut();
      }
      await _auth.signOut();
      Get.offAllNamed(MRoutes.welcome);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> sendPasswordResteEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      Navigator.pushReplacement(
          Get.context!, MaterialPageRoute(builder: (context) => LoginScreen()));
    } on FirebaseAuthException catch (e) {
      final ex = AuthenticationExceptions.code(e.code);
      AwesomeSnackbarContent(
          title: convertCodeToTitle(e.code),
          message: ex.message,
          contentType: ContentType.failure,
          color: Colors.red);

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
          backgroundColor: Colors.transparent, // Makes it seamless
          elevation: 0,
        ),
      );

      throw ex;
    }
  }

  Future<void> resetMentorPassword(TextEditingController password) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.updatePassword(password.text);

        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: AwesomeSnackbarContent(
              title: 'Password Updated!',
              message: "You have sucessfully updated your password!",
              contentType: ContentType.success,
            ),
            width: MediaQuery.of(Get.context!).size.width,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent, // Makes it seamless
            elevation: 0,
          ),
        );
        Navigator.pushReplacement(Get.context!,
            MaterialPageRoute(builder: (context) => LoginScreen()));
      } else {
        throw AuthenticationExceptions("User not found.");
      }
    } on FirebaseAuthException catch (e) {
      final ex = AuthenticationExceptions.code(e.code);
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: AwesomeSnackbarContent(
              title: convertCodeToTitle(e.code),
              message: ex.message,
              contentType: ContentType.failure,
              color: Colors.red),
          width: MediaQuery.of(Get.context!).size.width,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent, // Makes it seamless
          elevation: 0,
        ),
      );

      throw ex;
    } catch (e) {
      final ex = AuthenticationExceptions.code(e.toString());
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: AwesomeSnackbarContent(
              title: 'Error!',
              message: ex.message,
              contentType: ContentType.failure,
              color: Colors.red),
          width: MediaQuery.of(Get.context!).size.width,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent, // Makes it seamless
          elevation: 0,
        ),
      );

      throw ex;
    }
  }

  Future<UserCredential?> createUserWithoutSignIn(String email, String password,
      String studentID, String fullName, String profileImage) async {
    try {
      final firestore = FirestoreInstance();

      // 1. Get current user info and force token refresh
      final currentUser = _auth.currentUser;
      final currentAuthToken =
          await currentUser?.getIdToken(true); // Force refresh

      // 2. Create new account
      final newUserCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (newUserCredential.user == null) {
        throw AuthenticationExceptions("Failed to create user.");
      }

      // 3. Create user model and save to Firestore
      UserModel user = UserModel(
        accountApiID: newUserCredential.user!.uid,
        accountApiEmail: newUserCredential.user!.email ?? "",
        accountApiName: fullName,
        accountApiPhoto: profileImage,
        accountPassword: password,
        accountUsername: newUserCredential.user?.displayName ?? "Unknown",
        accountRole: UserRoleEnum.mentor,
        accountStudentId: studentID,
        accountCreatedTimestamp: DateTime.now(),
        accountModifiedTimestamp: DateTime.now(),
        accountSoftDeleted: false,
      );

      await firestore.setUser(user);

      // 4. Sign out new user
      await _auth.signOut();

      // 5. Add delay to ensure token operations complete
      await Future.delayed(const Duration(seconds: 1));

      // 6. Restore original session if we had one
      if (currentAuthToken != null && currentUser != null) {
        try {
          return await _auth.signInWithCustomToken(currentAuthToken);
        } catch (e) {
          // If custom token fails, try to sign in with original credentials
          // You'll need to have stored these somewhere secure
          // Alternatively, you could sign in anonymously here if appropriate

          return null;
        }
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }
}
