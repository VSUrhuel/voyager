import 'package:flutter/material.dart';
import 'package:voyager/src/features/mentee/screens/home/mentor_profile.dart';
import 'package:voyager/src/features/mentee/widgets/skills_display.dart';
// Import your MentorProfilePage

class MentorCard extends StatelessWidget {
  const MentorCard({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
                              "3rd Year",
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
                          "Francis Mark B.",
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
                          "CS mentor since 2023",
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.005),

                    // Skills Display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SkillsDisplay(
                          color: Colors.blue.shade300,
                          text: const Text("Mentor"),
                          width: 0.2,
                          height: 0.035,
                        ),
                        SizedBox(width: screenWidth * 0.04),
                        SkillsDisplay(
                          color: Colors.grey.shade300,
                          text: const Text("Mentor"),
                          width: 0.2,
                          height: 0.035,
                        ),
                      ],
                    ),

                    SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SkillsDisplay(
                          color: Colors.grey.shade300,
                          text: const Text("Mentor"),
                          width: 0.2,
                          height: 0.035,
                        ),
                        SizedBox(width: screenWidth * 0.04),
                        SkillsDisplay(
                          color: Colors.grey.shade300,
                          text: const Text("Mentor"),
                          width: 0.2,
                          height: 0.035,
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
