import 'package:voyager/src/features/mentee/widgets/normal_searchBar.dart';
import 'package:voyager/src/features/mentee/widgets/small_mentor_card.dart';
import 'package:voyager/src/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';

class MentorsList extends StatelessWidget {
  const MentorsList({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    int itemCount = 6; // Number of SmallMentorCards
    List<Widget> rows = [];

    for (int i = 0; i < itemCount; i += 2) {
      if (i + 1 < itemCount) {
        rows.add(
          Row(
            children: [
              Expanded(child: SmallMentorCard()),
              SizedBox(width: 8.0), // Add spacing between cards
              Expanded(child: SmallMentorCard()),
            ],
          ),
        );
      } else {
        rows.add(
          Row(
            children: [
              Expanded(child: SmallMentorCard()),
            ],
          ),
        );
      }
      rows.add(SizedBox(height: 8.0));
    }
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
          'Mentors List',
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
          NormalSearchbar(), // Add the NormalSearchbar widget
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                    left: screenWidth * 0.05, right: screenWidth * 0.05),
                child: Column(children: rows),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
