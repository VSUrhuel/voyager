import 'package:flutter/material.dart';
import 'package:voyager/src/features/mentor/screens/session/completed.dart';
import 'package:voyager/src/features/mentor/screens/session/upcoming.dart';

class ToggleButton extends StatefulWidget {
  const ToggleButton({super.key});

  @override
  State<ToggleButton> createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Center(
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
      SizedBox(height: screenWidth * 0.04),
      _selectedIndex == 0 ? CompletedSession() : UpcomingSession(),
    ]));
  }
}
