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

  Widget _buildCapabilityItem(
    BuildContext context,
    IconData icon,
    String text,
    double screenWidth,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.01),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: screenWidth * 0.05,
            color: Theme.of(context).primaryColor.withOpacity(0.7),
          ),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: screenWidth * 0.038,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCardInfo(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        // Admin badge with icon
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.01,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.admin_panel_settings,
                color: Theme.of(context).primaryColor,
                size: screenWidth * 0.06,
              ),
              SizedBox(width: screenWidth * 0.02),
              Text(
                "Application Administrator",
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: screenHeight * 0.02),

        // Admin capabilities in a card
      ],
    );
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
        body: SingleChildScrollView(
            child: Column(
          children: [
            Profile(role: 'Admin'),
            SizedBox(height: screenHeight * 0.03),
            _buildAdminCardInfo(context),
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
              text: "Administrative Privileges",
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
        )));
  }
}
