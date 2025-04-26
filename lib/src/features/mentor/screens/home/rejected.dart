import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentor/controller/mentee_list_controller.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:voyager/src/widgets/user_card.dart';
import 'package:voyager/src/widgets/vertical_widget_slider.dart';

class RejectedList extends StatefulWidget {
  const RejectedList({super.key, required this.menteeListController});
  final MenteeListController menteeListController;

  @override
  State<RejectedList> createState() => _RejectedListState();
}

class _RejectedListState extends State<RejectedList> {
  late Future<List<UserModel>> rejectedMenteesFuture;
  bool isMounted = false;

  @override
  void initState() {
    super.initState();
    isMounted = true;
    widget.menteeListController.searchMenteeController.addListener(loadNewData);
    refreshRejectedMentees();
  }

  void loadNewData() {
    if (!isMounted) return; // Check if the widget is still mounted

    setState(() {
      final index = widget.menteeListController.currentStatus.value;
      if (index == 2) {
        // Filter rejected mentees based on search text
        rejectedMenteesFuture = getRejectedMentees().then((mentees) {
          final searchText = widget
              .menteeListController.searchMenteeController.text
              .toLowerCase();
          if (searchText.isEmpty) {
            return mentees; // Return all if no search text
          }
          return mentees
              .where((mentee) =>
                  mentee.accountApiName.toLowerCase().contains(searchText))
              .toList();
        });
      }
    });
  }

  void refreshRejectedMentees() {
    setState(() {
      if (!isMounted) return; // Check if the widget is still mounted
      rejectedMenteesFuture = getRejectedMentees();
    });
  }

  FirestoreInstance firestore = FirestoreInstance();
  Future<List<UserModel>> getRejectedMentees() async {
    List<UserModel> users = await firestore.getMentees("rejected");
    return users;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        // Limits to 25% of screen height
        child: SizedBox(
          height: screenHeight * 0.6,
          child: Column(
            children: [
              FutureBuilder<List<UserModel>>(
                future: rejectedMenteesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return FutureBuilder(
                      future: Future.delayed(const Duration(seconds: 3)),
                      builder: (context, delaySnapshot) {
                        if (delaySnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return SizedBox(
                              height: screenHeight * 0.25,
                              child: Center(
                                  child: Center(
                                      child: Lottie.asset(
                                'assets/images/loading.json',
                                fit: BoxFit.cover,
                                width: screenWidth * 0.2,
                                height: screenWidth * 0.2,
                                repeat: true,
                              ))));
                        }
                        refreshRejectedMentees(); // Refresh accepted mentees after loading
                        return const Center(
                            child: Text('Still loading, please wait...'));
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                        child: SingleChildScrollView(
                            child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          'assets/images/empty-list.json', // Consider adding a dedicated empty state animation
                          width: screenWidth * 0.25,
                          height: screenWidth * 0.25,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'No Rejected Mentees',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'When there are rejected requests,\nthey will appear here',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenWidth * 0.033,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 24),
                      ],
                    )));
                  } else {
                    return SizedBox(
                        height: screenHeight *
                            0.6, // Limits to 25% of screen height
                        child: VerticalWidgetSlider(
                          widgets: snapshot.data!
                              .map((mentee) => UserCard(
                                    user: mentee,
                                    height: screenHeight * 0.80,
                                    actions: [],
                                    onActionCompleted: refreshRejectedMentees,
                                  ))
                              .toList(),
                        ));
                  }
                },
              ),
            ],
          ),
        ));
  }
}
