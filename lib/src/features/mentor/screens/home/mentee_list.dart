import 'package:voyager/src/features/mentee/widgets/normal_searchBar.dart';
import 'package:flutter/material.dart';

class MenteeList extends StatelessWidget {
  const MenteeList({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // Assuming a white background
        elevation: 1.0, // Optional: Add a subtle shadow
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black), // Black arrow back
          onPressed: () {
            Navigator.pop(context); // Go back when pressed
          },
        ),
        title: Text(
          'Mentees',
          style: TextStyle(
            color: Colors.black, // Black text
            fontWeight: FontWeight.normal, // Normal font weight
            fontSize: 18.0, // Adjust font size as needed
          ),
        ),
        centerTitle: true, // Align title to the left
      ),
      body: Column(
        children: [
          NormalSearchbar(),
          Padding(
            padding: EdgeInsets.only(
                left: screenWidth * 0.05, bottom: screenHeight * 0.02),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenHeight * 0.01),
                      backgroundColor: Color(0x601877F2),
                      foregroundColor: Color(0xFF1877F2)),
                  child: Text('Accepted'),
                ),
                SizedBox(width: screenWidth * 0.02),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenHeight * 0.01),
                      backgroundColor: Color(0x7F455A64),
                      foregroundColor: Color(0xFF4A4A4A)),
                  child: Text('Pending'),
                ),
                SizedBox(width: screenWidth * 0.02),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenHeight * 0.01),
                      backgroundColor: Color(0x7F455A64),
                      foregroundColor: Color(0xFF4A4A4A)),
                  child: Text('Rejected'),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                    left: screenWidth * 0.05, right: screenWidth * 0.05),
                child: Center(
                  child: Column(children: [
                    Text(
                      'No more requests',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: screenWidth * 0.03,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                  ]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
