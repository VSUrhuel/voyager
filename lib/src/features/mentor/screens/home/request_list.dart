import 'package:voyager/src/features/mentee/widgets/normal_search_bar.dart';
import 'package:flutter/material.dart';

class RequestList extends StatelessWidget {
  const RequestList({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

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
          'Pending Requests',
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
                child: Center(
                  child: Column(children: [
                    SizedBox(height: screenHeight * 0.02),
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
