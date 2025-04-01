import 'package:flutter/material.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentor/controller/mentee_list_controller.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:voyager/src/widgets/user_card.dart';

class PendingList extends StatefulWidget {
  final bool isMentorHome;
  const PendingList(
      {super.key,
      required this.isMentorHome,
      required this.menteeListController});
  final MenteeListController menteeListController;

  @override
  State<PendingList> createState() => _PendingListState();
}

class _PendingListState extends State<PendingList> {
  late Future<List<UserModel>> _pendingMenteesFuture;
  final FirestoreInstance _firestore = FirestoreInstance();
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    widget.menteeListController.searchMenteeController.addListener(loadNewData);
    _pendingMenteesFuture = _fetchPendingMentees();
  }

  @override
  void dispose() {
    widget.menteeListController.searchMenteeController
        .removeListener(loadNewData);
    _isMounted = false;
    super.dispose();
  }

  Future<void> refreshPendingMentees() async {
    setState(() {
      if (!_isMounted) return;
      _pendingMenteesFuture = _fetchPendingMentees();
    });
  }

  void loadNewData() {
    if (!_isMounted) return;

    setState(() {
      _pendingMenteesFuture = _fetchPendingMentees().then((mentees) {
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
    });
  }

  Future<List<UserModel>> _fetchPendingMentees() async {
    try {
      final mentees = await _firestore.getMentees("pending");
      return mentees;
    } catch (e) {
      if (!_isMounted) return [];
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      height: screenHeight * 0.6, // Limits to 25% of screen height
      child: SizedBox(
        height: screenHeight * 0.25, // Limits to 25% of screen height
        child: SingleChildScrollView(
          child: Column(
            children: [
              FutureBuilder<List<UserModel>>(
                future: _pendingMenteesFuture,
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
                    return SizedBox(
                        height: screenHeight * 0.6,
                        child: Column(
                          // Use Column to prevent overflow in ListView
                          children: snapshot.data!
                              .map((mentee) => UserCard(
                                    user: mentee,
                                    height: screenHeight * 0.80,
                                    actions: ['Accept', 'Reject'],
                                    onActionCompleted: refreshPendingMentees,
                                  ))
                              .toList(),
                        ));
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
