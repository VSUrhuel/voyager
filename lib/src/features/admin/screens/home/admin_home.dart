import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:voyager/src/features/admin/screens/admin_dashboard.dart';
import 'package:voyager/src/features/admin/screens/courses/course_list.dart';
import 'package:voyager/src/features/admin/screens/mentors/mentor_list.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/repository/authentication_repository_firebase/authentication_repository.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:voyager/src/widgets/custom_page_route.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  late String profileUserName = '';
  late String profilePicUrl = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    FirestoreInstance firestore = Get.put(FirestoreInstance());

    try {
      UserModel user =
          await firestore.getUser(FirebaseAuth.instance.currentUser!.uid);
      setState(() {
        profilePicUrl = user.accountApiPhoto;
        profileUserName = user.accountUsername;
        if (profilePicUrl.isEmpty) {
          profilePicUrl =
              'https://zyqxnzxudwofrlvdzbvf.supabase.co/storage/v1/object/public/profile-picture//profile.png';
        }
        if (profileUserName.isEmpty) {
          profileUserName = 'Admin';
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final auth = Get.put(FirebaseAuthenticationRepository());

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        foregroundColor: Colors.white,
        forceMaterialTransparency: true,
        iconTheme: const IconThemeData(
            color: Colors.white), // For back button if you have one
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.white, // Makes status bar transparent
          statusBarIconBrightness:
              Brightness.dark, // Dark icons for light status bar
          statusBarBrightness: Brightness.light, // Light status bar
          systemNavigationBarIconBrightness:
              Brightness.dark, // Navigation bar icons
        ),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        toolbarHeight: 80,
        title: _isLoading
            ? Row(
                children: [
                  _buildPlaceholderAvatar(isLoading: true),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 20,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 160,
                        height: 16,
                        color: Colors.grey[200],
                      ),
                    ],
                  ),
                ],
              )
            : Row(
                children: [
                  _buildProfileImage(),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, Admin',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Management awaits you!',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color
                              ?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
        actions: [
          Padding(
            padding: EdgeInsets.only(
              right: screenSize.width * 0.04,
            ),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.primaryColor.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.logout,
                  color: theme.primaryColor,
                  size: screenSize.width * 0.06,
                ),
              ),
              onPressed: () async {
                await auth.logout();
              },
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Quick Actions',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              context,
              icon: Icons.group,
              title: 'Mentor Management',
              subtitle: 'View and manage all mentors',
              onTap: () => Navigator.push(
                context,
                CustomPageRoute(
                    page: MentorList(), direction: AxisDirection.left),
              ),
              color: Colors.blue[50],
              iconColor: Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              context,
              icon: Icons.book,
              title: 'Course Management',
              subtitle: 'View and manage all courses',
              onTap: () => Navigator.push(
                context,
                CustomPageRoute(
                    page: CourseList(), direction: AxisDirection.left),
              ),
              color: Colors.green[50],
              iconColor: Colors.green,
            ),
            const SizedBox(height: 24),
            // Text(
            //   'Admin Tools',
            //   style: theme.textTheme.titleLarge?.copyWith(
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
            // const SizedBox(height: 16),
            // ProfileListTile(
            //   iconData: Icons.person,
            //   text: 'Admin Profile',
            //   onTap: () => Navigator.of(context).push(
            //     CustomPageRoute(
            //       page: const AdminProfile(),
            //       direction: AxisDirection.left,
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 8),
            // ProfileListTile(
            //   iconData: Icons.settings,
            //   text: 'Settings',
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => const AdminSettings(),
            //       ),
            //     );
            //   },
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
    Color? iconColor,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color ?? theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor?.withOpacity(0.2) ??
                    theme.primaryColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor ?? theme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: screenWidth * 0.047,
                      fontWeight: FontWeight.w500,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: screenWidth * 0.033,
                      color:
                          theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return GestureDetector(
      onTap: () {
        AdminDashboard(
          index: 1,
        );
      },
      child: CachedNetworkImage(
        imageUrl: profilePicUrl,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: 24,
          backgroundImage: imageProvider,
        ),
        placeholder: (context, url) => _buildPlaceholderAvatar(isLoading: true),
        errorWidget: (context, url, error) => _buildPlaceholderAvatar(),
      ),
    );
  }

  Widget _buildPlaceholderAvatar({bool isLoading = false}) {
    return Container(
      width: 48,
      height: 48,
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
          : Icon(
              Icons.person,
              size: 24,
              color: Colors.grey[600],
            ),
    );
  }
}
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:voyager/src/features/admin/screens/courses/course_list.dart';
// import 'package:voyager/src/features/admin/screens/mentors/mentor_list.dart';
// import 'package:voyager/src/features/admin/screens/profile/admin_profile.dart';
// import 'package:voyager/src/features/authentication/models/user_model.dart';
// import 'package:voyager/src/repository/authentication_repository_firebase/authentication_repository.dart';
// import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:flutter/services.dart';
// import 'package:voyager/src/widgets/custom_page_route.dart';
// import 'package:voyager/src/widgets/profile_list_tile.dart';

