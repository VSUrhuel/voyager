import 'package:voyager/src/features/authentication/widgets/password_text_field.dart';
import 'package:voyager/src/features/mentor/controller/reset_pass_controller.dart';
import 'package:voyager/src/repository/authentication_repository_firebase/authentication_repository.dart';
import 'package:voyager/src/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ResetPass extends StatelessWidget {
  const ResetPass({super.key});


  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ResetPassController());
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final auth = Get.put(FirebaseAuthenticationRepository());
    return SafeArea(
        bottom: true,
        top: false,
        child: Scaffold(
            appBar: AppBar(
              systemOverlayStyle: SystemUiOverlayStyle.dark,
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  auth.logout();
                },
              ),
              backgroundColor: Colors.transparent,
              actionsIconTheme: IconThemeData(color: Colors.black),
            ),
            body: Center(
                child: Padding(
                    padding: EdgeInsets.only(
                        left: screenWidth * 0.05, right: screenWidth * 0.05),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                          'Reset your password!',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(
                          height: screenHeight * 0.02,
                        ),
                        PasswordTextField(
                          labelText: 'Enter your password',
                          fontSize: screenWidth * 0.04,
                          leadingIcon: Icons.lock,
                          controllerParam:
                              ResetPassController.instance.initialPassword,
                        ),
                        SizedBox(
                          height: screenHeight * 0.02,
                        ),
                        PasswordTextField(
                          labelText: 'Confirm your password',
                          fontSize: screenWidth * 0.04,
                          leadingIcon: Icons.lock,
                          controllerParam: controller.confirmedPassword,
                        ),
                        SizedBox(
                          height: screenHeight * 0.02,
                        ),
                        Obx(() => DefaultButton(
                              buttonText: 'Reset Password',
                              bgColor: Theme.of(context).colorScheme.primary,
                              textColor: Colors.white,
                              borderColor: Colors.transparent,
                              isLoading:
                                  controller.isLoading.value ? true : false,
                              onPressed: controller.isLoading.value
                                  ? () {}
                                  : () {
                                      if (controller.confirmedPassword.text
                                              .trim() ==
                                          "mentor2025") {
                                        Get.snackbar(
                                          'Error',
                                          'Password should be new',
                                          backgroundColor: Colors.red,
                                          colorText: Colors.white,
                                          duration: Duration(seconds: 2),
                                        );
                                      } else {
                                        controller.resetPassword(controller
                                            .confirmedPassword.text
                                            .trim());
                                        controller.dispose();
                                      }
                                    },
                            )),
                      ],
                    )))));
  }
}
