import 'package:flutter/material.dart';

class SkillsDisplay extends StatelessWidget {
  final Color color;
  final String text;
  final bool isPrimary;
  final double widthFactor;
  final double heightFactor;

  const SkillsDisplay({
    required this.color,
    required this.text,
    this.isPrimary = false,
    this.widthFactor = 0.4,
    this.heightFactor = 0.035,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isPrimary ? color : color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        // border: isPrimary
        //     ? Border.all(color: color.withOpacity(0.0), width: 0)
        //     : Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: screenSize.width * 0.032,
          fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
          color: isPrimary ? Colors.white : color,
        ),
      ),
    );
  }
}
