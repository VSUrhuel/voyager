import 'package:voyager/src/features/mentee/widgets/normal_searchBar.dart';
import 'package:voyager/src/features/mentee/widgets/small_course_card.dart';
import 'package:voyager/src/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';

class CourseOffered extends StatelessWidget {
  const CourseOffered({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white, // Assuming a white background
          elevation: 1.0, // Optional: Add a subtle shadow
          leading: IconButton(
            icon:
                Icon(Icons.arrow_back, color: Colors.black), // Black arrow back
            onPressed: () {
              Navigator.pop(context); // Go back when pressed
            },
          ),
          title: Text(
            'Courses Offered',
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
                    child: Column(
                      children: List.generate(
                        5, // Number of CourseCards to create
                        (index) => SmallCourseCard(), // The widget to repeat
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavBar());
  }
}
