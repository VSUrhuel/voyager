import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentee/screens/course_offered.dart';
import 'package:voyager/src/features/mentee/screens/mentors_list.dart';
import 'package:voyager/src/features/mentee/widgets/course_card.dart';
import 'package:voyager/src/features/mentee/widgets/mentor_card.dart';
import 'package:voyager/src/repository/authentication_repository_firebase/authentication_repository.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:voyager/src/widgets/bottom_nav_bar.dart';
import 'package:voyager/src/widgets/custom_button.dart';
import 'package:voyager/src/widgets/horizontal_slider.dart';
import 'package:voyager/src/widgets/horizontal_slider_mentor.dart';
import 'package:voyager/src/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MenteeHome extends StatelessWidget {
  const MenteeHome({super.key});

  Future<UserModel?> getUserModel(String email) async {
    try {
      return await FirestoreInstance().getUserThroughEmail(email);
    } catch (e) {
      return null;
    }
  }

  String getName(String? name) {
    List names = name!.split(' ');
    return names.sublist(0, names.length - 1).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final auth = Get.put(FirebaseAuthenticationRepository());

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white, // White background
          elevation: 0, // No shadow
          title: Row(
            children: [
              CircleAvatar(
                radius: 25, // Adjust radius as needed
                child: Image.asset(
                    'assets/images/application_images/profile.png'), // Replace with your image URL
              ),
              SizedBox(width: 16), // Spacing between image and text
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, Rhuel',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18, // Adjust font size as needed
                      fontWeight: FontWeight.w500, // Semi-bold
                    ),
                  ),
                  Text(
                    'Courses awaits you!',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16, // Adjust font size as needed
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(
                  right: 16.0), // Add padding to the right
              child: CircleAvatar(
                backgroundColor: Colors.grey[200], // Light grey background
                child: IconButton(
                  icon: Icon(Icons.notifications_none, color: Colors.black),
                  onPressed: () {
                    // Handle notification tap
                  },
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.only(
                  left: screenWidth * 0.05, right: screenWidth * 0.05),
              child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(
                          'Discover',
                          style: TextStyle(
                            fontSize: screenHeight * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          width: screenWidth * 0.02,
                        ),
                        Text(
                          'Courses',
                          style: TextStyle(
                            fontSize: screenHeight * 0.04,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1877F2),
                          ),
                        ),
                      ]),
                      SizedBox(height: screenHeight * 0.01),
                      SearchBarWithDropdown(),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Featured Courses',
                            style: TextStyle(
                              fontSize: screenHeight * 0.02,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CourseOffered()));
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                            child: const Text('View All'),
                          )
                        ],
                      ),
                      HorizontalWidgetSlider(
                        widgets: [
                          // Declare the widgets inline
                          CourseCard(),
                          CourseCard(),
                          CourseCard(),
                          // Add more widgets as needed
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Featured Mentors',
                            style: TextStyle(
                              fontSize: screenHeight * 0.02,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MentorsList()));
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors
                                  .transparent, // Make background transparent
                              foregroundColor:
                                  Colors.blue, // Text color (example: blue)
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8), // Adjust padding as needed
                              textStyle: const TextStyle(
                                  fontSize: 16), // Adjust text style as needed
                            ),
                            child: const Text('View All'),
                          )
                        ],
                      ),
                      HorizontalWidgetSliderMentor(
                        widgets: [
                          MentorCard(),
                          MentorCard(),
                          MentorCard(),
                        ],
                      ),
                      SizedBox(height: 100),
                      DefaultButton(
                        buttonText: 'Logout',
                        bgColor: Colors.red,
                        textColor: Colors.white,
                        isLoading: false,
                        borderColor: Colors.transparent,
                        onPressed: () async {
                          await auth.logout();
                        },
                      ),
                    ]),
              )),
        ),
        bottomNavigationBar: BottomNavBar());
  }
}
