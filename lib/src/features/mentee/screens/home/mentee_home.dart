// ignore_for_file: library_private_types_in_public_api

import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentee/model/course_model.dart';
import 'package:voyager/src/features/mentee/screens/home/course_offered.dart';
import 'package:voyager/src/features/mentee/screens/home/mentors_list.dart';
import 'package:voyager/src/features/mentee/screens/home/notification.dart';
import 'package:voyager/src/features/mentee/widgets/course_card.dart';
import 'package:voyager/src/features/mentee/widgets/mentor_card.dart';
import 'package:voyager/src/features/mentor/model/mentor_model.dart';
import 'package:voyager/src/repository/authentication_repository_firebase/authentication_repository.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:voyager/src/widgets/horizontal_slider.dart';
import 'package:voyager/src/widgets/horizontal_slider_mentor.dart';
import 'package:voyager/src/widgets/search_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MenteeHome extends StatefulWidget {
  const MenteeHome({super.key});

  @override
  _MenteeHomeState createState() => _MenteeHomeState();
}

class _MenteeHomeState extends State<MenteeHome> {
  User? user = FirebaseAuth.instance.currentUser;
  FirestoreInstance firestoreInstance = FirestoreInstance();

  // Fetch mentors with details
  Future<List<MentorCard>> fetchMentorsWithDetails() async {
    try {
      List<UserModel> users = await firestoreInstance.getMentors();

      List<MentorModel> mentorDetails = await Future.wait(users.map((user) =>
          firestoreInstance.getMentorThroughAccId(user.accountApiID)));

      return List.generate(users.length, (index) {
        return MentorCard(
          mentorModel: mentorDetails[index],
          user: users[index],
        );
      });
    } catch (e) {
      return [];
    }
  }

  // Fetch courses with details (similar to fetching mentors)
  Future<List<CourseCard>> fetchCoursesWithDetails() async {
    try {
      List<CourseModel> courses = await firestoreInstance.getCourses();

      return List.generate(courses.length, (index) {
        return CourseCard(
          courseModel: courses[index],
        );
      });
    } catch (e) {
      return [];
    }
  }

  String getName(String? name) {
    if (name == null || name.isEmpty) return "User";
    List<String> names = name.split(' ');
    return names.length > 1
        ? names.sublist(0, names.length - 1).join(' ')
        : name;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    String profileImageURL =
        user?.photoURL ?? 'assets/images/application_images/profile.png';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(profileImageURL)
                  : AssetImage(profileImageURL) as ImageProvider,
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${getName(user?.displayName)}!',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Courses await you!',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
                backgroundColor: Colors.grey[200],
                child: IconButton(
                  icon: Icon(Icons.notifications_none, color: Colors.black),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NotificationScreen()),
                    );
                  },
                )),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Discover',
                      style: TextStyle(
                        fontSize: screenHeight * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      'Courses',
                      style: TextStyle(
                        fontSize: screenHeight * 0.04,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1877F2),
                      ),
                    ),
                  ],
                ),
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
                              builder: (context) => CourseOffered()),
                        );
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.blue),
                      child: const Text('View All'),
                    ),
                  ],
                ),
                // Updated HorizontalWidgetSlider for Courses
                FutureBuilder<List<CourseCard>>(
                  future: fetchCoursesWithDetails(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError ||
                        !snapshot.hasData ||
                        snapshot.data!.isEmpty) {
                      return Center(child: Text("No courses available"));
                    }
                    return HorizontalWidgetSlider(
                      widgets: snapshot.data!,
                    );
                  },
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
                              builder: (context) => MentorsList()),
                        );
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.blue),
                      child: const Text('View All'),
                    ),
                  ],
                ),
                // HorizontalWidgetSliderMentor for Mentors
                FutureBuilder<List<MentorCard>>(
                  future: fetchMentorsWithDetails(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError ||
                        !snapshot.hasData ||
                        snapshot.data!.isEmpty) {
                      return Center(child: Text("No mentors available"));
                    }
                    return HorizontalWidgetSliderMentor(
                      widgets: snapshot.data!,
                    );
                  },
                ),
                SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
