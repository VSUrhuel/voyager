import 'package:flutter/material.dart';

class ToggleButtonIcons extends StatefulWidget {
  const ToggleButtonIcons({super.key});

  @override
  State<ToggleButtonIcons> createState() => _ToggleButtonIconsState();
}

class _ToggleButtonIconsState extends State<ToggleButtonIcons> {
  int _selectedIndex = 0; // 0 for Announcement, 1 for Resources
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Center(
        child: Container(
      width: screenWidth * 0.9,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.transparent, // No background for outer container
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Announcement Button
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = 0;
              });
            },
            child: Container(
              width: (screenWidth * 0.9) / 2,
              height: 50,
              decoration: BoxDecoration(
                color: _selectedIndex == 0 ? Colors.grey[300] : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.campaign, color: Colors.black54),
                  SizedBox(width: 5),
                  Text(
                    "Announcement",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          // Resources Button
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = 1;
              });
            },
            child: Container(
              width: (screenWidth * 0.9) / 2,
              height: 50,
              decoration: BoxDecoration(
                color: _selectedIndex == 1 ? Colors.grey[300] : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.grid_view, color: Colors.black54),
                  SizedBox(width: 5),
                  Text(
                    "Resources",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
