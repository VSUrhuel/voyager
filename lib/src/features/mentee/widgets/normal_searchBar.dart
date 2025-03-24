import 'package:flutter/material.dart';

class NormalSearchbar extends StatelessWidget {
  const NormalSearchbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: 16.0), // Add padding for aesthetics
        decoration: BoxDecoration(
          color: Colors.white, // White background
          borderRadius: BorderRadius.circular(30.0), // Rounded corners
          border: Border.all(color: Colors.grey[300]!), // Light grey border
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  border: InputBorder.none, // Remove default underline
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 8.0), // Adjust vertical padding
                ),
                style: TextStyle(fontSize: 16.0), // Adjust font size as needed
              ),
            ),
            Icon(
              Icons.search,
              color: Colors.grey[600], // Grey search icon
            ),
          ],
        ),
      ),
    );
  }
}
