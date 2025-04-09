import 'package:flutter/material.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentee/screens/home/mentor_profile.dart';
import 'package:voyager/src/features/mentee/widgets/skills_display.dart';
import 'package:voyager/src/features/mentor/model/mentor_model.dart';

class SmallMentorCard extends StatelessWidget {
  final MentorModel mentorModel;
  final UserModel user;
  const SmallMentorCard(
      {super.key, required this.mentorModel, required this.user});

  @override
  Widget build(BuildContext context) {
    String formatName(String fullName) {
      List<String> nameParts = fullName.split(" ");
      if (nameParts.isEmpty) return "";
      if (nameParts.length == 1) {
        return nameParts[0][0].toUpperCase() +
            nameParts[0].substring(1).toLowerCase();
      }
      String lastName = nameParts.last[0].toUpperCase() +
          nameParts.last.substring(1).toLowerCase();
      String initials = nameParts
          .sublist(0, nameParts.length - 1)
          .map((name) => name[0].toUpperCase())
          .join("");
      return "$initials $lastName";
    }

    String shortenMotto(String mentorMotto) {
      List<String> words = mentorMotto.split(" ");
      if (words.length <= 6) {
        return mentorMotto;
      }
      return "${words.sublist(0, 6).join(" ")}...";
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final mentorName = formatName(user.accountApiName);
    final motto = shortenMotto(mentorModel.mentorMotto);
    final List<String> skills = mentorModel.mentorExpertise;

    // Set a fixed height for the entire card
    const double cardHeight = 300.0;

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
        child: Container(
          height: cardHeight, // Fixed height for all cards
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
                width: screenWidth * 0.45,
                height: cardHeight *
                    0.45, // Adjust profile image height proportionally
              ),
              SizedBox(height: screenHeight * 0.01),
              // Mentor Details
              SizedBox(
                width: screenWidth * 0.4,
                child: Column(
                  children: [
                    // Year Badge
                    Row(
                      children: [
                        Container(
                          width: screenWidth * 0.15,
                          height: screenHeight * 0.03,
                          decoration: BoxDecoration(
                            color: const Color(0xFF52CA82),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              mentorModel.mentorYearLvl,
                              style: TextStyle(
                                fontSize: screenWidth * 0.025,
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
                            fontSize: screenWidth * 0.045,
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
                            fontSize: screenWidth * 0.03,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    // Skills Display
                    Column(
                      children: [
                        for (int i = 0; i < skills.length; i += 2)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SkillsDisplay(
                                  color: i == 0
                                      ? Colors.blue.shade300
                                      : Colors.grey.shade300,
                                  text: Text(skills[i].split(" ").first),
                                  width: 0.2,
                                  height: 0.03,
                                ),
                                SizedBox(width: screenWidth * 0.03),
                                if (i + 1 < skills.length)
                                  SkillsDisplay(
                                    color: Colors.grey.shade300,
                                    text: Text(skills[i + 1].split(" ").first),
                                    width: 0.2,
                                    height: 0.03,
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
