import 'package:firebase_auth/firebase_auth.dart';
import 'package:voyager/src/features/admin/models/course_mentor_model.dart';
import 'package:voyager/src/features/mentor/model/content_model.dart';
import 'package:voyager/src/features/mentor/model/mentor_model.dart';
import 'package:voyager/src/features/mentor/screens/post/create_post.dart';
import 'package:voyager/src/features/mentor/widget/post_content.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:voyager/src/widgets/custom_page_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Post extends StatelessWidget {
  const Post({super.key});

  @override
  Widget build(BuildContext context)  {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
     List<PostContentModel> posts = [];
    Future<void> getPosts() async {
      FirestoreInstance firestoreInstance = FirestoreInstance();
      MentorModel mentor = await firestoreInstance.getMentorThroughAccId(FirebaseAuth.instance.currentUser!.uid);
      CourseMentorModel courseMentor = await firestoreInstance.getCourseMentorThroughMentor(mentor.mentorId);
      posts = await firestoreInstance.getPostContentThroughCourseMentor(courseMentor.courseId);
      //return firestoreInstance.g(mentor.mentorId);
    }
    

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
              Padding(
                padding: EdgeInsets.only(
                    top: screenHeight * 0.013,
                    left: screenHeight * 0.01), // Add padding to the left
                child: Text(
                  'Posts',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize:
                        screenHeight * 0.037, // Adjust font size as needed
                    fontWeight: FontWeight.bold, // Bold
                  ),
                ),
              ),
              SizedBox(width: 16),
              // Spacing between image and text
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(
                  right: 16.0), // Add padding to the right
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
                    Navigator.push(
                      context,
                      CustomPageRoute(page: CreatePost()),
                    );
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
                      top: screenHeight * 0.00),
                  child: Column(children: [
                    Divider(
                      color: Colors.black,
                      thickness: 1,
                    ),
                    SizedBox(
                      height: screenHeight * 0.02,
                    ),
                    PostContent(),
                  ]))),
        ));
  }
}
