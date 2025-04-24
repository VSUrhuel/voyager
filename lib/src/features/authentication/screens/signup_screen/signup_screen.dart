import 'package:voyager/src/features/authentication/controllers/signup_controller.dart';
import 'package:voyager/src/features/authentication/screens/login_screen/login_screen.dart';
import 'package:voyager/src/features/authentication/screens/signup_screen/signup_form.dart';
import 'package:voyager/src/features/authentication/widgets/divider_with_text.dart';
import 'package:voyager/src/widgets/custom_button_w_icon.dart';
import 'package:voyager/src/widgets/custom_page_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  late final SignupController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(SignupController());
  }

  @override
  void dispose() {
    Get.delete<SignupController>(force: true);
    super.dispose();
  }

  final List<String> textValues = [
    'Student ID',
    'Full Name',
    'Email Address',
  ];

  final List<String> hintText = [
    '22-1-12345',
    'Juan Del Cruz',
    'example@gmail.com',
  ];

  final List<IconData> leadingIcons = [
    Icons.badge,
    Icons.person,
    Icons.email,
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
        onTap: () =>
            FocusScope.of(context).unfocus(), // Dismiss keyboard on tap
        child: SafeArea(
          bottom: true,
          top: false,
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              scrolledUnderElevation: 0,
              systemOverlayStyle: SystemUiOverlayStyle.dark,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              elevation: 0,
              foregroundColor: Colors.black,
            ),
            extendBodyBehindAppBar: true,
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.07,
                  horizontal: screenWidth * 0.07,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      'assets/images/signup_images/sign_up.svg',
                      width: screenWidth * 0.3,
                    ),
                    Text(
                      'Get on Board',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontSize: screenWidth * 0.06,
                              ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      'Create your profile to start your journey!',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: screenWidth * 0.04,
                          ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    SignupForm(
                      formKey: _formKey,
                      controller: controller,
                      textValues: textValues,
                      leadingIcons: leadingIcons,
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      hintText: hintText,
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    DividerWithText(screenWidth: screenWidth),
                    SizedBox(height: screenHeight * 0.01),
                    _GoogleSignupButton(
                        screenWidth: screenWidth, controller: controller),
                    _AlreadyHaveAccount(screenWidth: screenWidth),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}

class _GoogleSignupButton extends StatelessWidget {
  final double screenWidth;
  final SignupController controller;

  const _GoogleSignupButton(
      {required this.screenWidth, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => DefaultIconButton(
          buttonText: 'Sign up With Google',
          image: 'assets/images/login_images/google-icon.png',
          direction: null,
          bgColor: Colors.white,
          textColor: Color(0xFF455A64),
          borderColor: Color(0xFF455A64),
          prefixIcon: null,
          isLoading: controller.isGoogleLoading.value ? true : false,
          onPressed: controller.isGoogleLoading.value
              ? () {}
              : () => controller.googleSignUp(),
        ));
  }
}

class _AlreadyHaveAccount extends StatelessWidget {
  final double screenWidth;

  const _AlreadyHaveAccount({required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account?',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: screenWidth * 0.04,
              ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              CustomPageRoute(
                  page: LoginScreen(), direction: AxisDirection.left),
            );
          },
          child: Text(
            'Log In',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: screenWidth * 0.04,
                  color: Theme.of(context).primaryColor,
                ),
          ),
        ),
      ],
    );
  }
}
