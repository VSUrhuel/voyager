import 'package:voyager/src/features/authentication/controllers/signup_controller.dart';
import 'package:voyager/src/features/authentication/widgets/password_text_field.dart';
import 'package:voyager/src/widgets/custom_button.dart';
import 'package:voyager/src/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupForm extends StatelessWidget {
  const SignupForm({
    super.key,
    required this.formKey,
    required this.controller,
    required this.textValues,
    required this.leadingIcons,
    required this.screenWidth,
    required this.screenHeight,
    required this.hintText,
  });

  final GlobalKey<FormState> formKey;
  final SignupController controller;
  final List<String> textValues;
  final List<IconData> leadingIcons;
  final double screenWidth;
  final double screenHeight;
  final List<String> hintText;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          ...List<Widget>.generate(3, (index) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.0),
              child: CustomTextField(
                obscureTextValue: textValues[index],
                fieldWidth: screenWidth * 0.9,
                fontSize: screenWidth * 0.04,
                leadingIcon: leadingIcons[index],
                hintText: hintText[index],
                controllerParam: index == 0
                    ? controller.studentID
                    : index == 1
                        ? controller.fullName
                        : controller.email,
              ),
            );
          }),
          PasswordTextField(
            labelText: 'Password',
            fontSize: screenWidth * 0.04,
            leadingIcon: Icons.lock,
            controllerParam: controller.password,
          ),
          SizedBox(height: screenHeight * 0.02),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'By registering, you agree to our ',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: screenWidth * 0.04,
                      ),
                ),
                TextSpan(
                  text: 'Terms of Service',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: screenWidth * 0.04,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                TextSpan(
                  text: ' and ',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: screenWidth * 0.04,
                      ),
                ),
                TextSpan(
                  text: 'Privacy Policy',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: screenWidth * 0.04,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          Obx(() => DefaultButton(
                buttonText: 'Sign Up',
                bgColor: Theme.of(context).colorScheme.primary,
                textColor: Colors.white,
                borderColor: Colors.transparent,
                isLoading: controller.isLoading.value ? true : false,
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.registerUser(
                        controller.email.text.trim(),
                        controller.password.text.trim()),
                
              )),
        ],
      ),
    );
  }
}
