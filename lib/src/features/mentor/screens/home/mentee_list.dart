import 'package:voyager/src/features/mentee/widgets/normal_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:voyager/src/features/mentor/widget/status_toggle_button.dart';

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
                  left: screenWidth * 0.05,
                  bottom: screenHeight * 0.02,
                  right: screenWidth * 0.05),
              child: StatusToggleButton()),
        ],
      ),
    );
  }
}
