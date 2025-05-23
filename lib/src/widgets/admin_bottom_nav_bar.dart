import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class AdminBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabChange;
  final List<GButton> tabs;

  const AdminBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabChange,
    this.tabs = const [
      GButton(
        icon: Icons.home,
        text: 'Home',
      ),
      GButton(
        icon: Icons.person, 
        text: 'Profile',
      ),
    ],
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      color: Colors.black,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.2, 
          vertical: screenWidth * 0.00,
        ),
        child: GNav(
          gap: screenWidth * 0.05,
          backgroundColor: Colors.black,
          color: Colors.white,
          activeColor: Colors.white,
          tabBackgroundColor: const Color(0xFF1877F2),
          tabBorderRadius: 15,
          padding: EdgeInsets.all(screenWidth * 0.04),
          selectedIndex: currentIndex,  
          onTabChange: onTabChange,    
          tabs: tabs,
        ),
      ),
    );
  }
}