import 'package:flutter/material.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/repository/firebase_repository/firestore_instance.dart';
import 'package:voyager/src/widgets/user_card.dart';
import 'package:voyager/src/widgets/vertical_widget_slider.dart';

class AcceptedList extends StatefulWidget {
  const AcceptedList({super.key});

  @override
  State<AcceptedList> createState() => _AcceptedListState();
}

class _AcceptedListState extends State<AcceptedList> {
  late Future<List<UserModel>> _acceptedMenteesFuture;
  final FirestoreInstance _firestore = FirestoreInstance();

  @override
  void initState() {
    super.initState();
    _acceptedMenteesFuture = _fetchAcceptedMentees();
    refreshAcceptedMentees();
  }

  Future<List<UserModel>> _fetchAcceptedMentees() async {
    try {
      final mentees = await _firestore.getMentees("accepted");
      return mentees;
    } catch (e) {
      rethrow; // Re-throw to let FutureBuilder handle it
    }
  }

  void refreshAcceptedMentees() async {
    setState(() {
      _acceptedMenteesFuture = _fetchAcceptedMentees();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
        height: screenHeight * 0.6, // Limits to 25% of screen height
        child: SingleChildScrollView(
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
                      return const Center(child: CircularProgressIndicator());
                    }
                    refreshAcceptedMentees(); // Refresh accepted mentees after loading
                    return const Center(
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

              return VerticalWidgetSlider(
                widgets: snapshot.data!
                    .map((mentee) => UserCard(
                          user: mentee,
                          height: screenHeight * 0.1,
                          actions: ['Remove'],
                          onActionCompleted: refreshAcceptedMentees,
                        ))
                    .toList(),
              );
            },
          ),
        ])));
  }
}
