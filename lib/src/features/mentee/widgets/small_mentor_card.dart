import 'package:voyager/src/features/mentee/widgets/skills_display.dart';
import 'package:flutter/material.dart';

class SmallMentorCard extends StatelessWidget {
  const SmallMentorCard({super.key});

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
                      .contain, // Or BoxFit.contain, or other BoxFit options
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(10), // Bottom left corner
                ),
                color: Colors.black,
              ),
              width: screenWidth * 0.5,
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
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: SizedBox(
                          width: screenWidth * 0.14, // Adjust width as needed
                          height:
                              screenHeight * 0.035, // Adjust height as needed
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
                                  fontSize: screenWidth * 0.025,
                                  color: Colors.white, // Text color
                                  fontWeight: FontWeight
                                      .bold, // Adjust font weight as needed
                                ),
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
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0, top: 4.0),
                        child: Text(
                          "Francis Mark B.",
                          style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: screenHeight * 0.005,
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text(
                          "CS mentor since 2023",
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            fontWeight: FontWeight.w300, // Make the font bold
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: screenHeight * 0.005,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 8.0, top: 4.0, right: 8.0),
                    child: Row(
                      children: [
                        SkillsDisplay(
                          color: Colors.blue.shade300,
                          text: Text("Mentor",
                              style: TextStyle(fontSize: screenWidth * 0.03)),
                          width: 0.14,
                          height: 0.03,
                        ),
                        SizedBox(
                          width: screenWidth * 0.04,
                        ),
                        SkillsDisplay(
                          color: Colors.grey.shade300,
                          text: Text("Mentor",
                              style: TextStyle(fontSize: screenWidth * 0.03)),
                          width: 0.14,
                          height: 0.03,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, bottom: 4.0, right: 8.0),
                    child: Row(
                      children: [
                        SkillsDisplay(
                          color: Colors.grey.shade300,
                          text: Text("Mentor",
                              style: TextStyle(fontSize: screenWidth * 0.03)),
                          width: 0.14,
                          height: 0.03,
                        ),
                        SizedBox(
                          width: screenWidth * 0.04,
                        ),
                        SkillsDisplay(
                          color: Colors.grey.shade300,
                          text: Text("Mentor",
                              style: TextStyle(fontSize: screenWidth * 0.03)),
                          width: 0.14,
                          height: 0.03,
                        ),
                      ],
                    ),
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
