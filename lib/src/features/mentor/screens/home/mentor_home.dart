import 'package:voyager/src/features/mentor/screens/home/accepted.dart';
import 'package:voyager/src/features/mentor/screens/home/mentee_list.dart';
import 'package:voyager/src/features/mentor/screens/home/pending.dart';
import 'package:voyager/src/features/mentor/screens/home/request_list.dart';
import 'package:voyager/src/repository/authentication_repository_firebase/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MentorHome extends StatefulWidget {
  const MentorHome({super.key});

  @override
  _MentorHomeState createState() => _MentorHomeState();
}

class _MentorHomeState extends State<MentorHome> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final isChanged = false;

  // Keys to access the list states
  final GlobalKey _pendingListKey = GlobalKey();
  final GlobalKey _acceptedListKey = GlobalKey();

  Future<void> _handleRefresh() async {
    // Refresh both lists
    if (_pendingListKey.currentState != null) {
      (_pendingListKey.currentState as dynamic).refreshPendingMentees();
    }
    if (_acceptedListKey.currentState != null) {
      (_acceptedListKey.currentState as dynamic).refreshAcceptedMentees();
    }
    await Future.delayed(
        const Duration(milliseconds: 500)); // Small delay for visual feedback
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final auth = FirebaseAuthenticationRepository();

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        toolbarHeight: screenHeight * 0.10,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: screenWidth * 0.06,
          fontWeight: FontWeight.bold,
        ),
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: screenHeight * 0.035,
              child:
                  Image.asset('assets/images/application_images/profile.png'),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, Rhuel',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Courses awaits you!',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: screenHeight * 0.03,
              backgroundColor: Colors.grey[200],
              child: IconButton(
                icon: const FaIcon(
                  FontAwesomeIcons.pen,
                  color: Colors.black,
                ),
                onPressed: () {
                  // Handle notification tap
                },
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(), // Needed for RefreshIndicator
          child: Center(
            child: Padding(
              padding: EdgeInsets.only(
                left: screenWidth * 0.06,
                right: screenWidth * 0.05,
                top: screenHeight * 0.01,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pending Requests',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RequestList(),
                            ),
                          ).then(
                              (_) => _refreshIndicatorKey.currentState?.show());
                        },
                        child: Text(
                          'View All',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: screenWidth * 0.033,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: screenHeight * 0.26,
                    child: PendingList(
                      key: _pendingListKey,
                      isMentorHome: true,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Mentee List',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MenteeList(),
                            ),
                          ).then(
                              (_) => _refreshIndicatorKey.currentState?.show());
                        },
                        child: Text(
                          'View All',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: screenWidth * 0.033,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: screenHeight * 0.3,
                    child: AcceptedList(
                      key: _acceptedListKey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
