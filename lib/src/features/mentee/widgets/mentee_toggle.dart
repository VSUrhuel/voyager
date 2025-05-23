import 'package:flutter/material.dart';
import 'package:voyager/src/features/mentee/screens/session/mentee_session_completed.dart';
import 'package:voyager/src/features/mentee/screens/session/mentee_session_upcoming.dart';

class MenteeToggle extends StatefulWidget {
  const MenteeToggle({super.key});

  @override
  State<MenteeToggle> createState() => _MenteeToggleState();
}

class _MenteeToggleState extends State<MenteeToggle> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
        child: Center(
            child: Column(children: [
      Container(
        width: screenWidth * 0.9,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.grey[700], // Dark background
        ),
        child: ToggleButtons(
          constraints:
              BoxConstraints.expand(width: screenWidth * 0.41, height: 40),
          borderRadius: BorderRadius.circular(30),
          color: Colors.white60, // Text color for unselected
          selectedColor: Colors.black, // Text color for selected
          fillColor: Colors.white, // Background color when selected
          borderColor: Colors.transparent, // Remove border
          selectedBorderColor: Colors.transparent,
          isSelected: [_selectedIndex == 0, _selectedIndex == 1],
          onPressed: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text("Completed",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                  )),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                "Upcoming",
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 5),
      Text(
        'Please note that your regular schedule is not included in this list. To view your regular schedule, kindly check the calendar..',
        style: TextStyle(
          color: Colors.black,
          fontSize: screenWidth * 0.025,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 5),
      _selectedIndex == 0
          ? const MenteeSessionCompleted()
          : const MenteeSessionUpcoming(),
    ])));
  }
}
