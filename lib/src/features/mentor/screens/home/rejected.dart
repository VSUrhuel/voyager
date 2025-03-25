import 'package:flutter/material.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:voyager/src/widgets/user_card.dart';
import 'package:voyager/src/widgets/vertical_widget_slider.dart';

class RejectedList extends StatefulWidget {
  const RejectedList({super.key});

  @override
  State<RejectedList> createState() => _RejectedListState();
}

class _RejectedListState extends State<RejectedList> {
  late Future<List<UserModel>> rejectedMenteesFuture;

  @override
  void initState() {
    super.initState();
    refreshRejectedMentees();
  }

  void refreshRejectedMentees() {
    setState(() {
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
    return Container(
      height: screenHeight * 0.6, // Limits to 25% of screen height
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
                      return const Center(child: CircularProgressIndicator());
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
                return VerticalWidgetSlider(
                  widgets: snapshot.data!
                      .map((mentee) => UserCard(
                            user: mentee,
                            height: screenHeight * 0.80,
                            actions: [],
                            onActionCompleted: refreshRejectedMentees,
                          ))
                      .toList(),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
