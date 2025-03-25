import 'package:voyager/src/features/mentee/widgets/normal_searchBar.dart';
import 'package:voyager/src/features/mentee/widgets/pick_mentor_card.dart';
import 'package:voyager/src/features/mentee/widgets/small_course_card.dart';
import 'package:voyager/src/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';

class EnrollCourse extends StatelessWidget {
  const EnrollCourse({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Enroll Course',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 18.0,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              height: screenHeight * 0.25,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'assets/images/application_images/profile.png'),
                  fit: BoxFit.fitWidth,
                ),
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Colors.black,
              ),
            ),

            SizedBox(height: screenHeight * 0.02),

            // Course Info Section
            Container(
              padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.015,
                  horizontal: screenWidth * 0.05),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoItem(Icons.access_time, '1 Semester', screenHeight),
                  _infoItem(Icons.groups, '3 Mentors', screenHeight),
                  _infoItem(Icons.people, '5 Mentees', screenHeight),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.03),

            // Description
            Text(
              "Description",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: screenHeight * 0.022,
              ),
            ),
            SizedBox(height: screenHeight * 0.005),
            Text(
              "Lorem ipsum dolor sit amet consectetur. Lobortis in mi faucibus molestie eget quis viverra purus. Commodo sed volutpat mauris non lacus ultrices vitae. Odio elit congue quam commodo rhoncus sed. Malesuada purus rhoncus aliquet turpis eu facilisi.",
              style: TextStyle(fontSize: screenHeight * 0.018),
            ),

            SizedBox(height: screenHeight * 0.03),

            // What You'll Learn
            Text(
              "What You'll Learn:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: screenHeight * 0.022,
              ),
            ),
            SizedBox(height: screenHeight * 0.005),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _bulletPoint(
                    "Lorem ipsum dolor sit amet consectetur.", screenHeight),
                _bulletPoint(
                    "Ridiculus odio blandit varius bibendum.", screenHeight),
                _bulletPoint(
                    "Amet id faucibus justo massa nulla consectetur et risus nunc.",
                    screenHeight),
                _bulletPoint("Neque nunc ut ultrices eu in viverra non quam.",
                    screenHeight),
                _bulletPoint(
                    "Lectus faucibus at scelerisque massa eget gravida vulputate cursus dictumst.",
                    screenHeight),
              ],
            ),

            SizedBox(height: screenHeight * 0.03),

            // Pick Your Mentor
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Pick your Mentor",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenHeight * 0.022,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to mentor selection
                  },
                  child: Text(
                    "View Mentors",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: screenHeight * 0.020,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: screenHeight * 0.02),

            // FIXED: Set a bounded height for the mentor cards list
            SizedBox(
              height: screenHeight * 0.4, // Fixed height for scrollable area
              child: ListView.builder(
                itemCount: 3, // Adjust based on your data
                itemBuilder: (context, index) => PickMentorCard(),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Colors.white, // Optional background color
        child: SizedBox(
          width: double.infinity, // Full width
          height: 50, // Adjust height as needed
          child: ElevatedButton(
            onPressed: () {
              // Add your action here
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // Button color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // Rounded edges
              ),
              padding: EdgeInsets.symmetric(vertical: 12), // Adjust padding
            ),
            child: Text(
              "Enroll this Course",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Text color
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoItem(IconData icon, String text, double screenHeight) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: screenHeight * 0.04),
        SizedBox(height: screenHeight * 0.005),
        Text(
          text,
          style: TextStyle(
            fontSize: screenHeight * 0.018,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _bulletPoint(String text, double screenHeight) {
    return Padding(
      padding: EdgeInsets.only(bottom: screenHeight * 0.005),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• ", style: TextStyle(fontSize: screenHeight * 0.018)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: screenHeight * 0.018),
            ),
          ),
        ],
      ),
    );
  }
}
