import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:voyager/src/features/admin/screens/courses/course_list.dart';
import 'package:voyager/src/features/admin/screens/mentors/mentor_list.dart';
import 'package:voyager/src/features/admin/screens/profile/admin_profile.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/repository/authentication_repository_firebase/authentication_repository.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:voyager/src/widgets/custom_page_route.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  // Future<UserModel?> getUserModel(String email) async {
  //   try {
  //     return await FirestoreInstance().getUserThroughEmail(email);
  //   } catch (e) {
  //     return null;
  //   }
  // }

  late String profileUserName = '';
  late String profilePicUrl = '';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    FirestoreInstance firestore = Get.put(FirestoreInstance());

    UserModel user =
        await firestore.getUser(FirebaseAuth.instance.currentUser!.uid);
    setState(() {
      profilePicUrl = user.accountApiPhoto;
      profileUserName = user.accountUsername;
      if (profilePicUrl == '') {
        profilePicUrl =
            'https://zyqxnzxudwofrlvdzbvf.supabase.co/storage/v1/object/public/profile-picture//profile.png';
      }
      if (profileUserName == '') {
        profileUserName = 'User';
      }
    });
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
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        toolbarHeight: screenHeight * 0.10,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: screenWidth * 0.06,
          fontWeight: FontWeight.bold,
        ),
        elevation: 0,
        title: Row(
          children: [
            _buildProfileImage(screenWidth),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $profileUserName',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Management awaits you!',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.all(10.0),
        //     child: IconButton(
        //       icon: CircleAvatar(
        //         backgroundColor: const Color.fromARGB(31, 182, 206, 239),
        //         child: Icon(Icons.logout_sharp),
        //       ),
        //       onPressed: () async {
        //         await auth.logout();
        //       },
        //     ),
        //   )
        // ],
      ),
      body: Padding(
        padding: EdgeInsets.only(
                left: screenWidth * 0.06,
                right: screenWidth * 0.05,
                top: screenHeight * 0.01,
              ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.02),
            Text(
              'Actions',
              style: TextStyle(
                fontSize: screenWidth * 0.05,
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

  Widget _buildProfileImage(double screenWidth) {
    return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            CustomPageRoute(
              page: AdminProfile(),
              direction: AxisDirection.left,
            ),
          );
        },
        child: CachedNetworkImage(
          imageUrl: profilePicUrl,
          imageBuilder: (context, imageProvider) => CircleAvatar(
            radius: 30,
            backgroundImage: imageProvider,
          ),
          placeholder: (context, url) =>
              _buildPlaceholderAvatar(isLoading: true),
          errorWidget: (context, url, error) => _buildPlaceholderAvatar(),
        ));
  }

  Widget _buildPlaceholderAvatar({bool isLoading = false}) {
    return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            CustomPageRoute(
              page: AdminProfile(),
              direction: AxisDirection.right,
            ),
          );
        },
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[300],
          ),
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.grey[600],
                  ),
                )
              : Image.asset(
                  'assets/images/application_images/profile.png', // Placeholder image path
                  fit: BoxFit.cover,
                ),
        ));
  }
}
