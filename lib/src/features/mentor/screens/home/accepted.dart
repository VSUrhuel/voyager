import 'package:flutter/material.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/features/mentor/controller/mentee_list_controller.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:voyager/src/widgets/user_card.dart';
import 'package:voyager/src/widgets/vertical_widget_slider.dart';

class AcceptedList extends StatefulWidget {
  const AcceptedList({super.key, required this.menteeListController});
  final MenteeListController menteeListController;

  @override
  State<AcceptedList> createState() => _AcceptedListState();
}

class _AcceptedListState extends State<AcceptedList> {
  late Future<List<UserModel>> _acceptedMenteesFuture;
  final FirestoreInstance _firestore = FirestoreInstance();
  bool _isMounted = false;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  @override
  void initState() {
    super.initState();
    _isMounted = true;
    widget.menteeListController.searchMenteeController.addListener(loadNewData);
    _acceptedMenteesFuture = _fetchAcceptedMentees();
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
                height: screenHeight * 0.6,
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
                                      child: CircularProgressIndicator()));
                            }
                            refreshAcceptedMentees(); // Refresh accepted mentees after loading
                            return Center(
                                child: Text('Still loading, please wait...'));
                          },
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Failed to load mentees'),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: refreshAcceptedMentees,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text(
                            'No accepted mentees found',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: screenWidth * 0.033,
                            ),
                          ),
                        );
                      }

                      return SizedBox(
                          height: screenHeight *
                              0.6, // Limits to 25% of screen height
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
