import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:voyager/src/features/admin/screens/profile/admin_security_password.dart';
import 'package:voyager/src/features/admin/screens/profile/personal_information_admin.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentor/screens/profile/about.dart';
import 'package:voyager/src/features/mentor/screens/profile/user_agreement.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:voyager/src/widgets/custom_page_route.dart';
import 'package:voyager/src/widgets/profile.dart';
import 'package:voyager/src/widgets/profile_list_tile.dart';

class AdminProfile extends StatefulWidget {
  const AdminProfile({super.key});

  @override
  State<AdminProfile> createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {
  FirestoreInstance firestore = FirestoreInstance();
  late UserModel userModel;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    userModel = await firestore.getUser(FirebaseAuth.instance.currentUser!.uid);
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
              iconData: Icons.person,
              text: "Personal Information",
              onTap: () async {
                Navigator.push(
                  context,
                  CustomPageRoute(
                      page: AdminPersonalInformation(userModel: userModel)),
                );
              },
            ),
            ProfileListTile(
              iconData: Icons.lock,
              text: "Security and Password",
              onTap: () {
                Navigator.push(
                  context,
                  CustomPageRoute(page: AdminSecuritySettingsScreen()),
                );
              },
            ),
            ProfileListTile(
              iconData: Icons.verified_user,
              text: "User agreement",
              onTap: () {
                Navigator.push(
                  context,
                  CustomPageRoute(page: UserAgreement()),
                );
              },
            ),
            ProfileListTile(
              iconData: Icons.info,
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
