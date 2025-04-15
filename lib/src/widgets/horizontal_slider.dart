import 'package:flutter/material.dart';

// Create a separate file named horizontal_widget_slider.dart
// (or any name you prefer) and paste the following code into it:
class HorizontalWidgetSlider extends StatelessWidget {
  final List<Widget> widgets;

  const HorizontalWidgetSlider({super.key, required this.widgets});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.47, // Set explicit height
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widgets.length,
        itemBuilder: (context, index) {
          return SizedBox(
            width: MediaQuery.of(context).size.width * 0.85, // Card width
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: widgets[index],
            ),
          );
        },
      ),
    );
  }
}
