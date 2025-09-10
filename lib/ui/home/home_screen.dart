import 'package:flutter/material.dart';
import '../scan/scan_screen.dart';
import '../profile/profile_screen.dart';
import 'package:skincare_app/ui/recommendations/recommendations_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    Center(child: Text("Dashboard / Home", style: TextStyle(fontSize: 22))),
    ScanScreen(),
    RecommendationsTab(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // important for 4+ items
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: "Scan",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: "Recommendations",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
