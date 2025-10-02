// lib/screens/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'admin_panel/admin_profile_view.dart';
import 'admin_panel/manage_levels_view.dart';
import 'admin_panel/manage_quizzes_view.dart';
import 'admin_panel/manage_teams_view.dart';
import '../widgets/custom_admin_nav_bar.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    const ManageTeamsView(),
    const ManageQuizzesView(),
    const ManageLevelsView(),
    const AdminProfileView(),
  ];

  final List<String> _titles = const [
    'Manage Teams',
    'Manage Quizzes',
    'Manage Levels',
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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/admin_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: _pages,
        ),
      ),
      bottomNavigationBar: CustomAdminNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
