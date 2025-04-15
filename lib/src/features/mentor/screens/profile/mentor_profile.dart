import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:voyager/src/features/admin/models/course_mentor_model.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentee/model/course_model.dart';
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
  // Constants
  static const _appBarTitle = "My Profile";
  static const _mentorInterfaceTitle = "Mentor Interface";
  static const _settingsTitle = "Settings";
  static const _noCourseMessage =
      "No course assignment found. Please contact the admin.";
  static const _courseAllocationIssue =
      "If there is an issue with your course allocation, please contact the admin.";

  // Services
  final FirestoreInstance firestore = FirestoreInstance();

  // Models
  late MentorModel mentorModel;
  late UserModel userModel;
  late CourseMentorModel courseMentorModel;
  String courseName = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser!;

      mentorModel = await firestore.getMentorThroughAccId(currentUser.uid);
      userModel = await firestore.getUser(currentUser.uid);
      courseMentorModel =
          await firestore.getCourseMentorThroughMentor(mentorModel.mentorId);

      final courseModel = await firestore.getCourse(courseMentorModel.courseId);

      if (mounted) {
        setState(() {
          courseName = courseModel.courseName;
        });
      }
    } catch (e) {
      // Handle error appropriately
      if (mounted) {
        setState(() {
          courseName = '';
        });
      }
    }
  }

  Widget _buildMentorInfoCard(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.2,
      width: screenWidth * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        border: Border.all(
          color: Theme.of(context).primaryColor,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.02,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.info,
                  color: Theme.of(context).primaryColor,
                  size: screenWidth * 0.06,
                ),
                SizedBox(width: screenWidth * 0.03),
                Text(
                  _mentorInterfaceTitle,
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),

            SizedBox(height: screenHeight * 0.01),

            // Course Info
            if (courseName.isNotEmpty && courseName.trim().isNotEmpty)
              Column(
                children: [
                  Text(
                    "The admin assigned you as a mentor for",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Text(
                    courseName.trim(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              )
            else
              Text(
                _noCourseMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),

            // Footer note
            SizedBox(height: screenHeight * 0.01),
            Text(
              _courseAllocationIssue,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenWidth * 0.03,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).push(
            CustomPageRoute(
              page: MentorDashboard(index: 0),
              direction: AxisDirection.right,
            ),
          ),
        ),
        title: const Text(
          _appBarTitle,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Profile(role: "mentor"),
            SizedBox(height: screenHeight * 0.03),

            // Settings Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: screenWidth * 0.04),
                    child: Text(
                      _settingsTitle,
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.01),

                  // Profile Options
                  ProfileListTile(
                    iconData: Icons.person,
                    text: "Personal Information",
                    onTap: () => Navigator.push(
                      context,
                      CustomPageRoute(
                        page: MentorPersonalInformation(
                          mentorModel: mentorModel,
                          userModel: userModel,
                        ),
                      ),
                    ),
                  ),
                  ProfileListTile(
                    iconData: Icons.lock,
                    text: "Security and Password",
                    onTap: () => Navigator.push(
                      context,
                      CustomPageRoute(page: SecuritySettingsScreen()),
                    ),
                  ),
                  ProfileListTile(
                    iconData: Icons.verified_user,
                    text: "User agreement",
                    onTap: () => Navigator.push(
                      context,
                      CustomPageRoute(page: UserAgreement()),
                    ),
                  ),
                  ProfileListTile(
                    iconData: Icons.info,
                    text: "About",
                    onTap: () => Navigator.push(
                      context,
                      CustomPageRoute(page: AboutScreen()),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.02),

            // Mentor Info Card
            Center(child: _buildMentorInfoCard(context)),
          ],
        ),
      ),
    );
  }
}
