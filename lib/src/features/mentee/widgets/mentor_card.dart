import 'package:flutter/material.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentee/screens/home/mentor_profile.dart';
import 'package:voyager/src/features/mentee/widgets/skills_display.dart';
import 'package:voyager/src/features/mentor/model/mentor_model.dart';
// Import your MentorProfilePage

class MentorCard extends StatelessWidget {
  final MentorModel mentorModel;
  final UserModel user;
  const MentorCard({super.key, required this.mentorModel, required this.user});

  @override
  Widget build(BuildContext context) {
    String formatName(String fullName) {
      List<String> nameParts = fullName.split(" ");

      if (nameParts.isEmpty) return "";

      if (nameParts.length == 1) {
        // If there's only one name, capitalize the first letter and lowercase the rest
        return nameParts[0][0].toUpperCase() +
            nameParts[0].substring(1).toLowerCase();
      }

      // Extract last name and format it (capitalize first letter, lowercase the rest)
      String lastName = nameParts.last[0].toUpperCase() +
          nameParts.last.substring(1).toLowerCase();

      // Convert all given names (except last) to initials
      String initials = nameParts
          .sublist(0, nameParts.length - 1)
          .map((name) => name[0].toUpperCase()) // Get first letter as uppercase
          .join(""); // Join initials

      return "$initials $lastName"; // Combine initials and formatted last name
    }

    String shortenMotto(String mentorMotto) {
      List<String> words = mentorMotto.split(" ");

      if (words.length <= 6) {
        return mentorMotto; // Return as is if it's 6 words or less
      }

      return "${words.sublist(0, 6).join(" ")}..."; // Take first 6 words and add "..."
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final mentorName = formatName(user.accountApiName);
    final motto = shortenMotto(mentorModel.mentorMotto);
    final List<String> skills = mentorModel.mentorExpertise;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MentorProfilePage()),
        );
      },
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // Upper Display (Profile Image)
              Container(
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage(
                        'assets/images/application_images/profile.png'),
                    fit: BoxFit.fitWidth,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black,
                ),
                width: screenWidth * 0.6,
                height: screenHeight * 0.22,
              ),

              SizedBox(height: screenHeight * 0.01),

              // Mentor Details
              SizedBox(
                width: screenWidth * 0.5,
                child: Column(
                  children: [
                    // Year Badge
                    Row(
                      children: [
                        Container(
                          width: screenWidth * 0.18,
                          height: screenHeight * 0.035,
                          decoration: BoxDecoration(
                            color: const Color(0xFF52CA82),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              mentorModel.mentorYearLvl,
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.005),

                    // Mentor Name
                    Row(
                      children: [
                        Text(
                          mentorName,
                          style: TextStyle(
                            fontSize: screenWidth * 0.055,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.005),

                    // Mentor Info
                    Row(
                      children: [
                        Text(
                          motto,
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.005),

                    Column(
                      children: [
                        for (int i = 0;
                            i < skills.length;
                            i += 2) // Iterate in pairs
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: 10), // Spacing between rows
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SkillsDisplay(
                                  color: i == 0
                                      ? Colors.blue.shade300
                                      : Colors.grey.shade300,
                                  text: Text(skills[i]
                                      .split(" ")
                                      .first), // Show only the first word
                                  width: 0.23,
                                  height: 0.035,
                                ),
                                SizedBox(width: screenWidth * 0.04),
                                if (i + 1 <
                                    skills
                                        .length) // Ensure the second skill exists
                                  SkillsDisplay(
                                    color: Colors.grey.shade300,
                                    text: Text(skills[i + 1]
                                        .split(" ")
                                        .first), // Show only the first word
                                    width: 0.23,
                                    height: 0.035,
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
