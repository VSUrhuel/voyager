import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentor/screens/home/mentee_list.dart';
import 'package:voyager/src/features/mentor/screens/home/request_list.dart';
import 'package:voyager/src/repository/authentication_repository_firebase/authentication_repository.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:voyager/src/widgets/user_card.dart';
import 'package:voyager/src/widgets/vertical_widget_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MentorHome extends StatefulWidget {
  const MentorHome({super.key});

  @override
  _MentorHomeState createState() => _MentorHomeState();
}

class _MentorHomeState extends State<MentorHome> {
  @override
  void initState() {
    super.initState();
  }

  FirestoreInstance firestore = FirestoreInstance();

  Future<List<UserModel>> getApprovedMentees() async {
    List<UserModel> users = await firestore.getMentees("approved");
    return users;
  }

  Future<List<UserModel>> getPendingMentees() async {
    List<UserModel> users = await firestore.getMentees("pending");
    return users;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final auth = FirebaseAuthenticationRepository();
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        toolbarHeight: screenHeight * 0.10,

        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: screenWidth * 0.06,
          fontWeight: FontWeight.bold,
        ),
        elevation: 0, // No shadow
        title: Row(
          children: [
            CircleAvatar(
              radius: screenHeight * 0.035, // Adjust radius as needed
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
            padding:
                const EdgeInsets.only(right: 16.0), // Add padding to the right
            child: CircleAvatar(
              // Adjust size as needed
              radius: screenHeight * 0.03,
              backgroundColor: Colors.grey[200], // Light grey background
              child: IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.pen,
                  color: Colors.black,
                ),
                onPressed: () {
                  // Handle notification tap
                },
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(
                left: screenWidth * 0.06,
                right: screenWidth * 0.05,
                top: screenHeight * 0.01),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pending Requests',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RequestList(),
                            ),
                          );
                        },
                        child: Text(
                          'View All',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: screenWidth * 0.033,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                  FutureBuilder<List<UserModel>>(
                    future: getPendingMentees(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text('No pending requests');
                      } else {
                        return VerticalWidgetSlider(
                          widgets: snapshot.data!
                              .map((mentee) => UserCard(user: mentee))
                              .toList(),
                        );
                      }
                    },
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Mentee List',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MenteeList(),
                            ),
                          );
                        },
                        child: Text(
                          'View All',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: screenWidth * 0.033,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                  FutureBuilder<List<UserModel>>(
                    future: getApprovedMentees(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text('No approved mentees');
                      } else {
                        return VerticalWidgetSlider(
                          widgets: snapshot.data!
                              .map((mentee) => UserCard(user: mentee))
                              .toList(),
                        );
                      }
                    },
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await auth.logout();
                    },
                    child: const Text('Go to Login'),
                  )
                ]),
          ),
        ),
      ),
    );
  }
}
