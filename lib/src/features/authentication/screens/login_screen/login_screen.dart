import 'package:voyager/src/features/authentication/controllers/login_controller.dart';
import 'package:voyager/src/features/authentication/screens/login_screen/login_form.dart';
import 'package:voyager/src/features/authentication/screens/signup_screen/signup_screen.dart';
import 'package:voyager/src/features/authentication/widgets/divider_with_text.dart';
import 'package:voyager/src/widgets/custom_button_w_icon.dart';
import 'package:voyager/src/widgets/custom_page_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<LoginScreen> {
  @override
  void dispose() {
    Get.delete<LoginController>();
    super.dispose();
  }

  final controller = Get.put(LoginController());
  final _formKey = GlobalKey<FormState>();

  final List<String> textValues = ['Email', 'Password'];
  final List<IconData> leadingIcons = [Icons.email, Icons.lock];
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          elevation: 0,
          foregroundColor: Colors.black,
        ),
        extendBodyBehindAppBar: true,
        body: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.only(
                    top: screenHeight * 0.07,
                    left: screenWidth * 0.07,
                    right: screenWidth * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      'assets/images/login_images/log_in.svg',
                      width: screenWidth * 0.3,
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Welcome back to ',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontSize: screenWidth * 0.06,
                                ),
                          ),
                          TextSpan(
                            text: 'eduvate',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: Color(0xFF1877F2),
                                  fontSize: screenWidth * 0.06,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Login to you account',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: screenWidth * 0.04,
                          ),
                    ),
                    SizedBox(
                      height: screenHeight * 0.02,
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          LoginForm(
                              formKey: _formKey,
                              controller: controller,
                              textValues: textValues,
                              leadingIcons: leadingIcons,
                              screenWidth: screenWidth,
                              screenHeight: screenHeight),
                          SizedBox(
                            height: screenHeight * 0.01,
                          ),
                          DividerWithText(screenWidth: screenWidth),
                          SizedBox(
                            height: screenHeight * 0.01,
                          ),
                          Obx(() => DefaultIconButton(
                                buttonText: 'Log In with Google',
                                image:
                                    'assets/images/login_images/google-icon.png',
                                direction: null,
                                bgColor: Colors.white,
                                textColor: Color(0xFF455A64),
                                borderColor: Color(0xFF455A64),
                                prefixIcon: null,
                                isLoading: controller.isGoogleLoading.value
                                    ? true
                                    : false,
                                onPressed: controller.isGoogleLoading.value
                                    ? () {}
                                    : () => controller.googleSignIn(),
                              )),
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Don\'t have an account? ',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        fontSize: screenWidth * 0.04,
                                      ),
                                ),
                                TextButton(
                                  onPressed: () => {
                                    Navigator.push(
                                      context,
                                      CustomPageRoute(
                                        page: SignupScreen(),
                                        direction: AxisDirection.left,
                                      ),
                                    )
                                  },
                                  child: Text(
                                    'Register',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Color(0xFF1877F2),
                                          fontSize: screenWidth * 0.04,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ))));
  }
}
