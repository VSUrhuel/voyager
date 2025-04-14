import 'package:voyager/src/features/mentor/screens/session/calendar.dart';
import 'package:voyager/src/features/mentor/widget/toggle_button.dart';
import 'package:voyager/src/widgets/custom_page_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Session extends StatelessWidget {
  const Session({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        toolbarHeight: screenHeight * 0.10,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: screenWidth * 0.06,
          fontWeight: FontWeight.bold,
        ),
        elevation: 0, // No shadow
        title: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  top: screenHeight * 0.013,
                  left: screenHeight * 0.01), // Add padding to the left
              child: Text(
                'My Sessions',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: screenWidth * 0.07, // Adjust font size as needed
                  fontWeight: FontWeight.bold, // Bold
                ),
              ),
            ),
            SizedBox(width: 16), // Spacing between image and text
          ],
        ),
        actions: [
          Padding(
            padding:
                const EdgeInsets.only(right: 16.0), // Add padding to the right
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                ),
                child: Icon(Icons.calendar_month,
                    color: Theme.of(context).primaryColor,
                    size: screenWidth * 0.069),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  CustomPageRoute(page: CalendarView()),
                );
                // Handle notification tap
              },
            ),
          ),
        ],
      ),
      body: Center(
          child: Padding(
              padding: EdgeInsets.only(
                  left: screenWidth * 0.06,
                  right: screenWidth * 0.05,
                  top: screenHeight * 0.00),
              child: Column(children: [
                ToggleButton(),
              ]))),
    );
  }
}
