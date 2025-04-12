// ignore_for_file: deprecated_member_use

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentor/model/mentor_model.dart';
import 'package:voyager/src/features/mentor/screens/input_information/mentor_info1.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:voyager/src/widgets/custom_page_route.dart';

class AdminPersonalInformation extends StatefulWidget {

  const AdminPersonalInformation({super.key,
    required this.userModel,
  });
  final UserModel userModel;

  @override
  State<AdminPersonalInformation> createState() =>
      _AdminPersonalInformationState();
}

class _AdminPersonalInformationState extends State<AdminPersonalInformation> {
  FirestoreInstance firestore = FirestoreInstance();
   late UserModel userModel;

  @override
  void initState() {
    super.initState();
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
                            child: const Text(
                              "Eduvate Admin",
                              style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          // IconButton(
                          //   icon: const Icon(Icons.edit, color: Colors.black),
                          //   onPressed: () {
                          //     Navigator.push(
                          //       context,
                          //       CustomPageRoute(
                          //           page: MentorInfo1(
                          //               mentorModel: mentorModel,
                          //               userModel: userModel)),
                          //     );
                          //   },
                          // ),
                        ],
                      ),

                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                left: screenWidth * 0.02,
                                top: screenHeight * 0.0),
                            child: Text(
                              userModel.accountApiName,
                              style: TextStyle(
                                  fontSize: screenHeight * 0.04,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03),
                        child: Text(
                          userModel.accountUsername,
                          style: TextStyle(color: Colors.black54, fontSize: 30, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03,
                            vertical: screenHeight * 0.01),
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
                      _infoCardWithTitle("About",
                          "A dedicated administrator with experience overseeing a digital mentorship platform designed to connect computer science students for guided learning, collaboration, and career development. Skilled in managing user engagement, streamlining mentor-mentee matching processes, and ensuring a seamless user experience. Passionate about fostering inclusive, tech-forward learning communities and leveraging technology to bridge the gap between academic learning and real-world application."),

                      const SizedBox(height: 20),
                      // Row(
                      //   children: [
                      //     // Experience Section (60% width)
                      //     Expanded(
                      //       flex: 7,
                      //       child: _experienceSection(screenHeight),
                      //     ),

                      //     const SizedBox(width: 10),

                      //     // Mentorship Sessions (40% width)
                      //     Expanded(
                      //       flex: 3,
                      //       child: _mentorshipCard("10",
                      //           "Mentorship Sessions Completed", screenHeight),
                      //     ),
                      //   ],
                      // ),

                      // Experience Section with New UI

                      // const SizedBox(height: 20),

                      // // Language Known
                      // _sectionTitle("Language Known"),
                      // Wrap(
                      //   spacing: 8,
                      //   children: [
                      //     _languageChip("Waray-waray"),
                      //     _languageChip("Cebuano"),
                      //     _languageChip("Filipino"),
                      //     _languageChip("English"),
                      //   ],
                      // ),

                      // const SizedBox(height: 20),

                      // // Social Links
                      // _sectionTitle("Social Links"),
                      // Row(
                      //   children: [
                      //     _socialIcon(Icons.facebook, Colors.blue),
                      //     const SizedBox(width: 20),
                      //     _socialIcon(Icons.link, Colors.blue.shade800),
                      //   ],
                      // ),

                      // const SizedBox(height: 30),
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
          const SizedBox(height: 10),
          Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          
        ],
      ),
    );
  }

  // Experience Section with Improved UI
  // Widget _experienceSection(double screenHeight) {
  //   return Container(
  //     height: screenHeight * 0.4,
  //     padding: const EdgeInsets.all(12),
  //     decoration: BoxDecoration(
  //       color: Colors.blue.shade50,
  //       borderRadius: BorderRadius.circular(12),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text(
  //           "Experience",
  //           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //         ),
  //         const SizedBox(height: 10),
  //         _experienceItem("Product Designer at Google"),
  //         _experienceItem("Product Designer at Google"),
  //         _experienceItem("Product Designer at Google"),
  //       ],
  //     ),
  //   );
  // }

  // Individual Experience Item
  // Widget _experienceItem(String title) {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 8),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           "• $title",
  //           style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
  //         ),
  //         const SizedBox(height: 4),
  //         const Text(
  //           "Lorem ipsum dolor sit amet consectetur.",
  //           style: TextStyle(fontSize: 14, color: Colors.black87),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Mentorship Card Widget
  // Widget _mentorshipCard(String number, String label, double screenHeight) {
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     width: 120,
  //     height: screenHeight * 0.4,
  //     decoration: BoxDecoration(
  //       color: Colors.green.shade100,
  //       borderRadius: BorderRadius.circular(12),
  //     ),
  //     child: Column(
  //       mainAxisAlignment:
  //           MainAxisAlignment.center, // Centers content vertically
  //       children: [
  //         Text(
  //           number,
  //           style: const TextStyle(
  //               fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
  //         ),
  //         const SizedBox(height: 8), // Adds spacing between number and label
  //         Text(
  //           label,
  //           textAlign: TextAlign.center,
  //           style:
  //               TextStyle(color: Colors.green, fontSize: screenHeight * 0.015),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // // Section Title Widget
  // Widget _sectionTitle(String title) {
  //   return Text(
  //     title,
  //     style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //   );
  // }

  // // Language Chip Widget
  // Widget _languageChip(String text) {
  //   return Theme(
  //     data: ThemeData(
  //       chipTheme: ChipThemeData(
  //         shape: RoundedRectangleBorder(
  //           side: BorderSide(color: Colors.transparent), // Transparent border
  //           borderRadius: BorderRadius.circular(20), // Keeps rounded shape
  //         ),
  //       ),
  //     ),
  //     child: Chip(
  //       label: Text(
  //         text,
  //         style:
  //             const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
  //       ),
  //       backgroundColor: Colors.blue.shade100,
  //     ),
  //   );
  // }

  // // Social Icon Widget
  // Widget _socialIcon(IconData icon, Color color) {
  //   return Container(
  //     padding: const EdgeInsets.all(8),
  //     decoration: BoxDecoration(
  //       color: color.withOpacity(0.1),
  //       shape: BoxShape.circle,
  //     ),
  //     child: Icon(icon, size: 30, color: color),
  //   );
  // }
}
