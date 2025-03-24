import 'package:voyager/src/features/mentor/screens/profile/mentor_profile.dart';
import 'package:voyager/src/features/mentor/screens/session/session.dart';
import 'package:flutter/material.dart';
import 'package:voyager/src/features/mentor/screens/home/mentor_home.dart';
import 'package:voyager/src/widgets/bottom_nav_bar_mentor.dart';
import 'package:voyager/src/features/mentor/screens/post/post.dart';

class MentorDashboard extends StatefulWidget {
  const MentorDashboard({super.key});

  @override
  State<MentorDashboard> createState() => _MentorDashboardState();
}

class _MentorDashboardState extends State<MentorDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    MentorHome(),
    Post(),
    Session(),
    MentorProfile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavBarMentor(
        currentIndex: _selectedIndex,
        onTabChange: _onItemTapped,
      ),
    );
  }
}
