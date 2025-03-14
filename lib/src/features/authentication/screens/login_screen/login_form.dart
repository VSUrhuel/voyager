import 'package:voyager/src/features/authentication/controllers/login_controller.dart';
import 'package:voyager/src/features/authentication/screens/forget_password/forget_password_mail.dart';
import 'package:voyager/src/features/authentication/widgets/password_text_field.dart';
import 'package:voyager/src/widgets/custom_button.dart';
import 'package:voyager/src/widgets/custom_page_route.dart';
import 'package:voyager/src/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
    required this.formKey,
    required this.controller,
    required this.textValues,
    required this.leadingIcons,
    required this.screenWidth,
    required this.screenHeight,
  });

  final GlobalKey<FormState> formKey;
  final LoginController controller;
  final List<String> textValues;
  final List<IconData> leadingIcons;
  final double screenWidth;
  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    return Form(
        key: formKey,
        child: Column(
          children: [
            CustomTextField(
              obscureTextValue: 'Email',
              fieldWidth: screenWidth * 0.9,
              fontSize: screenWidth * 0.04,
              leadingIcon: Icons.email,
              controllerParam: controller.email,
              hintText: 'example@gmail.com',
            ),
            PasswordTextField(
              labelText: 'Password',
              fontSize: screenWidth * 0.04,
              leadingIcon: Icons.lock,
              controllerParam: controller.password,
            ),
            Padding(
              // Add padding to the right of the text
              padding: EdgeInsets.all(0),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => {
                    Navigator.push(
                      context,
                      CustomPageRoute(
                        page: ForgetPasswordSCreen(),
                        direction: AxisDirection.left,
                      ),
                    )
                  },
                  child: Text(
                    'Forgot Password?',
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: screenWidth * 0.04,
                          color: Color(0xFF1877F2),
                        ),
                  ),
                ),
              ),
            ),
            DefaultButton(
              buttonText: 'Log In',
              bgColor: Theme.of(context).colorScheme.primary,
              textColor: Colors.white,
              borderColor: Colors.transparent,
              isLoading: controller.isLoading.value ? true : false,
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  try {
                    controller.logInUser(
                      controller.email.text.trim(),
                      controller.password.text.trim(),
                    );

                    // Navigate to the next screen or show success message
                  } catch (e) {
                    // Show an error message to the user
                    Get.snackbar(
                      'Error',
                      e.toString(), // Customize the message based on exception type
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                }
              },
            ),
          ],
        ));
  }
}
