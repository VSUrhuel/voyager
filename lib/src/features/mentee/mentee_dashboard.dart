import 'package:voyager/src/features/mentee/screens/home/mentee_home.dart';
import 'package:voyager/src/features/mentee/screens/profile/mentee_profile.dart';
import 'package:voyager/src/widgets/bottom_nav_bar_mentor.dart';
import 'package:flutter/material.dart';

class MenteeDashboard extends StatefulWidget {
  const MenteeDashboard({super.key});

  @override
  State<MenteeDashboard> createState() => _MenteeDashboardState();
}

class _MenteeDashboardState extends State<MenteeDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    MenteeHome(),
    Scaffold(body: Center(child: Text('Post Page'))),
    Scaffold(body: Center(child: Text('Session Page'))),
    MenteeProfile(),
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
