import 'package:flutter/material.dart';

class VerticalWidgetSlider extends StatelessWidget {
  const VerticalWidgetSlider({super.key, required this.widgets});
  final List<Widget> widgets;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.30,
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: widgets.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
            child: widgets[index],
          );
        },
      ),
    );
  }
}
