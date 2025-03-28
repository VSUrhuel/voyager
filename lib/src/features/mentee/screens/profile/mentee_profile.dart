import 'package:voyager/src/features/mentee/screens/profile/personal_information.dart';
import 'package:voyager/src/widgets/custom_page_route.dart';
import 'package:voyager/src/widgets/profile.dart';
import 'package:voyager/src/widgets/profile_list_tile.dart';
import 'package:flutter/material.dart';

class MenteeProfile extends StatelessWidget {
  const MenteeProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Padding(
            padding: EdgeInsets.only(
                top: screenHeight * 0.035,
                left: screenHeight * 0.01), // Add padding to the left
            child: Text(
              'My Profile',
              style: TextStyle(
                color: Colors.black,
                fontSize: screenHeight * 0.037, // Adjust font size as needed
                fontWeight: FontWeight.bold, // Bold
              ),
            ),
          ),
          centerTitle: false,
        ),
        body: Container(
            child: Column(
          children: [
            SizedBox(height: screenHeight * 0.025),
            Profile(role: 'mentee'),
            SizedBox(height: screenHeight * 0.03),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: Text(
                    "Settings",
                    style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.01),
            //Add ProfileListTile widget
            ProfileListTile(
              text: "Personal Information",
              onTap: () {
                Navigator.push(
                  context,
                  CustomPageRoute(page: PersonalInformation()),
                );
              },
            ),
            ProfileListTile(
              text: "Security and Password",
              onTap: () {
                Navigator.push(
                  context,
                  CustomPageRoute(page: PersonalInformation()),
                );
              },
            ),
            ProfileListTile(
              text: "User agreement",
              onTap: () {
                Navigator.push(
                  context,
                  CustomPageRoute(page: PersonalInformation()),
                );
              },
            ),
            ProfileListTile(
              text: "About",
              onTap: () {
                Navigator.push(
                  context,
                  CustomPageRoute(page: PersonalInformation()),
                );
              },
            ),
          ],
        )));
  }
}
