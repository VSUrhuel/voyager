import 'package:voyager/src/features/admin/screens/courses/course_list.dart';
import 'package:voyager/src/features/admin/screens/mentors/mentor_list.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/repository/authentication_repository_firebase/authentication_repository.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

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
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          toolbarHeight: screenHeight * 0.10,
          leading: Padding(
            padding: const EdgeInsets.only(left: 10.0, top: 5.0, bottom: 5.0),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue[100],
              child: Icon(Icons.person, size: screenWidth * 0.09),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, Admin',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: screenWidth * 0.027,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Text(
                'Mentors awaits you!',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: screenWidth * 0.03,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: IconButton(
                icon: CircleAvatar(
                  backgroundColor: const Color.fromARGB(31, 182, 206, 239),
                  child: Icon(Icons.logout_sharp),
                ),
                onPressed: () async {
                  await auth.logout();
                },
              ),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 30, right: 35),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Actions',
                style: TextStyle(
                  fontSize: screenHeight * 0.025,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              SizedBox(
                width: screenWidth * 1,
                height: screenHeight * 0.06,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => MentorList()));
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Color.fromARGB(255, 226, 225, 225),
                    side: BorderSide(color: Color(0xFF666666)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13.0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'View Mentors',
                        style: TextStyle(
                          fontSize: screenHeight * 0.018,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      Spacer(),
                      Icon(Icons.arrow_forward_ios,
                          size: screenHeight * 0.02, color: Colors.black),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              SizedBox(
                width: screenWidth * 1,
                height: screenHeight * 0.06,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => CourseList()));
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Color.fromARGB(255, 226, 225, 225),
                    side: BorderSide(color: Color(0xFF666666)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13.0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'View Courses',
                        style: TextStyle(
                          fontSize: screenHeight * 0.018,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      Spacer(),
                      Icon(Icons.arrow_forward_ios,
                          size: screenHeight * 0.02, color: Colors.black),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
