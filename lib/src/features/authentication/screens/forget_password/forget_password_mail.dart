import 'package:voyager/src/features/authentication/controllers/forgot_password_controller.dart';
import 'package:voyager/src/widgets/custom_button.dart';
import 'package:voyager/src/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class ForgetPasswordSCreen extends StatefulWidget {
  const ForgetPasswordSCreen({super.key});

  @override
  State<ForgetPasswordSCreen> createState() => _ForgetPasswordSCreenState();
}

class _ForgetPasswordSCreenState extends State<ForgetPasswordSCreen> {
  @override
  void dispose() {
    Get.delete<ForgotPasswordController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ForgotPasswordController controller =
        Get.put(ForgotPasswordController());
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
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
              padding: EdgeInsets.only(
                top: screenHeight * 0.07,
                left: screenWidth * 0.07,
                right: screenWidth * 0.05,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: screenHeight * 0.09,
                      ),
                      SvgPicture.asset(
                        'assets/images/forget_password/forget_pass.svg',
                        width: screenWidth * 0.6,
                      ),
                      Text(
                        'Forget Password',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontSize: screenWidth * 0.08,
                            ),
                      ),
                      Text(
                        'Enter your email address to reset your password!',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: screenWidth * 0.04,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  Padding(
                      padding: EdgeInsets.only(
                          top: screenHeight * 0.02,
                          bottom: screenHeight * 0.01),
                      child: SizedBox(
                          height: screenHeight * 0.07,
                          child: CustomTextField(
                              hintText: 'Enter your email',
                              controllerParam: controller.email,
                              leadingIcon: Icons.email,
                              obscureTextValue: 'Email',
                              fieldWidth: screenWidth * 0.86,
                              fontSize: screenWidth * 0.04))),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  Padding(
                      padding: EdgeInsets.only(top: screenHeight * 0.01),
                      child: DefaultButton(
                        buttonText: 'Send Reset Password Link',
                        bgColor: Colors.black,
                        textColor: Colors.white,
                        borderColor: Colors.transparent,
                        onPressed: () {
                          controller
                              .sendPasswordResetEmail(controller.email.text);
                        },
                      ))
                ],
              ),
            ),
          ),
        ));
  }
}
