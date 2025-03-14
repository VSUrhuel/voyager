import 'package:flutter/material.dart';

class DividerWithText extends StatelessWidget {
  final double screenWidth;

  const DividerWithText({super.key, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Divider(
          thickness: 1,
          color: Color(0xFF455A64),
        ),
        Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'or',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: screenWidth * 0.04,
                  color: Color(0xFF455A64),
                ),
          ),
        ),
      ],
    );
  }
}
