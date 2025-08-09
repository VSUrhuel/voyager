// ignore_for_file: deprecated_member_use

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:voyager/src/features/mentor/controller/post_controller.dart';
import 'package:voyager/src/features/mentor/controller/video_controller.dart';
import 'package:voyager/src/features/mentor/model/content_model.dart';
import 'package:voyager/src/features/mentor/screens/post/create_post.dart';
import 'package:voyager/src/features/mentor/widget/post_content.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:voyager/src/widgets/custom_page_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

class Post extends StatefulWidget {
  const Post({super.key});

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  final PostController postController = Get.put(PostController());
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _isRefreshing = false;
  bool _hasMorePosts = true;
  bool _hasCourseAllocation = false;
  late Future<List<PostContentModel>> postsFuture;
  VideoPlaybackController videoPlaybackController =
      Get.put(VideoPlaybackController());

  @override
  void initState() {
    _initializePosts();
    _updateCourseAllocationStatus();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  void _updateCourseAllocationStatus() async {
    // Check if the user has a course allocation
    FirestoreInstance firestoreInstance = Get.put(FirestoreInstance());
    final val = await firestoreInstance.checkCourseAllocation();
    setState(() {
      _hasCourseAllocation = val;
    });
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
    Get.delete<PostController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          scrolledUnderElevation: 0,
          toolbarHeight: screenHeight * 0.07,
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Padding(
            padding: EdgeInsets.only(
              top: screenHeight * 0.02,
            ),
            child: Text(
              'Posts',
              style: TextStyle(
                color: Colors.black,
                fontSize: screenWidth * 0.07,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          centerTitle: false,
          actions: [
            _buildCreatePostButton(context, postController),
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

  Widget _buildCreatePostButton(
      BuildContext context, PostController controller) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.15),
                Theme.of(context).primaryColor.withOpacity(0.25),
              ],
            ),
          ),
          child: Icon(
            FontAwesomeIcons.solidPenToSquare,
            color: Theme.of(context).primaryColor,
            size: MediaQuery.of(context).size.width * 0.05,
          ),
        ),
        onPressed: () {
          // Reads the allocation status directly from the controller
          if (!_hasCourseAllocation) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('You need to be allocated a course to create a post.'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          // Navigate to the create post screen
          Navigator.push(
            context,
            CustomPageRoute(
              page: const CreatePost(),
              direction: AxisDirection.left,
            ),
          ).then((didPost) {
            // Refresh posts if a new post was created
            if (didPost == true) {
              controller.refreshPosts();
            }
          });
        },
      ),
    );
  }
}
