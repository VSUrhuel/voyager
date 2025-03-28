import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[500]!),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.013,
            horizontal: screenHeight * 0.01,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: screenHeight * 0.03, // Adjust radius as needed
                    child: Image.asset(
                        'assets/images/application_images/profile.png'), // Replace with your image URL
                  ),
                  Padding(
                      padding: EdgeInsets.only(left: screenHeight * 0.01),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'rhuelxx',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: screenHeight *
                                      0.019, // Adjust font size as needed
                                  fontWeight: FontWeight.w500, // Semi-bold
                                ),
                              ),
                              SizedBox(width: screenHeight * 0.01),
                              Text(
                                '•',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: screenHeight *
                                      0.019, // Adjust font size as needed
                                ),
                              ),
                              SizedBox(width: screenHeight * 0.01),
                              Text(
                                '2 hours ago',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: screenHeight *
                                      0.015, // Adjust font size as needed
                                ),
                              ),
                            ],
                          ),
                          Container(
                              alignment: Alignment.center,
                              width: screenWidth * 0.3,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Color(0x501877F2),
                              ),
                              child: Text(
                                'Announcement',
                                style: TextStyle(
                                  color: Color(0xFF1877F2),
                                  fontSize: screenHeight *
                                      0.015, // Adjust font size as needed
                                  fontWeight: FontWeight.w500, // Semi-bold
                                ),
                              ))
                        ],
                      ))
                ],
              ),
              Divider(
                color: Colors.grey[500]!,
                thickness: 1,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: screenHeight * 0.01,
                    vertical: screenHeight * 0.01), // Add padding to the left
                child: Text(
                  'Hello, everyone! I am excited to announce that we will be having a webinar on the 30th of June. Please join us and learn more about the latest trends in the industry. See you there!',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize:
                        screenHeight * 0.019, // Adjust font size as needed
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
