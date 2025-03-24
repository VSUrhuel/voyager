import 'package:flutter/material.dart';

class SkillsDisplay extends StatelessWidget {
  final Color color;
  final Text text;
  final dynamic width;
  final dynamic height;
  const SkillsDisplay(
      {super.key,
      required this.color,
      required this.text,
      required this.width,
      required this.height});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      width: screenWidth * width, // Adjust width as needed
      height: screenHeight * height, // Adjust height as needed
      child: Container(
        decoration: BoxDecoration(
          color: color, // Light Green Color (adjust as needed)
          borderRadius:
              BorderRadius.circular(20), // Half of height for pill shape
          boxShadow: [
            // Add shadow for depth
          ],
        ),
        child: Center(
          // Center the text within the container
          child: text,
        ),
      ),
    );
  }
}
