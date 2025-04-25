import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:voyager/src/features/mentee/screens/profile/mentee_about.dart';
import 'package:voyager/src/features/mentee/screens/profile/mentee_security_password.dart';
import 'package:voyager/src/features/mentee/screens/profile/mentee_user_agreement.dart';
import 'package:voyager/src/features/mentee/screens/profile/personal_information.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:voyager/src/widgets/custom_page_route.dart';
import 'package:voyager/src/widgets/profile.dart';
import 'package:voyager/src/widgets/profile_list_tile.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';

class MenteeProfile extends StatefulWidget {
  const MenteeProfile({super.key});

  @override
  State<MenteeProfile> createState() => _MenteeProfileState();
}

class _MenteeProfileState extends State<MenteeProfile> {
  late UserModel userModel;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final firestore = FirestoreInstance();
    if (userId != null) {
      userModel = await firestore.getUser(userId);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
        bottom: true,
        top: false,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Padding(
              padding: EdgeInsets.only(
                top: screenHeight * 0.035,
                left: screenHeight * 0.01,
              ),
              child: Text(
                'My Profile',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: screenWidth * 0.07,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            centerTitle: false,
          ),
          body: isLoading
              ? Center(
                  child: Lottie.asset(
                  'assets/images/loading.json',
                  fit: BoxFit.cover,
                  width: screenHeight * 0.08,
                  height: screenWidth * 0.04,
                  repeat: true,
                ))
              : SingleChildScrollView(
                  child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.025),
                    Profile(role: 'mentee'),
                    SizedBox(height: screenHeight * 0.03),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04),
                          child: Text(
                            "Settings",
                            style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    ProfileListTile(
                      iconData: Icons.person,
                      text: "Personal Information",
                      onTap: () {
                        Navigator.push(
                          context,
                          CustomPageRoute(
                            page:
                                MenteePersonalInformation(userModel: userModel),
                          ),
                        );
                      },
                    ),
                    ProfileListTile(
                      iconData: Icons.lock,
                      text: "Security and Password",
                      onTap: () {
                        Navigator.push(
                          context,
                          CustomPageRoute(page: MenteeSecurityPassword()),
                        );
                      },
                    ),
                    ProfileListTile(
                      iconData: Icons.verified_user,
                      text: "User agreement",
                      onTap: () {
                        Navigator.push(
                          context,
                          CustomPageRoute(page: MenteeUserAgreement()),
                        );
                      },
                    ),
                    ProfileListTile(
                      iconData: Icons.info,
                      text: "About",
                      onTap: () {
                        Navigator.push(
                          context,
                          CustomPageRoute(page: MenteeAbout()),
                        );
                      },
                    ),
                  ],
                )),
        ));
  }
}
