import 'package:flutter/material.dart';
// **NEW: Import the new single management view**
import 'package:treasure_hunt_app/screens/admin_panel/manage_teams_view.dart';
import 'package:treasure_hunt_app/screens/admin_panel/admin_profile_view.dart';
import 'package:treasure_hunt_app/widgets/custom_admin_nav_bar.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  // **UPDATED: The page list is now simpler**
  final List<Widget> _pages = [
    const ManageTeamsView(), // Index 0: Manage Teams (Pending & Approved)
    const Center(child: Text('Notifications (View 2)')), // Index 1: Placeholder
    const AdminProfileView(), // Index 2: Settings (Admin Profile)
  ];

  // **UPDATED: Titles list is also shorter**
  final List<String> _titles = const [
    'Manage Teams',
    'Notifications',
    'Admin Profile',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Text(_titles[_selectedIndex]),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.orange.shade50,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: CustomAdminNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
