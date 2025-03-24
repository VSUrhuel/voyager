import 'package:voyager/src/features/authentication/screens/onboarding_screens/onboarding_screen3.dart';
import 'package:voyager/src/widgets/custom_page_route.dart';
import 'package:flutter/material.dart';
import 'package:voyager/src/widgets/custom_button.dart';

class OnboardingScreen2 extends StatelessWidget {
  const OnboardingScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            SizedBox(
                height: screenHeight * 0.75,
                width: screenWidth,
                child: Image.asset(
                  'assets/images/onboarding_images/onboarding-image-2.jpg',
                  fit: BoxFit.cover,
                )),
            Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                    width: screenWidth,
                    height: screenHeight * 0.35,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 5),
                            child: Stack(
                              children: [
                                Container(
                                  width: 50,
                                  height: screenHeight * 0.01,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                Container(
                                  width: 32,
                                  height: screenHeight * 0.01,
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ],
                            )),
                      ],
                    ))),
            Positioned(
              left: 25,
              top: screenHeight * 0.68 + screenWidth * 0.01,
              child: Text('Explore Courses',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: screenWidth * 0.08,
                      )),
            ),
            Positioned(
              left: 25,
              top: screenHeight * 0.72 + screenWidth * 0.01,
              child: Text('Tailored to Curricullum',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: screenWidth * 0.08,
                      )),
            ),
            Positioned(
              left: 25,
              top: screenHeight * 0.78,
              child: SizedBox(
                width: screenWidth - 50,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text:
                            'Choose courses that match your curriculum and learning goals. ',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: screenWidth * 0.04,
                            ),
                      ),
                      TextSpan(
                          text: 'Discover',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: screenWidth * 0.04,
                                    color: Color(0xFF1877F2),
                                    fontWeight: FontWeight.w700,
                                  )),
                      TextSpan(
                          text: ' and ',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: screenWidth * 0.04,
                                  )),
                      TextSpan(
                          text: 'dive ',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: screenWidth * 0.04,
                                    color: Color(0xFF1877F2),
                                    fontWeight: FontWeight.w700,
                                  )),
                      TextSpan(
                        text:
                            'into educational content tailored to empower your academic and personal growth.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: screenWidth * 0.04,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
                left: 25,
                top: screenHeight * 0.91,
                child: DefaultButton(
                  buttonText: 'Continue',
                  bgColor: Theme.of(context).colorScheme.primary,
                  textColor: Colors.white,
                  borderColor: Colors.transparent,
                  onPressed: () {
                    precacheImage(
                        AssetImage(
                            'assets/images/onboarding_images/onboarding-image-3.jpg'),
                        context);
                    Navigator.push(
                      context,
                      CustomPageRoute(
                          page: OnboardingScreen3(),
                          direction: AxisDirection.up),
                    );
                  },
                )),
          ],
        ));
  }
}
