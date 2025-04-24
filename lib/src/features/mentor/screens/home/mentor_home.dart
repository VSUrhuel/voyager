// ignore_for_file: library_private_types_in_public_api

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:voyager/src/features/mentor/screens/profile/mentor_profile.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentor/controller/mentee_list_controller.dart';
import 'package:voyager/src/features/mentor/screens/home/accepted.dart';
import 'package:voyager/src/features/mentor/screens/home/mentee_list.dart';
import 'package:voyager/src/features/mentor/screens/home/pending.dart';
import 'package:voyager/src/features/mentor/screens/home/request_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:voyager/src/features/mentor/screens/post/create_post.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:voyager/src/widgets/custom_page_route.dart';

class MentorHome extends StatefulWidget {
  const MentorHome({super.key});

  @override
  _MentorHomeState createState() => _MentorHomeState();
}

class _MentorHomeState extends State<MentorHome> {
  MenteeListController menteeListController = MenteeListController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final isChanged = false;

  // Keys to access the list states
  final GlobalKey _pendingListKey = GlobalKey();
  final GlobalKey _acceptedListKey = GlobalKey();

  Future<void> _handleRefresh() async {
    final refreshOp = <Future>[];
    if (_pendingListKey.currentState != null) {
      //   menteeListController.searchMenteeController.addListener(
      //      await (_pendingListKey.currentState as dynamic).loadNewData());

      (_pendingListKey.currentState as dynamic).refreshPendingMentees();
    }
    if (_acceptedListKey.currentState != null) {
      (_acceptedListKey.currentState as dynamic).refreshAcceptedMentees();
    }
    await Future.wait(refreshOp);
    await Future.delayed(const Duration(milliseconds: 500));
  }

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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
        bottom: true,
        top: false,
        child: Scaffold(
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
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                    ),
                    child: Icon(Icons.edit,
                        color: Theme.of(context).primaryColor,
                        size: screenWidth * 0.065),
                  ),
                  onPressed: () {
                    // Handle the button press here
                    Navigator.push(
                      context,
                      CustomPageRoute(
                        page: CreatePost(),
                        direction: AxisDirection.left,
                      ),
                    ).then((_) => _refreshIndicatorKey.currentState?.show());
                  },
                ),
              ),
            ],
          ),
          body: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: _handleRefresh,
            child: SingleChildScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(), // Needed for RefreshIndicator
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: screenWidth * 0.06,
                    right: screenWidth * 0.05,
                    top: screenHeight * 0.01,
                  ),
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
                                CustomPageRoute(
                                  page: const RequestList(),
                                  direction: AxisDirection.left,
                                ),
                              ).then((_) =>
                                  _refreshIndicatorKey.currentState?.show());
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
                      SizedBox(
                        height: screenHeight * 0.26,
                        child: PendingList(
                          menteeListController: menteeListController,
                          key: _pendingListKey,
                          isMentorHome: true,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
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
                                CustomPageRoute(
                                  page: MenteeList(),
                                  direction: AxisDirection.left,
                                ),
                              ).then((_) =>
                                  _refreshIndicatorKey.currentState?.show());
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
                      SizedBox(
                        height: screenHeight * 0.35,
                        child: AcceptedList(
                          menteeListController: menteeListController,
                          key: _acceptedListKey,
                          isMentorHome: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }

  Widget _buildProfileImage(double screenWidth) {
    return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            CustomPageRoute(
              page: MentorProfile(),
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
              page: MentorProfile(),
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
