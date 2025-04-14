import 'package:flutter/material.dart';

class SkillsDisplay extends StatelessWidget {
  final Color color;
  final String text; // Changed from Text to String for more control
  final double widthFactor;
  final double heightFactor;

  const SkillsDisplay({
    super.key,
    required this.color,
    required this.text,
    this.widthFactor = 0.3, // Default values
    this.heightFactor = 0.03,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final maxWidth = screenSize.width * widthFactor;
    final height = screenSize.height * heightFactor;

    return Container(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
        minWidth: 40, // Minimum width to prevent too small badges
      ),
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(height / 2), // Perfect pill shape
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: height * 0.5, // Responsive font size
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
