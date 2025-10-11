// ===============================
// FILE NAME: admin_dashboard.dart
// FILE PATH: C:\treasurehunt\treasure_huntjo\treasure_hunt_app\lib\screens\admin_dashboard.dart
// ===============================

import 'package:flutter/material.dart';
// FIX: Cleaned up and corrected the import statements to be consistent.
// This resolves both the 'ambiguous_import' and 'creation_with_non_type' errors.
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

  final List<IconData> _icons = const [
    Icons.groups_rounded,
    Icons.quiz_rounded,
    Icons.key_rounded,
    Icons.admin_panel_settings_rounded,
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
      // NEW: AppBar is now transparent to blend with the background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        // NEW: Dark gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF141E30), Color(0xFF243B55)],
          ),
        ),
        child: SafeArea(
          bottom:
              false, // SafeArea for top, but not bottom due to custom nav bar
          child: Column(
            children: [
              _buildHeaderCard(),
              Expanded(
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomAdminNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  // NEW: Header card with updated dark theme styling
  Widget _buildHeaderCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 8,
        // ignore: deprecated_member_use
        color: Colors.white.withOpacity(0.1),
        // ignore: deprecated_member_use
        shadowColor: Colors.black.withOpacity(0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.amber.withOpacity(0.4),
                      offset: const Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Icon(
                  _icons[_selectedIndex],
                  color: Colors.black,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _titles[_selectedIndex],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getSubtitle(_selectedIndex),
                      style: TextStyle(
                        fontSize: 14,
                        // ignore: deprecated_member_use
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getSubtitle(int index) {
    switch (index) {
      case 0:
        return 'Organize treasure hunting crews';
      case 1:
        return 'Create challenging adventures';
      case 2:
        return 'Design quest difficulty levels';
      case 3:
        return 'Manage your admin settings';
      default:
        return 'Control your treasure hunt';
    }
  }
}
