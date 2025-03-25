import 'package:flutter/material.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentor/screens/home/mentor_home.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:voyager/src/widgets/user_card.dart';

class PendingList extends StatefulWidget {
  final bool isMentorHome;
  const PendingList({super.key, required this.isMentorHome});

  @override
  State<PendingList> createState() => _PendingListState();
}

class _PendingListState extends State<PendingList> {
  late Future<List<UserModel>> pendingMenteesFuture;

  @override
  void initState() {
    super.initState();
    refreshPendingMentees();
  }

  void refreshPendingMentees() {
    setState(() {
      pendingMenteesFuture = getPendingMentees();
    });
  }

  FirestoreInstance firestore = FirestoreInstance();

  Future<List<UserModel>> getPendingMentees() async {
    List<UserModel> mentee = await firestore.getMentees("pending");
    return mentee;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: screenHeight * 0.6, // Limits to 25% of screen height
      child: SizedBox(
        height: screenHeight * 0.25, // Limits to 25% of screen height
        child: SingleChildScrollView(
          child: Column(
            children: [
              FutureBuilder<List<UserModel>>(
                future: pendingMenteesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return FutureBuilder(
                      future: Future.delayed(const Duration(seconds: 3)),
                      builder: (context, delaySnapshot) {
                        if (delaySnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        refreshPendingMentees(); // Refresh accepted mentees after loading
                        return const Center(
                            child: Text('Still loading, please wait...'));
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text(
                      'No pending mentees',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: screenWidth * 0.033,
                      ),
                    );
                  } else {
                    return Column(
                      // Use Column to prevent overflow in ListView
                      children: snapshot.data!
                          .map((mentee) => UserCard(
                                user: mentee,
                                height: screenHeight * 0.80,
                                actions: ['Accept', 'Reject'],
                                onActionCompleted: refreshPendingMentees,
                              ))
                          .toList(),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
