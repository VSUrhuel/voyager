import 'package:voyager/src/features/mentee/widgets/skills_display.dart';
import 'package:flutter/material.dart';

class MentorCard extends StatelessWidget {
  const MentorCard({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(0.0),
        child: Column(
          children: [
            Container(
              //Upper Display
              decoration: BoxDecoration(
                image: DecorationImage(
                  // Use DecorationImage
                  image: AssetImage(
                      'assets/images/application_images/profile.png'), // Use AssetImage
                  fit: BoxFit
                      .fitWidth, // Or BoxFit.contain, or other BoxFit options
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(10), // Bottom left corner
                ),
                color: Colors.black,
              ),
              width: screenWidth * 0.6,
              height: screenHeight * 0.22,
            ),
            //Container for details
            SizedBox(
              height: screenHeight * 0.01,
            ),
            SizedBox(
              width: screenWidth * 0.5,
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: screenWidth * 0.18, // Adjust width as needed
                        height: screenHeight * 0.035, // Adjust height as needed
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(
                                0xFF52CA82), // Light Green Color (adjust as needed)
                            borderRadius: BorderRadius.circular(
                                20), // Half of height for pill shape
                            boxShadow: [
                              // Add shadow for depth
                            ],
                          ),
                          child: Center(
                            // Center the text within the container
                            child: Text(
                              "3rd Year",
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                color: Colors.white, // Text color
                                fontWeight: FontWeight
                                    .bold, // Adjust font weight as needed
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: screenHeight * 0.0,
                  ),
                  Row(
                    children: [
                      Text(
                        "Francis Mark B.",
                        style: TextStyle(
                            fontSize: screenWidth * 0.055,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: screenHeight * 0.005,
                  ),
                  Row(
                    children: [
                      Text(
                        "CS mentor since 2023",
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.w300, // Make the font bold
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: screenHeight * 0.005,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkillsDisplay(
                        color: Colors.blue.shade300,
                        text: Text("Mentor"),
                        width: 0.2,
                        height: 0.035,
                      ),
                      SizedBox(
                        width: screenWidth * 0.04,
                      ),
                      SkillsDisplay(
                        color: Colors.grey.shade300,
                        text: Text("Mentor"),
                        width: 0.2,
                        height: 0.035,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkillsDisplay(
                        color: Colors.grey.shade300,
                        text: Text("Mentor"),
                        width: 0.2,
                        height: 0.035,
                      ),
                      SizedBox(
                        width: screenWidth * 0.04,
                      ),
                      SkillsDisplay(
                        color: Colors.grey.shade300,
                        text: Text("Mentor"),
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
    );
  }
}
