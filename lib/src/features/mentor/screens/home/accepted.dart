import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentor/controller/mentee_list_controller.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:voyager/src/widgets/user_card.dart';
import 'package:voyager/src/widgets/vertical_widget_slider.dart';

class AcceptedList extends StatefulWidget {
  const AcceptedList(
      {super.key,
      required this.menteeListController,
      required this.isMentorHome});
  final MenteeListController menteeListController;
  final bool isMentorHome; // Added to control the height of the list

  @override
  State<AcceptedList> createState() => _AcceptedListState();
}

class _AcceptedListState extends State<AcceptedList> {
  late Future<List<UserModel>> _acceptedMenteesFuture;
  final FirestoreInstance _firestore = FirestoreInstance();
  bool _isMounted = false;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  double _acceptedMenteesHeight = 0.6; // Default height for accepted mentees
  @override
  void initState() {
    super.initState();
    _isMounted = true;
    widget.menteeListController.searchMenteeController.addListener(loadNewData);
    _acceptedMenteesFuture = _fetchAcceptedMentees();
    if (widget.isMentorHome) {
      _acceptedMenteesHeight = 0.4; // 27% of screen height for mentor home
    } else {
      _acceptedMenteesHeight = 0.7; // 25% of screen height for other screens
    }
  }

  @override
  void dispose() {
    widget.menteeListController.searchMenteeController
        .removeListener(loadNewData);
    _isMounted = false;
    super.dispose();
  }

  Future<void> refreshAcceptedMentees() async {
    setState(() {
      if (!_isMounted) return; // Check if the widget is still mounted
      _acceptedMenteesFuture = _fetchAcceptedMentees();
    });
  }

  void loadNewData() {
    if (!_isMounted) return;

    setState(() {
      final index = widget.menteeListController.currentStatus.value;
      if (index == 0) {
        // Filter accepted mentees based on search text
        _acceptedMenteesFuture = _fetchAcceptedMentees().then((mentees) {
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
      } else {
        _acceptedMenteesFuture = _fetchAcceptedMentees();
      }
    });
  }

  Future<List<UserModel>> _fetchAcceptedMentees() async {
    try {
      final mentees = await _firestore.getMentees("accepted");
      return mentees;
    } catch (e) {
      if (!_isMounted) return []; // Check if the widget is still mounted
      rethrow; // Re-throw to let FutureBuilder handle it
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: refreshAcceptedMentees,
        child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            // Limits to 25% of screen height
            child: SizedBox(
                height: screenHeight * _acceptedMenteesHeight,
                child: Column(children: [
                  FutureBuilder<List<UserModel>>(
                    future: _acceptedMenteesFuture,
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
                            refreshAcceptedMentees(); // Refresh accepted mentees after loading
                            return Center(
                                child: Text('Still loading, please wait...'));
                          },
                        );
                      }

                      if (snapshot.hasError) {
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
                                  0.3, // Slightly larger for better visibility
                              height: screenWidth * 0.3,
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
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                            child: SingleChildScrollView(
                                child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Lottie.asset(
                              'assets/images/empty-list.json', // Consider adding a dedicated empty state animation
                              width: screenWidth * 0.3,
                              height: screenWidth * 0.3,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'No Accepted Mentees',
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'When you accept mentee requests,\nthey will appear here',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: screenWidth * 0.033,
                                color: Colors.grey[600],
                                height: 1.4,
                              ),
                            ),
                          ],
                        )));
                      }

                      return SizedBox(
                          height: screenHeight *
                              _acceptedMenteesHeight, // Limits to 25% of screen height
                          child: VerticalWidgetSlider(
                            widgets: snapshot.data!
                                .map((mentee) => UserCard(
                                      user: mentee,
                                      height: screenHeight * 0.1,
                                      actions: ['Remove'],
                                      onActionCompleted: refreshAcceptedMentees,
                                    ))
                                .toList(),
                          ));
                    },
                  ),
                ]))));
  }
}
