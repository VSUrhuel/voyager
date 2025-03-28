import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentee/screens/home/notification.dart';
import 'package:voyager/src/features/mentee/widgets/post_card.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Post extends StatelessWidget {
  const Post({super.key});

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
    User? user = FirebaseAuth.instance.currentUser;
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
                  'Courses awaits you!',
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
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NotificationScreen()));
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.blue,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: Center(
                    child: Icon(Icons.notifications_none, color: Colors.black),
                  ),
                )),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.only(
                left: screenWidth * 0.05, right: screenWidth * 0.05),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.04),
                Row(
                  children: [
                    Text(
                      'Posts',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize:
                            screenHeight * 0.037, // Adjust font size as needed
                        fontWeight: FontWeight.bold, // Bold
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.03),
                Column(
                  children: [PostCard()],
                )
              ],
            )),
      ),
    );
  }
}