// class AdminHome extends StatefulWidget {
//   const AdminHome({super.key});

//   @override
//   _AdminHomeState createState() => _AdminHomeState();
// }

// class _AdminHomeState extends State<AdminHome> {
//   // Future<UserModel?> getUserModel(String email) async {
//   //   try {
//   //     return await FirestoreInstance().getUserThroughEmail(email);
//   //   } catch (e) {
//   //     return null;
//   //   }
//   // }

//   late String profileUserName = '';
//   late String profilePicUrl = '';

//   @override
//   void initState() {
//     super.initState();
//     fetchData();
//   }

//   void fetchData() async {
//     FirestoreInstance firestore = Get.put(FirestoreInstance());

//     UserModel user =
//         await firestore.getUser(FirebaseAuth.instance.currentUser!.uid);
//     setState(() {
//       profilePicUrl = user.accountApiPhoto;
//       profileUserName = user.accountUsername;
//       if (profilePicUrl == '') {
//         profilePicUrl =
//             'https://zyqxnzxudwofrlvdzbvf.supabase.co/storage/v1/object/public/profile-picture//profile.png';
//       }
//       if (profileUserName == '') {
//         profileUserName = 'User';
//       }
//     });
//   }

//   String getName(String? name) {
//     List names = name!.split(' ');
//     return names.sublist(0, names.length - 1).join(' ');
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     final auth = Get.put(FirebaseAuthenticationRepository());

