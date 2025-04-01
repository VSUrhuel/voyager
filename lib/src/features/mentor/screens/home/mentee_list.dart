import 'package:flutter/material.dart';
import 'package:voyager/src/features/mentor/controller/mentee_list_controller.dart';
import 'package:voyager/src/features/mentor/widget/status_toggle_button.dart';

class MenteeList extends StatelessWidget {
  MenteeList({super.key});

  final MenteeListController menteeListController = MenteeListController();

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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 16.0), // Add padding for aesthetics
                decoration: BoxDecoration(
                  color: Colors.white, // White background
                  borderRadius: BorderRadius.circular(30.0), // Rounded corners
                  border:
                      Border.all(color: Colors.grey[300]!), // Light grey border
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: menteeListController.searchMenteeController,
                        decoration: InputDecoration(
                          hintText: 'Search',
                          border: InputBorder.none, // Remove default underline
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 15.0,
                              horizontal: 7), // Adjust vertical padding
                        ),
                        style: TextStyle(
                            fontSize: 16.0), // Adjust font size as needed
                      ),
                    ),
                    Icon(
                      Icons.search,
                      color: Colors.grey[600], // Grey search icon
                    ),
                  ],
                ),
              ),
            ),
            Padding(
                padding: EdgeInsets.only(
                    left: screenWidth * 0.05,
                    bottom: screenHeight * 0.02,
                    right: screenWidth * 0.05),
                child: StatusToggleButton(
                  controller: menteeListController,
                )),
          ],
        ),
      ),
    );
  }
}
