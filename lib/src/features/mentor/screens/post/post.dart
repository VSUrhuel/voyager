import 'package:get/get.dart';
import 'package:voyager/src/features/mentor/controller/post_controller.dart';
import 'package:voyager/src/features/mentor/controller/video_controller.dart';
import 'package:voyager/src/features/mentor/model/content_model.dart';
import 'package:voyager/src/features/mentor/screens/post/create_post.dart';
import 'package:voyager/src/features/mentor/widget/post_content.dart';
import 'package:voyager/src/widgets/custom_page_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  late Future<List<PostContentModel>> postsFuture;
  VideoPlaybackController videoPlaybackController =
      Get.put(VideoPlaybackController());

  @override
  void initState() {
    _initializePosts();
    _scrollController.addListener(_scrollListener);
    super.initState();
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

    return Scaffold(
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
                    fontSize: screenWidth * 0.07, fontWeight: FontWeight.bold),
              ),
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
                );
              },
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

            if (posts.isEmpty) {
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
    );
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Icon(Icons.error_outline, size: 50, color: Colors.red[300]),
        const SizedBox(height: 16),
        Center(
            child: Text(
          'Failed to load posts',
          style: Theme.of(context).textTheme.titleMedium,
        )),
        const SizedBox(height: 8),
        Text(
          error,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _refreshPosts,
          child: const Text('Retry'),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Icon(Icons.feed_outlined, size: 50, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text(
          'No posts available',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Be the first to create a post',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreatePost(),
            ),
          ).then((_) => _refreshPosts()),
          child: const Text('Create Post'),
        ),
      ],
    );
  }
}
