import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class BottomNavBarMentor extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabChange;

  const BottomNavBarMentor({
    super.key,
    required this.currentIndex,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      color: Colors.black,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: GNav(
          gap: screenWidth * 0.03,
          backgroundColor: Colors.black,
          color: Colors.white,
          activeColor: Colors.white,
          tabBackgroundColor: Color(0xFF1877F2),
          tabBorderRadius: 15,
          padding: EdgeInsets.all(screenWidth * 0.04),
          selectedIndex: currentIndex,
          onTabChange: onTabChange,
          tabs: const [
            GButton(icon: Icons.home, text: 'Home'),
            GButton(icon: Icons.campaign, text: 'Post'),
            GButton(icon: Icons.calendar_month, text: 'Session'),
            GButton(icon: Icons.person, text: 'Profile'),
          ],
        ),
      ),
    );
  }
}
