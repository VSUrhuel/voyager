import 'package:get/get.dart';
import 'package:voyager/src/features/mentor/controller/post_controller.dart';
import 'package:voyager/src/features/mentor/model/content_model.dart';
import 'package:voyager/src/features/mentor/screens/post/create_post.dart';
import 'package:voyager/src/features/mentor/widget/post_content.dart';
import 'package:voyager/src/widgets/custom_page_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Post extends StatefulWidget {
  const Post({super.key});

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  late PostController postController;
  late Future<List<PostContentModel>> postsFuture;
  bool _isRefreshing = false;

  @override
  void initState() {
    _initializePosts();
    super.initState();
  }

  void _initializePosts() {
    postController = Get.put(PostController());
    postsFuture = postController.getPosts();
  }

  Future<void> _refreshPosts() async {
    setState(() => _isRefreshing = true);
    try {
      postsFuture = postController.getPosts();
      await postsFuture;
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  void dispose() {
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
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: screenHeight * 0.03,
              backgroundColor: Colors.grey[200],
              child: IconButton(
                icon: const FaIcon(FontAwesomeIcons.pen, color: Colors.black),
                onPressed: () => Navigator.push(
                  context,
                  CustomPageRoute(
                      page: CreatePost(
                    fromHome: true,
                  )),
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.02,
            ),
            child: Column(
              children: [
                const Divider(thickness: 1),
                SizedBox(height: screenHeight * 0.02),
                FutureBuilder<List<PostContentModel>>(
                  future: postsFuture,
                  builder: (context, snapshot) {
                    if (_isRefreshing) {
                      return SizedBox(
                        height: screenHeight * 0.5,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox(
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (snapshot.hasError) {
                      debugPrint('Post loading error: ${snapshot.error}');
                      debugPrintStack(stackTrace: snapshot.stackTrace);
                      return _buildErrorState(context);
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildEmptyState(context);
                    }

                    return Column(
                      children: snapshot.data!
                          .map((post) => Column(
                                children: [
                                  PostContent(post: post),
                                  SizedBox(height: screenHeight * 0.02),
                                ],
                              ))
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Icon(Icons.error_outline, size: 50, color: Colors.red[300]),
        const SizedBox(height: 16),
        Text(
          'Failed to load posts',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Please check your connection and try again',
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
          ).then((_) {
            dispose();
            if (mounted) {
              setState(() {
                postsFuture = postController.getPosts();
              });
            }
          }),
          child: const Text('Create Post'),
        ),
      ],
    );
  }
}
