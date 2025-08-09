import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:voyager/src/features/authentication/controllers/email_verification_controller.dart';

class EmailVerification extends StatelessWidget {
  const EmailVerification({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller using Get.put()
    final controller = Get.put(EmailVerificationController());
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Use a user object from FirebaseAuth to display the user's email
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        // Automatically add a back button that triggers the signOut method
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => controller.signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // -- IMAGE --
              SvgPicture.asset(
                'assets/images/email_verification/email_verification.svg',
                width: screenWidth * 0.6,
              ),
              SizedBox(height: screenHeight * 0.04),

              // -- TITLE & SUBTITLE --
              Text(
                'Verify Your Email',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.02),
              // Display the user's email for clarity
              Text(
                user?.email ?? 'your email address',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                'We have sent a verification link to your inbox. Please click the link to continue.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.04),
              Center(
                  child: Padding(
                      padding: EdgeInsets.only(top: screenHeight * 0.01),
                      child: SizedBox(
                        width: screenWidth * 0.4,
                        height: screenHeight * 0.08,
                        child: OutlinedButton(
                          onPressed: () =>
                              controller.manuallyCheckEmailVerificationStatus(),
                          child: Text(
                            'Continue',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: screenWidth * 0.04,
                                      color: Color(0xFF1877F2),
                                    ),
                          ),
                        ),
                      ))),
              SizedBox(height: screenHeight * 0.02),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => controller.sendVerificationEmail(),
                      child: Text(
                        'Resend E-mail Link',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Color(0xFF1877F2),
                              fontSize: screenWidth * 0.04,
                            ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                  ],
                ),
            
              ),
            ],
          ),
        ),
      ),
    );
  }
}
