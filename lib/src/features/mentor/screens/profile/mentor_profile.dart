import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentor/model/mentor_model.dart';
import 'package:voyager/src/features/mentor/screens/mentor_dashboard.dart';
import 'package:voyager/src/features/mentor/screens/profile/about.dart';
import 'package:voyager/src/features/mentor/screens/profile/personal_information_mentor.dart';
import 'package:voyager/src/features/mentor/screens/profile/security_password.dart';
import 'package:voyager/src/features/mentor/screens/profile/user_agreement.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:voyager/src/widgets/custom_page_route.dart';
import 'package:voyager/src/widgets/profile.dart';
import 'package:voyager/src/widgets/profile_list_tile.dart';

class MentorProfile extends StatefulWidget {
  const MentorProfile({super.key});

  @override
  State<MentorProfile> createState() => _MentorProfileState();
}

class _MentorProfileState extends State<MentorProfile> {
  FirestoreInstance firestore = FirestoreInstance();
  late MentorModel mentorModel;
  late UserModel userModel;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    mentorModel = await firestore.getMentorThroughAccId(FirebaseAuth.instance
        .currentUser!.uid); // Replace 'mentorId' with the actual argument
    userModel = await firestore.getUser(FirebaseAuth.instance.currentUser!
        .uid); // Replace 'userId' with the actual argument
  }

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
            onPressed: () {
              Navigator.of(context).push(
                CustomPageRoute(
                  page: MentorDashboard(index: 0),
                  direction: AxisDirection.right,
                ),
              );
            },
          ),
          title: const Text(
            "My Profile",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Profile(role: "mentor"),
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
                  CustomPageRoute(
                      page: MentorPersonalInformation(
                          mentorModel: mentorModel, userModel: userModel)),
                );
              },
            ),
            ProfileListTile(
              text: "Security and Password",
              onTap: () {
                Navigator.push(
                  context,
                  CustomPageRoute(page: SecuritySettingsScreen()),
                );
              },
            ),
            ProfileListTile(
              text: "User agreement",
              onTap: () {
                Navigator.push(
                  context,
                  CustomPageRoute(page: UserAgreement()),
                );
              },
            ),
            ProfileListTile(
              text: "About",
              onTap: () {
                Navigator.push(
                  context,
                  CustomPageRoute(page: AboutScreen()),
                );
              },
            ),
          ],
        ));
  }
}
