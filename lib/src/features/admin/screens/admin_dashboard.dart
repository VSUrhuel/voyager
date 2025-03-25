

import 'package:flutter/material.dart';
import 'package:voyager/src/features/admin/screens/home/admin_home.dart';
// import 'package:voyager/src/features/admin/screens/mentors/mentor_list.dart';
import 'package:voyager/src/widgets/admin_bottom_nav_bar.dart';
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {

int _selectedIndex = 0;
final List<Widget> _screens = [
  AdminHome(),

];

void _onItemTapped(int index){
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
      bottomNavigationBar: AdminBottomNavBar(
        currentIndex: _selectedIndex,
        onTabChange: _onItemTapped,
      ),
    );
  }
}



