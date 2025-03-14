import 'package:voyager/src/features/authentication/screens/login_screen/login_screen.dart';
import 'package:voyager/src/features/authentication/screens/signup_screen/signup_screen.dart';
import 'package:voyager/src/widgets/custom_page_route.dart';
import 'package:flutter/material.dart';
import 'package:voyager/src/widgets/custom_button.dart';
import 'package:flutter/services.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _OpeningScreen4State();
}

class _OpeningScreen4State extends State<Welcome> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            Positioned(
              left: screenWidth * 0.05,
              top: screenHeight * 0.25,
              child: SizedBox(
                width: screenWidth,
                child: Text(
                  'Engage.',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Color(0xFF1877F2),
                        fontSize: screenWidth * 0.17,
                      ),
                ),
              ),
            ),
            Positioned(
              left: screenWidth * 0.05,
              top: screenHeight * 0.36,
              child: SizedBox(
                width: screenWidth,
                child: Text(
                  'Empower.',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontSize: screenWidth * 0.17,
                      ),
                ),
              ),
            ),
            Positioned(
              left: screenWidth * 0.05,
              top: screenHeight * 0.47,
              child: SizedBox(
                width: screenWidth,
                child: Text.rich(
                  TextSpan(
                      text: 'Elevate.',
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontSize: screenWidth * 0.17,
                              ),
                      children: [
                        WidgetSpan(
                            child: Padding(
                          padding: const EdgeInsets.only(left: 10, bottom: 9),
                          child: Image.asset('assets/images/icon-educ.png',
                              width: screenWidth * .13,
                              height: screenWidth * .13,
                              fit: BoxFit.contain),
                        )),
                      ]),
                ),
              ),
            ),
            // Positioned(
            //   left: screenWidth * 0.05,
            //   top: screenHeight * 0.45,
            //   child: SizedBox(
            //       width: screenWidth * 0.9,
            //       height: screenHeight * 0.29,
            //       child: SvgPicture.asset(
            //         'assets/images/cover-icon.png',
            //         fit: BoxFit.cover,
            //       )),
            // ),
            Positioned(
              left: screenWidth * 0.05,
              top: screenHeight * 0.83,
              child: Align(
                alignment: Alignment.center,
                child: DefaultButton(
                  buttonText: 'Log In',
                  bgColor: Colors.white,
                  textColor: Colors.black,
                  borderColor: Color(0xFF666666),
                  onPressed: () {
                    Navigator.push(
                      context,
                      CustomPageRoute(
                          page: LoginScreen(), direction: AxisDirection.left),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              left: screenWidth * 0.05,
              top: screenHeight * 0.90,
              child: Align(
                alignment: Alignment.center,
                child: DefaultButton(
                  buttonText: 'Sign Up',
                  bgColor: Theme.of(context).colorScheme.primary,
                  textColor: Colors.white,
                  borderColor: Colors.transparent,
                  onPressed: () {
                    Navigator.push(
                        context,
                        CustomPageRoute(
                            page: SignupScreen(),
                            direction: AxisDirection.left));
                  },
                ),
              ),
            )
          ],
        ));
  }
}
