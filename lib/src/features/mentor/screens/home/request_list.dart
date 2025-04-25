import 'package:flutter/material.dart';
import 'package:voyager/src/features/mentor/controller/mentee_list_controller.dart';
import 'package:voyager/src/features/mentor/screens/home/pending.dart';

class RequestList extends StatefulWidget {
  const RequestList({super.key});

  @override
  State<RequestList> createState() => _RequestListState();
}

class _RequestListState extends State<RequestList> {
  final MenteeListController menteeListController = MenteeListController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final GlobalKey _pendingListKey = GlobalKey();

  Future<void> handleRefresh() async {
    // Call the refresh method directly on the PendingList's state
    if (_pendingListKey.currentState != null) {
      (_pendingListKey.currentState as dynamic).refreshPendingMentees();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
        bottom: true,
        top: false,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1.0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Pending Requests',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.normal,
                fontSize: 18.0,
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30.0),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller:
                              menteeListController.searchMenteeController,
                          decoration: const InputDecoration(
                            hintText: 'Search',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 15.0,
                              horizontal: 7,
                            ),
                          ),
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ),
                      Icon(
                        Icons.search,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  key: _refreshIndicatorKey,
                  onRefresh: handleRefresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: screenWidth * 0.05,
                        right: screenWidth * 0.05,
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            SizedBox(height: screenHeight * 0.02),
                            PendingList(
                              menteeListController: menteeListController,
                              key: _pendingListKey,
                              isMentorHome: false,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
