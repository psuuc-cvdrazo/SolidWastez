import 'package:capstoneapp/screen/userside/form.dart';
import 'package:capstoneapp/screen/map.dart';
import 'package:capstoneapp/screen/userside/profile.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';


class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _selectedIndex = 1; 


  final List<Widget> _pages = [
    const FormScreen(),
    const MapScreen(),
    const UserProfileScreen(),                   
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],  
      bottomNavigationBar: CurvedNavigationBar(
        color: const Color(0xFF0A2A05),
        index: _selectedIndex,
        animationDuration: const Duration(milliseconds: 300),
        animationCurve: Curves.fastLinearToSlowEaseIn,
        buttonBackgroundColor: const Color(0xFF0A2A05),
        backgroundColor: Colors.transparent,
        items: [
          Icon(
            Icons.chat,
            color: _selectedIndex == 0 ? Colors.white : Colors.grey,
          ),
          Icon(
            Icons.map_rounded,
            color: _selectedIndex == 1 ? Colors.white : Colors.grey,
          ),
          Icon(
            Icons.person,
            color: _selectedIndex == 2 ? Colors.white : Colors.grey,
          ),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;  
          });
        },
      ),
    );
  }
}
