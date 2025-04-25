import 'package:voyager/src/features/authentication/controllers/email_verification_controller.dart';
import 'package:voyager/src/features/authentication/screens/login_screen/login_screen.dart';
import 'package:voyager/src/widgets/custom_page_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class EmailVerification extends StatelessWidget {
  const EmailVerification({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EmailVerificationController());
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
                        height: screenHeight * 0.04,
                      ),
                      SvgPicture.asset(
                        'assets/images/email_verification/email_verification.svg',
                        width: screenWidth * 0.5,
                      ),
                      Text(
                        'Verify your Email',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontSize: screenWidth * 0.07,
                            ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.02,
                      ),
                      Text(
                        'We have just send email verification link on your email. Please check email and click on that link to verify your email address.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: screenWidth * 0.04,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: screenHeight * 0.04,
                      ),
                      Text(
                        'If not redirected after verification, click on the Continue buttton.',
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
                  Center(
                    child: Padding(
                        padding: EdgeInsets.only(top: screenHeight * 0.01),
                        child: SizedBox(
                          width: screenWidth * 0.4,
                          height: screenHeight * 0.08,
                          child: OutlinedButton(
                            child: Text(
                              'Continue',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontSize: screenWidth * 0.04,
                                    color: Color(0xFF1877F2),
                                  ),
                            ),
                            onPressed: () => controller
                                .manuallyCheckEmailVerificationStatus(),
                          ),
                        )),
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => {
                          Navigator.push(
                            context,
                            CustomPageRoute(
                              page: EmailVerification(),
                              direction: AxisDirection.left,
                            ),
                          )
                        },
                        child: Text(
                          'Resend E-mail Link',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Color(0xFF1877F2),
                                    fontSize: screenWidth * 0.04,
                                  ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => {
                          Navigator.push(
                            context,
                            CustomPageRoute(
                              page: LoginScreen(),
                              direction: AxisDirection.left,
                            ),
                          )
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.arrow_back,
                              color: Color(0xFF1877F2),
                            ),
                            SizedBox(width: 5),
                            Text(
                              'back to log in',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Color(0xFF1877F2),
                                    fontSize: screenWidth * 0.04,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
                ],
              ),
            ),
          ),
        ));
  }
}
