import 'package:flutter/material.dart';
import 'package:voyager/src/widgets/profile.dart';
import 'package:voyager/src/widgets/profile_list_tile.dart';

class AdminProfile extends StatelessWidget {
  const AdminProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {},
          ),
          title: const Text(
            "My Profile",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Profile(role: 'Admin'),
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
                // Navigator.push(
                //   context,
                // CustomPageRoute(page: AdminPersonalInformation()),
                // );
              },
            ),
            ProfileListTile(
              text: "Security and Password",
              onTap: () {
                // Navigator.push(
                //   context,
                // CustomPageRoute(page: AdminPersonalInformation()),
                // );
              },
            ),
            ProfileListTile(
              text: "User agreement",
              onTap: () {
                // Navigator.push(
                //   context,
                // CustomPageRoute(page: AdminPersonalInformation()),
                // );
              },
            ),
            ProfileListTile(
              text: "About",
              onTap: () {
                // Navigator.push(
                //   context,
                //   // CustomPageRoute(page: AdminPersonalInformation()),
                // );
              },
            ),
          ],
        ));
  }
}
