import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentee/controller/mentee_controller.dart';
import 'package:voyager/src/features/mentee/model/course_model.dart';
import 'package:voyager/src/features/mentee/screens/home/course_offered.dart';
import 'package:voyager/src/features/mentee/screens/home/mentors_list.dart';
import 'package:voyager/src/features/mentee/screens/home/notification.dart';
import 'package:voyager/src/features/mentee/screens/profile/mentee_profile.dart';
import 'package:voyager/src/features/mentee/widgets/course_card.dart';
import 'package:voyager/src/features/mentee/widgets/mentor_card.dart';
import 'package:voyager/src/features/mentor/model/mentor_model.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:voyager/src/widgets/horizontal_slider.dart';
import 'package:voyager/src/widgets/horizontal_slider_mentor.dart';
import 'package:voyager/src/widgets/search_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MenteeHome extends StatefulWidget {
  const MenteeHome({super.key});

  @override
  _MenteeHomeState createState() => _MenteeHomeState();
}

class _MenteeHomeState extends State<MenteeHome> {
  User? user = FirebaseAuth.instance.currentUser;
  FirestoreInstance firestoreInstance = FirestoreInstance();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  MenteeController menteeController = Get.put(MenteeController());
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChange);
  }

  void _onSearchChange() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
      _isSearching = _searchQuery.isNotEmpty;
    });
  }

  // Fetch mentors with details
  Future<List<MentorCard>> fetchMentorsWithDetails() async {
    try {
      List<UserModel> users = await firestoreInstance.getMentors();

      List<MentorModel> mentorDetails = await Future.wait(users.map((user) =>
          firestoreInstance.getMentorThroughAccId(user.accountApiID)));

      List<MentorCard> mentors = List.generate(users.length, (index) {
        return MentorCard(
          mentorModel: mentorDetails[index],
          user: users[index],
        );
      });

      if (_isSearching && menteeController.searchCategory.text == 'Mentors') {
        mentors = mentors.where((mentor) {
          return mentor.user.accountApiName
                  .toLowerCase()
                  .contains(_searchQuery) ||
              mentor.user.accountApiEmail.toLowerCase().contains(_searchQuery);
        }).toList();
      }

      return mentors;
    } catch (e) {
      return [];
    }
  }

  Future<String?> getUserIdThroughEmail(String email) async {
    try {
      final userSnapshot = await _db
          .collection('users')
          .where('accountApiEmail', isEqualTo: email)
          .get();

      if (userSnapshot.docs.isEmpty) {
        print("⚠️ No user found with email: $email");
        return null;
      }

      final userId = userSnapshot.docs.first.id;

      final menteeSnapshot = await _db
          .collection('mentee')
          .where('accountId', isEqualTo: userId)
          .get();

      if (menteeSnapshot.docs.isEmpty) {
        print("⚠️ No mentee found with accountId: $userId");
        return null;
      }

      return menteeSnapshot.docs.first.id;
    } catch (e) {
      print("❌ Error in getUserIdThroughEmail: $e");
      return null;
    }
  }

  Future<List<String>> getCourseMentorIdsForMentee(String menteeId) async {
    try {
      final allocations = await _db
          .collection('menteeCourseAlloc')
          .where('menteeId', isEqualTo: menteeId)
          .where('mcaSoftDeleted', isEqualTo: false)
          .get();

      return allocations.docs
          .map((doc) => doc.data()['courseMentorId'] as String)
          .toList();
    } catch (e) {
      print("❌ Error getting course mentor IDs: $e");
      return [];
    }
  }

  // Fetch courses with details (similar to fetching mentors)
  Future<List<CourseCard>> fetchCoursesWithDetails(String userEmail) async {
    try {
      final menteeId = await getUserIdThroughEmail(userEmail);
      final List<CourseModel> allCourses = await firestoreInstance.getCourses();

      List<CourseModel> availableCourses;

      if (menteeId == null || menteeId.isEmpty) {
        print("❌ I am still not a mentee");
        // If no menteeId, return all active and non-soft-deleted courses
        availableCourses = allCourses.where((course) {
          return course.courseSoftDelete == false &&
              course.courseStatus == 'active';
        }).toList();
      } else {
        // Otherwise filter based on enrolled course mentor IDs
        print("❌ I am now a mentee");
        final enrolledCourseMentorIds =
            await getCourseMentorIdsForMentee(menteeId);

        //Problem
        print("❌ Enrolled in: $enrolledCourseMentorIds");
        List<CourseModel> enrolledCourses = [];
        for (String mentorId in enrolledCourseMentorIds) {
          final course =
              await firestoreInstance.getMentorCourseThroughId(mentorId);
          if (course != null) {
            enrolledCourses.add(course);
          }
        }

        final List<String> enrolledCourseNames =
            enrolledCourses.map((course) => course.courseName).toList();
        availableCourses = allCourses.where((course) {
          return !enrolledCourseNames.contains(course.courseName) &&
              course.courseSoftDelete == false &&
              course.courseStatus == 'active';
        }).toList();
      }

      if (_isSearching && menteeController.searchCategory.text == 'Courses') {
        availableCourses = availableCourses.where((course) {
          return course.courseName.toLowerCase().contains(_searchQuery);
        }).toList();
      }

      return List.generate(availableCourses.length, (index) {
        return CourseCard(courseModel: availableCourses[index]);
      });
    } catch (e) {
      print("❌ Error fetching courses with details: $e");
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
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MenteeProfile()),
                );
              },
              child: CircleAvatar(
                radius: 25,
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(profileImageURL)
                    : AssetImage(profileImageURL) as ImageProvider,
              ),
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
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            fetchCoursesWithDetails(user?.email ?? '');
            fetchMentorsWithDetails();
          });
        },
        child: SingleChildScrollView(
          physics:
              AlwaysScrollableScrollPhysics(), // Ensures pull-to-refresh works even if content is short
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
                  SearchBarWithDropdown(
                      onChanged: _onSearchChange,
                      controller: menteeController,
                      searchController: _searchController),
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
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.blue),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  // Updated HorizontalWidgetSlider for Courses
                  FutureBuilder<List<CourseCard>>(
                    future: fetchCoursesWithDetails(user?.email ?? ''),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Lottie.asset(
                            'assets/images/loading.json',
                            fit: BoxFit.cover,
                            width: screenHeight * 0.08,
                            height: screenWidth * 0.04,
                            repeat: true,
                          ),
                        );
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
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.blue),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  // HorizontalWidgetSliderMentor for Mentors
                  FutureBuilder<List<MentorCard>>(
                    future: fetchMentorsWithDetails(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Lottie.asset(
                            'assets/images/loading.json',
                            fit: BoxFit.cover,
                            width: screenHeight * 0.08,
                            height: screenWidth * 0.04,
                            repeat: true,
                          ),
                        );
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
                  SizedBox(height: screenHeight * 0.02),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
