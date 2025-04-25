import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentee/controller/mentee_post_controller.dart';
import 'package:voyager/src/features/mentee/screens/home/notification.dart';
import 'package:voyager/src/features/mentor/controller/video_controller.dart';
import 'package:voyager/src/features/mentor/widget/post_content.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:flutter/material.dart';

class Post extends StatefulWidget {
  const Post({super.key});

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  final MenteePostController postController = Get.put(MenteePostController());
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;
  bool _isLoadingMore = false;
  bool _hasMorePosts = true;
  VideoPlaybackController videoPlaybackController =
      Get.put(VideoPlaybackController());

  @override
  void initState() {
    super.initState();
    _initializePosts();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMorePosts();
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingMore || !_hasMorePosts) return;
    setState(() => _isLoadingMore = true);
    try {
      final hasMore = await postController.loadMorePosts();
      setState(() => _hasMorePosts = hasMore);
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  void _initializePosts() {
    postController.resetPagination();
    postController.loadPosts();
  }

  Future<void> _refreshPosts() async {
    setState(() => _isRefreshing = true);
    try {
      await postController.refreshPosts();
      setState(() => _hasMorePosts = true);
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    Get.delete<MenteePostController>();
    super.dispose();
  }

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
          title: Text(
            'Posts',
            style: TextStyle(
              color: Colors.black,
              fontSize: screenWidth * 0.07,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: false,
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
            onRefresh: _refreshPosts,
            child: Obx(() {
              final posts = postController.posts;
              final isLoading = postController.isLoading.value;
              final error = postController.error.value;

              if (isLoading && posts.isEmpty && !_isRefreshing) {
                return _buildLoadingState();
              }

              if (posts.isEmpty) {
                return _buildErrorState(context, error);
              }

              return ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.02,
                ),
                itemCount: posts.length + (_hasMorePosts ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == posts.length) {
                    return _buildMoreIndicator();
                  }
                  return Column(
                    children: [
                      PostContent(post: posts[index]),
                      SizedBox(height: screenHeight * 0.02),
                    ],
                  );
                },
              );
            })));
  }

  Widget _buildLoadingState() {
    return Center(
      child: Lottie.asset(
        'assets/images/loading.json',
        fit: BoxFit.cover,
        width: 40,
        height: 40,
        repeat: true,
      ),
    );
  }

  Widget _buildMoreIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: _isLoadingMore
            ? Lottie.asset(
                'assets/images/loading.json',
                fit: BoxFit.cover,
                width: 40,
                height: 40,
                repeat: true,
              )
            : Text('No more posts available'),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: screenWidth * 0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/images/empty-post.json',
                  fit: BoxFit.cover,
                  width: screenWidth * 0.6,
                  height: screenWidth * 0.4,
                  repeat: true,
                ),
                SizedBox(height: screenWidth * 0.05),
                Text(
                  'No Posts!',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenWidth * 0.02),
                Text(
                  'Make sure you are enrolled to a course\nand got accepted by the mentor',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: screenWidth * 0.033,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _refreshPosts,
          child: const Text('Retry'),
        ),
      ],
    );
  }
}
