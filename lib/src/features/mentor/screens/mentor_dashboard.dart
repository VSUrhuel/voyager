import 'package:flutter/material.dart';
import 'package:voyager/src/features/mentor/screens/profile/mentor_profile.dart';
import 'package:voyager/src/features/mentor/screens/session/session.dart';
import 'package:voyager/src/features/mentor/screens/home/mentor_home.dart';
import 'package:voyager/src/widgets/bottom_nav_bar_mentor.dart';
import 'package:voyager/src/features/mentor/screens/post/post.dart';

class MentorDashboard extends StatefulWidget {
  const MentorDashboard(
      {super.key, this.index = 0 // Default value of 0 if not provided
      });
  final int index;

  @override
  State<MentorDashboard> createState() => _MentorDashboardState();
}

class _MentorDashboardState extends State<MentorDashboard> {
  late int _selectedIndex; // Will be initialized in initState

  final List<Widget> _screens = const [
    MentorHome(),
    Post(),
    Session(),
    MentorProfile(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.index; // Initialize with passed index or default 0
  }

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
