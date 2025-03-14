import 'package:voyager/src/features/authentication/screens/welcome/welcome.dart';
import 'package:voyager/src/widgets/custom_page_route.dart';
import 'package:flutter/material.dart';
import 'package:voyager/src/widgets/custom_button.dart';

class OnboardingScreen3 extends StatelessWidget {
  const OnboardingScreen3({super.key});

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
              height: screenHeight * 0.80,
              width: screenWidth,
              child: Image.asset(
                'assets/images/onboarding_images/onboarding-image-3.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: screenWidth,
                height: screenHeight * 0.35,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 0),
                        child: Stack(
                          children: [
                            Container(
                              width: 50,
                              height: screenHeight * 0.01,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ],
                        )),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 25,
              top: screenHeight * 0.68 + screenWidth * 0.01,
              child: Text('Get Notify',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white, fontSize: screenWidth * 0.08)),
            ),
            Positioned(
              left: 25,
              top: screenHeight * 0.72 + screenWidth * 0.01,
              child: Text('Streamline Schedule',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white, fontSize: screenWidth * 0.08)),
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
                            'Stay on top of your tasks with timely notifications and a streamlined schedule. ',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontSize: screenWidth * 0.04,
                            ),
                      ),
                      TextSpan(
                          text: 'Organize',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontSize: screenWidth * 0.04,
                                    fontWeight: FontWeight.w700,
                                  )),
                      TextSpan(
                          text: ' your day, ',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontSize: screenWidth * 0.04,
                                  )),
                      TextSpan(
                          text: 'prioritize ',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontSize: screenWidth * 0.04,
                                    fontWeight: FontWeight.w700,
                                  )),
                      TextSpan(
                          text: 'effectively, and stay ',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontSize: screenWidth * 0.04,
                                  )),
                      TextSpan(
                          text: 'connected ',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontSize: screenWidth * 0.04,
                                    fontWeight: FontWeight.w700,
                                  )),
                      TextSpan(
                        text: 'with what matters.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white,
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
                  bgColor: Colors.white,
                  textColor: Colors.black,
                  borderColor: Colors.transparent,
                  onPressed: () {
                    Navigator.push(
                      context,
                      CustomPageRoute(
                          page: Welcome(), direction: AxisDirection.left),
                    );
                  },
                  assetName:
                      'assets/images/onboarding_images/onboarding-image-3.jpg',
                )),
          ],
        ));
  }
}
