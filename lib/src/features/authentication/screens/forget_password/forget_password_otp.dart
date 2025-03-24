import 'package:voyager/src/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OTPScreen extends StatelessWidget {
  const OTPScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: screenHeight * 0.09,
                ),
                SvgPicture.asset(
                  'assets/images/otp_images/otp.svg',
                  width: screenWidth * 0.6,
                ),
                Text('Reset Password',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: screenWidth * 0.08,
                        )),
                Text(
                  'Enter the 6 digit code sent to your email',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: screenWidth * 0.04,
                      ),
                ),
                SizedBox(
                  height: screenHeight * 0.03,
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: screenWidth * 0.13,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            counterText: '', // Hides the maxLength counter
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.02,
                ),
                Text.rich(TextSpan(children: [
                  TextSpan(
                    text: 'Resend OTP in ',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: screenWidth * 0.04,
                        ),
                  ),
                  TextSpan(
                      text: '53 seconds',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: screenWidth * 0.04,
                          color: Theme.of(context).primaryColor))
                ])),
                SizedBox(
                  height: screenHeight * 0.02,
                ),
                DefaultButton(
                  buttonText: 'Proceed',
                  bgColor: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  borderColor: Colors.transparent,
                )
              ],
            ),
          ),
        ));
  }
}
