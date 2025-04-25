import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:voyager/src/features/mentee/controller/notification_controller.dart';
import 'package:voyager/src/features/mentee/widgets/notification_content_card.dart';
import 'package:voyager/src/features/mentor/model/content_model.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final controller = NotificationController();
  final currentUser = FirebaseAuth.instance.currentUser;

  late Future<List<PostContentModel>> todayPostsFuture;
  late Future<List<PostContentModel>> previousPostsFuture;
  int _visiblePreviousCount = 5;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    final userEmail = currentUser?.email ?? '';
    todayPostsFuture = controller.getTodayPostsForUser(userEmail);
    previousPostsFuture = controller.getPreviousNotificationsForUser(userEmail);
  }

  Future<void> _refresh() async {
    setState(() {
      _visiblePreviousCount = 5; // Reset to initial state
      _loadNotifications();
    });
  }

  void _showMorePrevious() {
    setState(() {
      _visiblePreviousCount += 5;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 18.0,
          ),
        ),
        centerTitle: true,
        actions: [],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: screenHeight * 0.02),
                      const Text(
                        'Today',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),

                /// Today's Notifications
                FutureBuilder<List<PostContentModel>>(
                  future: todayPostsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Lottie.asset(
                            'assets/images/loading.json',
                            fit: BoxFit.cover,
                            width: screenHeight * 0.08,
                            height: screenWidth * 0.04,
                            repeat: true,
                          ),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return const SliverToBoxAdapter(
                        child: Text("Error loading today's notifications."),
                      );
                    }
                    if (snapshot.data == null || snapshot.data!.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            "No new notifications today",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => NotificationContentCard(
                          post: snapshot.data![index],
                        ),
                        childCount: snapshot.data!.length,
                      ),
                    );
                  },
                ),

                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: screenHeight * 0.03),
                      const Text(
                        'Earlier',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),

                /// Previous Notifications with Pagination
                FutureBuilder<List<PostContentModel>>(
                  future: previousPostsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Lottie.asset(
                            'assets/images/loading.json',
                            fit: BoxFit.cover,
                            width: screenHeight * 0.08,
                            height: screenWidth * 0.04,
                            repeat: true,
                          ),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return const SliverToBoxAdapter(
                        child: Text("Error loading previous notifications."),
                      );
                    }
                    if (snapshot.data == null || snapshot.data!.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            "No earlier notifications",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    }

                    final allPrevious = snapshot.data!;
                    final visible =
                        allPrevious.take(_visiblePreviousCount).toList();

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index < visible.length) {
                            return NotificationContentCard(
                              post: visible[index],
                            );
                          } else {
                            return Center(
                              child: TextButton(
                                onPressed: _showMorePrevious,
                                child: const Text(
                                  "See More",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                        childCount: visible.length +
                            (_visiblePreviousCount < allPrevious.length
                                ? 1
                                : 0),
                      ),
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
}
