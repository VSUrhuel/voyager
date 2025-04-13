// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentor/model/mentor_model.dart';
import 'package:voyager/src/features/mentor/screens/input_information/mentor_info1.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:voyager/src/widgets/custom_page_route.dart';

class MentorPersonalInformation extends StatefulWidget {
  const MentorPersonalInformation(
      {super.key, required this.mentorModel, required this.userModel});
  final MentorModel mentorModel;
  final UserModel userModel;

  @override
  State<MentorPersonalInformation> createState() =>
      _MentorPersonalInformationState();
}

class _MentorPersonalInformationState extends State<MentorPersonalInformation> {
  FirestoreInstance firestore = FirestoreInstance();
  late MentorModel mentorModel;
  late UserModel userModel;

  @override
  void initState() {
    super.initState();
    mentorModel = widget.mentorModel;
    userModel = widget.userModel;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final supabase = Supabase.instance.client;
    final imageUrl = (userModel.accountApiPhoto.isNotEmpty)
        ? (userModel.accountApiPhoto.startsWith('http')
            ? userModel.accountApiPhoto
            : supabase.storage
                .from('profile-picture')
                .getPublicUrl(userModel.accountApiPhoto))
        : 'https://zyqxnzxudwofrlvdzbvf.supabase.co/storage/v1/object/public/profile-picture/profile.png';

    String toTitleCase(String name) {
      if (name.isEmpty) return name;
      if (name.length == 1) return name.toUpperCase();
      return name
          .toLowerCase()
          .split(' ')
          .map((word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1)}'
              : '')
          .join(' ');
    }

    final formattedName = toTitleCase(userModel.accountApiName);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Image
                Stack(
                  children: [
                    Container(
                      height: screenHeight * 0.4,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 10,
                      left: 16,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.black, size: 30),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),

                // Profile Details
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05, vertical: 20),
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name & Year Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.02,
                                vertical: screenHeight * 0),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              mentorModel.mentorYearLvl,
                              style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.black),
                            onPressed: () {
                              Navigator.push(
                                context,
                                CustomPageRoute(
                                    page: MentorInfo1(
                                        mentorModel: mentorModel,
                                        userModel: userModel)),
                              );
                            },
                          ),
                        ],
                      ),

                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                left: screenWidth * 0.02,
                                top: screenHeight * 0.0),
                            child: Text(
                              formattedName,
                              style: TextStyle(
                                  fontSize: screenHeight * 0.03,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03),
                        child: Text(
                          userModel.accountApiEmail,
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                      ),

                      const SizedBox(height: 20),
                      Row(
                        children: [],
                      ),
                      // About Section (Title Inside Border)
                      _infoCardWithTitle("About", mentorModel.mentorAbout),

                      const SizedBox(height: 20),
                      Row(
                        children: [
                          // Experience Section (60% width)
                          Expanded(
                            flex: 7,
                            child: _experienceSection(screenHeight),
                          ),

                          const SizedBox(width: 10),

                          // Mentorship Sessions (40% width)
                          Expanded(
                            flex: 3,
                            child: _mentorshipCard(
                                mentorModel.mentorSessionCompleted.toString(),
                                "Mentorship Sessions Completed",
                                screenHeight),
                          ),
                        ],
                      ),

                      // Experience Section with New UI

                      const SizedBox(height: 20),

                      // Language Known
                      _sectionTitle("Language Known"),
                      Wrap(
                        spacing: 8,
                        children: [
                          for (int i = 0;
                              i < mentorModel.mentorLanguages.length;
                              i++)
                            _languageChip(mentorModel.mentorLanguages[i]),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Social Links
                      _sectionTitle("Social Links"),
                      Row(
                        children: [
                          _socialIcon(Icons.facebook, Colors.blue,
                              mentorModel.mentorFbUrl, context),
                          const SizedBox(width: 20),
                          _socialIcon(
                              FontAwesomeIcons.github,
                              Colors.blue.shade800,
                              mentorModel.mentorGitUrl,
                              context),
                        ],
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// Section Title Inside Border
  Widget _infoCardWithTitle(String title, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  // Experience Section with Improved UI
  Widget _experienceSection(double screenHeight) {
    final isExperienceEmpty = mentorModel.mentorExpHeader.isEmpty ||
        mentorModel.mentorExpDesc.isEmpty;

    return Container(
      height: screenHeight * 0.4,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Experience",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (isExperienceEmpty)
            const Text(
              "No Experience",
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            for (int i = 0; i < mentorModel.mentorExpHeader.length; i++)
              _experienceItem(mentorModel.mentorExpHeader[i], i),
        ],
      ),
    );
  }

  // Individual Experience Item
  Widget _experienceItem(String title, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "• $title",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            mentorModel.mentorExpDesc[index],
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  // Mentorship Card Widget
  Widget _mentorshipCard(String number, String label, double screenHeight) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: 120,
      height: screenHeight * 0.4,
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, // Centers content vertically
        children: [
          Text(
            number,
            style: const TextStyle(
                fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 8), // Adds spacing between number and label
          Text(
            label,
            textAlign: TextAlign.center,
            style:
                TextStyle(color: Colors.green, fontSize: screenHeight * 0.015),
          ),
        ],
      ),
    );
  }

  // Section Title Widget
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  // Language Chip Widget
  Widget _languageChip(String text) {
    return Theme(
      data: ThemeData(
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.transparent), // Transparent border
            borderRadius: BorderRadius.circular(20), // Keeps rounded shape
          ),
        ),
      ),
      child: Chip(
        label: Text(
          text,
          style:
              const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade100,
      ),
    );
  }

  // Social Icon Widget
  Widget _socialIcon(
      IconData icon, Color color, String url, BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.01),
      child: InkWell(
        onTap: () async {
          final uri = Uri.tryParse(url);
          print(uri);
          if (uri != null) {
            if (!await launchUrl(uri)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to open $uri! Contact your mentor.'),
                ),
              );
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 30, color: color),
        ),
      ),
    );
  }
}
