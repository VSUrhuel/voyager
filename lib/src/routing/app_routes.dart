import 'package:voyager/src/features/authentication/screens/login_screen/login_screen.dart';
import 'package:voyager/src/features/authentication/screens/onboarding_screens/onboarding_screen1.dart';
import 'package:voyager/src/features/authentication/screens/signup_screen/signup_screen.dart';
import 'package:voyager/src/features/authentication/screens/splash_screen/splash_screen.dart';
import 'package:voyager/src/features/authentication/screens/welcome/welcome.dart';
import 'package:voyager/src/routing/routes.dart';
import 'package:voyager/src/routing/routes_middleware.dart';
import 'package:get/get.dart';

class MAppRoutes {
  static final List<GetPage> pages = [
    // Splash Screen - Initial Route

    GetPage(
      name: MRoutes.splash,
      page: () => SplashScreen(),
      middlewares: [MRouteMiddleware()],
      // Middleware only here if needed
    ),

    // Welcome Screen
    GetPage(
      name: MRoutes.welcome,
      page: () => Welcome(),
      middlewares: [MRouteMiddleware()],
    ),

    // Login Screen
    GetPage(
      name: MRoutes.login,
      page: () => LoginScreen(),
    ),

    // Signup Screen
    GetPage(
      name: MRoutes.signup,
      page: () => SignupScreen(),
    ),

    // Mentee Home
    GetPage(
      name: MRoutes.menteeHome,
      page: () => Welcome(),
    ),

    // Mentor Home
    GetPage(
      name: MRoutes.mentorHome,
      page: () => Welcome(),
    ),

    // Admin Home
    GetPage(
      name: MRoutes.adminHome,
      page: () => Welcome(),
    ),

    GetPage(
      name: MRoutes.onBoarding,
      page: () => OnboardingScreen1(),
    ),
  ];
}
