import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:flutter/material.dart';

class UserCard extends StatelessWidget {
  const UserCard({super.key, required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    void showMessage(BuildContext context, String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }

    return Container(
      width: screenWidth * 0.85,
      height: screenHeight * 0.11, // Slightly increased for better spacing
      padding: EdgeInsets.only(left: screenHeight * 0.007, top: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(width: 1, color: const Color(0xFF9494A0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Profile Image
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(9),
              bottomLeft: Radius.circular(9),
            ),
            child: Image.asset(
              'assets/images/application_images/code.jpg',
              width: screenWidth * 0.15,
              height: screenHeight * 0.09,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10), // Spacing

          // User Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  user.accountApiName ?? 'no-name-provided',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: screenHeight * 0.02,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  user.accountApiEmail ?? 'no-email-provided',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: screenHeight * 0.016,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.underline,
                  ),
                ),
                Text(
                  user.accountStudentId ?? 'no-student-id-provided',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: screenHeight * 0.015,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // More options button
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: Colors.black,
              size: screenHeight * 0.035,
            ),
            onSelected: (value) {
              if (value == 'accept') {
                showMessage(context, 'Accepted');
              } else if (value == 'reject') {
                showMessage(context, 'Rejected');
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'accept',
                child: Text('Accept'),
              ),
              PopupMenuItem<String>(
                value: 'reject',
                child: Text('Reject'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
