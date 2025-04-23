import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';

class MentorDraftCard extends StatelessWidget {
  final UserModel userModel;


  const MentorDraftCard({
    super.key,
    required this.userModel,

  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return InkWell(
      onTap: () {
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Waiting for Mentor Response',
            message: 'Mentor Details are not available yet',
            contentType: ContentType.warning, // Changed to warning for better semantics
          ),
        );

        // Show the snackbar
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
        
      },
      child: Card(
          color: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
            side: BorderSide(
              color: Color(0xFF9494A0),
              width: 0.5,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(left: screenWidth * 0.02),
            child: SizedBox(
              height: screenHeight * 0.09,
              width: screenWidth * 0.9,
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                SizedBox(
                  width: screenWidth * 0.2,
                  child: userModel.accountApiPhoto.isNotEmpty?

                  ClipRRect(
                    borderRadius: BorderRadius.circular(10), // Adjust for desired roundness
                    child: Image.network(
                      userModel.accountApiPhoto,
                      fit: BoxFit.cover, // Ensures the image covers the space
                      width: screenWidth * 0.15,
                      height: screenWidth * 0.15,
                    ),
                  )
                  : CircleAvatar(
                      radius: screenWidth * 0.05,
                      child: Icon(
                        Icons.person,
                        size: screenWidth * 0.05,
                      ),
                    ),
                ),
                SizedBox(width: screenWidth * 0.02),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(userModel.accountApiName,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                          )),
                      SizedBox(height: screenHeight * 0.002),
                      Row(children: [
                        Builder(
                          builder: (context) {
                        
                            return Text(
                              userModel.accountApiEmail.length > 30
                              ?   userModel.accountApiEmail.substring(0, 30) +
                                        '...'
                                : userModel.accountApiEmail,
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                        ),
                      ]),
                      Row(children: [

                        // Time range
                        Text(
                          'No Schedule Chosen', // Get time portion
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: screenWidth * 0.035,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                      ]),
                    ]),
                Spacer(),
                
              ])),
          )),

    );
  }

}
