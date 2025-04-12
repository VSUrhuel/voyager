import 'package:flutter/material.dart';
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
                              child: const Center(
                                  child: CircularProgressIndicator()));
                        }
                        refreshRejectedMentees(); // Refresh accepted mentees after loading
                        return const Center(
                            child: Text('Still loading, please wait...'));
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text(
                      'No rejected mentees',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: screenWidth * 0.033,
                      ),
                    );
                  } else {
                    return SizedBox(
                        height: screenHeight *
                            0.6, // Limits to 25% of screen height
                        child: VerticalWidgetSlider(
                          widgets: snapshot.data!
                              .map((mentee) => UserCard(
                                    user: mentee,
                                    height: screenHeight * 0.80,
                                    actions: ['Accept'],
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
