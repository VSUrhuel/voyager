import 'package:flutter/material.dart';

// Create a separate file named horizontal_widget_slider.dart
// (or any name you prefer) and paste the following code into it:

class HorizontalWidgetSliderMentor extends StatelessWidget {
  final List<Widget> widgets; // Make the list of widgets a parameter

  const HorizontalWidgetSliderMentor({super.key, required this.widgets});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      height: screenHeight * 0.45, // Or adjust as needed
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widgets.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: widgets[index],
          );
        },
      ),
    );
  }
}
