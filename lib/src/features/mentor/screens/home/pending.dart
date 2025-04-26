import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentor/controller/mentee_list_controller.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:voyager/src/widgets/user_card.dart';
import 'package:voyager/src/widgets/vertical_widget_slider.dart';

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
  late Future<List<UserModel>> _pendingMenteesFuture = _fetchPendingMentees();
  final FirestoreInstance _firestore = FirestoreInstance();
  bool _isMounted = false;
  double _pendingMenteesHeight = 0.6;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    widget.menteeListController.searchMenteeController.addListener(loadNewData);
    if (widget.isMentorHome) {
      _pendingMenteesHeight = 0.27; // 27% of screen height for mentor home
    } else {
      _pendingMenteesHeight = 0.6; // 25% of screen height for other screens
    }
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
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      // Limits to 25% of screen height
      child: SizedBox(
        height: screenHeight * _pendingMenteesHeight,
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
                            child: Center(
                                child: Lottie.asset(
                              'assets/images/loading.json',
                              fit: BoxFit.cover,
                              width: screenWidth * 0.2,
                              height: screenWidth * 0.2,
                              repeat: true,
                            )));
                      }
                      refreshPendingMentees(); // Refresh accepted mentees after loading
                      return const Center(
                          child: Text('Still loading, please wait...'));
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                      child: SingleChildScrollView(
                          child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/images/error.json',
                        fit: BoxFit.cover,
                        width: screenWidth *
                            0.2, // Slightly larger for better visibility
                        height: screenWidth * 0.2,
                        repeat: true,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Oops! Something went wrong',
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.w600,
                          color: Colors.red[700],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Failed to load mentees data',
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                  )));
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
                        'No Pending Mentees',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'When there are mentee requests,\nthey will appear here',
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
                      height: screenHeight * _pendingMenteesHeight,
                      child: VerticalWidgetSlider(
                        widgets: snapshot.data!
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
    );
  }
}
