import 'package:flutter/material.dart';
import 'package:voyager/src/features/mentor/controller/mentee_list_controller.dart';
import 'package:voyager/src/features/mentor/screens/home/accepted.dart';
import 'package:voyager/src/features/mentor/screens/home/pending.dart';
import 'package:voyager/src/features/mentor/screens/home/rejected.dart';

class StatusToggleButton extends StatefulWidget {
  const StatusToggleButton({super.key, required this.controller});
  final MenteeListController controller;

  @override
  State<StatusToggleButton> createState() => _StatusToggleButtonState();
}

class _StatusToggleButtonState extends State<StatusToggleButton> {
  int selectedIndex = 0;
  final List<String> labels = ["Accepted", "Pending", "Rejected"];
  final List<Color> selectedColors = [
    Color(0xFF1877F2), // Blue for Accepted
    Color(0xFFFB8C00), // Orange for Pending
    Color(0xFFD32F2F) // Red for Rejected
  ];
  final List<Color> unselectedColors = [
    Color(0x7F455A64),
    Color(0x7F455A64),
    Color(0x7F455A64),
  ];
  final GlobalKey _pendingListKey = GlobalKey();
  final GlobalKey _acceptedListKey = GlobalKey();
  final GlobalKey _rejectedListKey = GlobalKey();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  Future<void> handleRefresh() async {
    try {
      switch (selectedIndex) {
        case 0:
          if (_acceptedListKey.currentState != null) {
            (_pendingListKey.currentState as dynamic).refreshAcceptedMentees();
          }
          break;
        case 1:
          if (_pendingListKey.currentState != null) {
            (_pendingListKey.currentState as dynamic).refreshPendingMentees();
          }
          break;
        case 2:
          if (_rejectedListKey.currentState != null) {
            (_pendingListKey.currentState as dynamic).refreshRejectedMentees();
          }
          break;
      }
    } catch (e) {
      debugPrint('Refresh error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Column(children: [
      Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(3, (index) {
            return Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      selectedIndex = index;
                    });
                    widget.controller.currentStatus.value = selectedIndex;
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.01,
                    ),
                    backgroundColor: selectedIndex == index
                        ? selectedColors[index]
                        : unselectedColors[index],
                    foregroundColor: selectedIndex == index
                        ? Colors.white
                        : Color(0xFF4A4A4A),
                  ),
                  child: Text(labels[index]),
                ));
          })),
      SizedBox(height: screenHeight * 0.02),
      RefreshIndicator(
        onRefresh: handleRefresh,
        key: _refreshIndicatorKey,
        child: selectedIndex == 0
            ? AcceptedList(
                menteeListController: widget.controller, key: _acceptedListKey)
            : selectedIndex == 1
                ? PendingList(
                    menteeListController: widget.controller,
                    key: _pendingListKey,
                    isMentorHome: false,
                  )
                : RejectedList(
                    menteeListController: widget.controller,
                    key: _rejectedListKey),
      )
    ]);
  }
}