//     return Scaffold(
//       appBar: AppBar(
//         systemOverlayStyle: SystemUiOverlayStyle.dark,
//         scrolledUnderElevation: 0,
//         backgroundColor: Colors.white,
//         automaticallyImplyLeading: false,
//         toolbarHeight: screenHeight * 0.10,
//         titleTextStyle: TextStyle(
//           color: Colors.black,
//           fontSize: screenWidth * 0.06,
//           fontWeight: FontWeight.bold,
//         ),
//         elevation: 0,
//         title: Row(
//           children: [
//             _buildProfileImage(screenWidth),
//             const SizedBox(width: 16),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Hello, $profileUserName',
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontSize: 18,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 Text(
//                   'Management awaits you!',
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontSize: 16,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         // actions: [
//         //   Padding(
//         //     padding: const EdgeInsets.all(10.0),
//         //     child: IconButton(
//         //       icon: CircleAvatar(
//         //         backgroundColor: const Color.fromARGB(31, 182, 206, 239),
//         //         child: Icon(Icons.logout_sharp),
//         //       ),
//         //       onPressed: () async {
//         //         await auth.logout();
//         //       },
//         //     ),
//         //   )
//         // ],
//       ),
//       body: Padding(
//         padding: EdgeInsets.only(
//           // left: screenWidth * 0.06,
//           // right: screenWidth * 0.05,
//           top: screenHeight * 0.01,
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: screenHeight * 0.02),
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
//               child: Text(
//                 'Actions',
//                 style: TextStyle(
//                   fontSize: screenWidth * 0.05,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             ProfileListTile(
//                 iconData: Icons.group,
//                 text: 'View Mentors',
//                 onTap: () {
//                   Navigator.push(context,
//                       MaterialPageRoute(builder: (context) => MentorList()));
//                 }),
//             SizedBox(height: screenHeight * 0.01),
//             ProfileListTile(
//                 iconData: Icons.book,
//                 text: 'View Courses',
//                 onTap: () {
//                   Navigator.push(context,
//                       MaterialPageRoute(builder: (context) => CourseList()));
//                 }),
//             SizedBox(height: screenHeight * 0.01),
//             // SizedBox(
//             //   width: screenWidth * 1,
//             //   height: screenHeight * 0.06,
//             //   child: OutlinedButton(
//             //     onPressed: () {
//             //       Navigator.push(context,
//             //           MaterialPageRoute(builder: (context) => MentorList()));
//             //     },
//             //     style: OutlinedButton.styleFrom(
//             //       foregroundColor: Colors.black,
//             //       backgroundColor: Color.fromARGB(255, 226, 225, 225),
//             //       side: BorderSide(color: Color(0xFF666666)),
//             //       shape: RoundedRectangleBorder(
//             //         borderRadius: BorderRadius.circular(13.0),
//             //       ),
//             //     ),
//             //     child: Row(
//             //       mainAxisAlignment: MainAxisAlignment.start,
//             //       children: [
//             //         Text(
//             //           'View Mentors',
//             //           style: TextStyle(
//             //             fontSize: screenHeight * 0.018,
//             //             fontWeight: FontWeight.normal,
//             //           ),
//             //         ),
//             //         Spacer(),
//             //         Icon(Icons.arrow_forward_ios,
//             //             size: screenHeight * 0.02, color: Colors.black),
//             //       ],
//             //     ),
//             //   ),
//             // ),
//             // SizedBox(height: screenHeight * 0.01),
//             // SizedBox(
//             //   width: screenWidth * 1,
//             //   height: screenHeight * 0.06,
//             //   child: OutlinedButton(
//             //     onPressed: () {
//             //       Navigator.push(context,
//             //           MaterialPageRoute(builder: (context) => CourseList()));
//             //     },
//             //     style: OutlinedButton.styleFrom(
//             //       foregroundColor: Colors.black,
//             //       backgroundColor: Color.fromARGB(255, 226, 225, 225),
//             //       side: BorderSide(color: Color(0xFF666666)),
//             //       shape: RoundedRectangleBorder(
//             //         borderRadius: BorderRadius.circular(13.0),
//             //       ),
//             //     ),
//             //     child: Row(
//             //       mainAxisAlignment: MainAxisAlignment.start,
//             //       children: [
//             //         Text(
//             //           'View Courses',
//             //           style: TextStyle(
//             //             fontSize: screenHeight * 0.018,
//             //             fontWeight: FontWeight.normal,
//             //           ),
//             //         ),
//             //         Spacer(),
//             //         Icon(Icons.arrow_forward_ios,
//             //             size: screenHeight * 0.02, color: Colors.black),
//             //       ],
//             //     ),
//             //   ),
//             // ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildProfileImage(double screenWidth) {
//     return GestureDetector(
//         onTap: () {
//           Navigator.of(context).push(
//             CustomPageRoute(
//               page: AdminProfile(),
//               direction: AxisDirection.left,
//             ),
//           );
//         },
//         child: CachedNetworkImage(
//           imageUrl: profilePicUrl,
//           imageBuilder: (context, imageProvider) => CircleAvatar(
//             radius: 30,
//             backgroundImage: imageProvider,
//           ),
//           placeholder: (context, url) =>
//               _buildPlaceholderAvatar(isLoading: true),
//           errorWidget: (context, url, error) => _buildPlaceholderAvatar(),
//         ));
//   }

//   Widget _buildPlaceholderAvatar({bool isLoading = false}) {
//     return GestureDetector(
//         onTap: () {
//           Navigator.of(context).push(
//             CustomPageRoute(
//               page: AdminProfile(),
//               direction: AxisDirection.right,
//             ),
//           );
//         },
//         child: Container(
//           width: 60,
//           height: 60,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             color: Colors.grey[300],
//           ),
//           child: isLoading
//               ? Center(
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2,
//                     color: Colors.grey[600],
//                   ),
//                 )
//               : Image.asset(
//                   'assets/images/application_images/profile.png', // Placeholder image path
//                   fit: BoxFit.cover,
//                 ),
//         ));
//   }
// }
