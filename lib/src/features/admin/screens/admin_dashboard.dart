import 'package:flutter/material.dart';
import 'package:voyager/src/features/admin/screens/home/admin_home.dart';
import 'package:voyager/src/features/admin/screens/profile/admin_profile.dart';
import 'package:voyager/src/widgets/admin_bottom_nav_bar.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key, this.index = 0});
  final int index;
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late int _selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.index;
  }

  final List<Widget> _screens = [
    AdminHome(),
    AdminProfile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: AdminBottomNavBar(
          currentIndex: _selectedIndex,
          onTabChange: _onItemTapped,
        ),
      ),
    );
  }
}
