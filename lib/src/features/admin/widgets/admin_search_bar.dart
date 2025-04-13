import 'package:flutter/material.dart';

class AdminSearchbar extends StatelessWidget {
  final ValueChanged<String> onSearchChanged;
  const AdminSearchbar({
    super.key,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal:
            screenWidth * 0.04, // Responsive side padding (4% of screen width)
        vertical: 12.0, // Consistent vertical padding
      ),
      child: Container(
        height: screenHeight * 0.06, // Slightly reduced for better proportions
        padding: EdgeInsets.symmetric(
            horizontal: 16.0), // Inner padding for text field
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.0),
          border: Border.all(color: Colors.grey[300]!), // Light grey border
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(
                    left: screenWidth * 0.02, // Responsive left padding
                    // Precise vertical alignment
                    bottom: screenHeight * 0.0, // Centers text vertically
                  ),
                  hintStyle: TextStyle(color: Colors.grey[500]),
                ),
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.search,
              color: Colors.grey[600],
              size: 24.0, // Standardized icon size
            ),
          ],
        ),
      ),
    );
  }
}
