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
    final textTheme = Theme.of(context).textTheme;

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
            titleTextStyle: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            elevation: 0,
            title: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      top: screenHeight * 0.013, left: screenHeight * 0.01),
                  child: Text(
                    'Posts',
                    style: TextStyle(
                        fontSize: screenWidth * 0.07,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            actions: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 1.0, end: 1.0),
                duration: Duration(milliseconds: 200),
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: Padding(
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
                        FontAwesomeIcons
                            .solidPenToSquare, // Alternative solid version
                        color: Theme.of(context).primaryColor,
                        size: screenWidth * 0.05,
                      ),
                    ),
                    onPressed: () {
                      if (_hasCourseAllocation == false) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'You need to be allocated a course to create a post.',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        CustomPageRoute(
                          page: CreatePost(),
                          direction: AxisDirection.left,
                        ),
                      );
                    },
                  ),
                ),
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

                if (error.isNotEmpty) {
                  return _buildErrorState(context, error);
                }

                if (posts.isEmpty) {
                  return _buildEmptyState(context);
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
                    if (index >= posts.length) {
                      // Trigger load more when we reach the end
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        postController.loadMorePosts();
                      });
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
              })
              // child: SingleChildScrollView(
              //   physics: const AlwaysScrollableScrollPhysics(),
              //   child: Padding(
              //     padding: EdgeInsets.symmetric(
              //       horizontal: screenWidth * 0.05,
              //       vertical: screenHeight * 0.02,
              //     ),
              //     child: Column(
              //       children: [
              //         const Divider(thickness: 1),
              //         SizedBox(height: screenHeight * 0.02),
              //         FutureBuilder<List<PostContentModel>>(
              //           future: postsFuture,
              //           builder: (context, snapshot) {
              //             if (_isRefreshing) {
              //               return SizedBox(
              //                 height: screenHeight * 0.5,
              //                 child: Center(child: CircularProgressIndicator()),
              //               );
              //             }

              //             if (snapshot.connectionState == ConnectionState.waiting) {
              //               return SizedBox(
              //                 child: const Center(child: CircularProgressIndicator()),
              //               );
              //             }

              //             if (snapshot.hasError) {
              //               debugPrint('Post loading error: ${snapshot.error}');
              //               debugPrintStack(stackTrace: snapshot.stackTrace);
              //               return _buildErrorState(context);
              //             }

              //             if (!snapshot.hasData || snapshot.data!.isEmpty) {
              //               return _buildEmptyState(context);
              //             }

              //             return Column(
              //               children: snapshot.data!
              //                   .map((post) => Column(
              //                         children: [
              //                           PostContent(post: post),
              //                           SizedBox(height: screenHeight * 0.02),
              //                         ],
              //                       ))
              //                   .toList(),
              //             );
              //           },
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              ),
        ));
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildMoreIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: _isLoadingMore
            ? CircularProgressIndicator()
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
        Lottie.asset(
          'assets/images/error.json',
          fit: BoxFit.cover,
          width: screenWidth * 0.6,
          height: screenWidth * 0.4,
          repeat: true,
        ),
        const SizedBox(height: 16),
        Center(
            child: Text(
          'Failed to load posts',
          style: Theme.of(context).textTheme.titleMedium,
        )),
        const SizedBox(height: 8),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _refreshPosts,
          child: const Text('Retry'),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.only(
          left: size.width * 0.05,
          right: size.width * 0.05,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Animated illustration
            Lottie.asset(
              'assets/images/empty-post.json',
              fit: BoxFit.cover,
              width: size.width * 0.6,
              height: size.width * 0.4,
              repeat: true,
            ),

            const SizedBox(height: 24),

            // Title with better typography
            Text(
              'No Posts Yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white70 : Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // More descriptive subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'The feed is empty right now. Start sharing your knowledge or questions with the community!',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDarkMode ? Colors.white60 : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 24),

            // Filled button with icon
            FilledButton.icon(
              onPressed: () {
                if (_hasCourseAllocation == false) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'You need to be allocated a course to create a post.',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreatePost(),
                  ),
                ).then((_) => _refreshPosts());
              },
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Create First Post'),
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            // Alternative action
            const SizedBox(height: 16),
            TextButton(
              onPressed: _refreshPosts,
              child: Text(
                'Refresh Feed',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
