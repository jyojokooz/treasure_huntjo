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

  final List<IconData> _icons = const [
    Icons.groups_rounded,
    Icons.quiz_rounded,
    Icons.emoji_events_rounded,
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
    // Applying the custom theme to the entire dashboard
    return Theme(
      data: _buildTreasureHuntTheme(context),
      child: Scaffold(
        extendBody: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: _buildCustomAppBar(),
        ),
        body: Container(
          decoration: _buildBackgroundDecoration(),
          child: Column(
            children: [
              _buildHeaderCard(),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    // Wrap each page to give it a consistent card-like appearance
                    children: _pages
                        .map((page) => _buildPageWrapper(page))
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 100), // Space for the floating nav bar
            ],
          ),
        ),
        bottomNavigationBar: CustomAdminNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }

  // --- THEME AND WIDGET BUILDER METHODS ---

  ThemeData _buildTreasureHuntTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: const Color(0xFFD68511), // Treasure gold
            brightness: Brightness.light,
          ).copyWith(
            primary: const Color(0xFFD68511),
            secondary: const Color(0xFF8B4513),
            tertiary: const Color(0xFFFFD700),
            surface: const Color(0xFFF5F3F0),
            // FIX: Removed deprecated 'surfaceVariant'
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: const Color(0xFF2C1810),
            outline: const Color(0xFFA0522D),
          ),
      // FIX: Changed CardTheme to CardThemeData
      cardTheme: CardThemeData(
        elevation: 8,
        // FIX: Replaced deprecated withOpacity
        shadowColor: Colors.black.withAlpha((0.3 * 255).round()),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 4,
          // FIX: Replaced deprecated withOpacity
          shadowColor: Colors.black.withAlpha((0.3 * 255).round()),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD68511), Color(0xFFB8860B), Color(0xFF8B4513)],
        ),
        boxShadow: [
          BoxShadow(
            // FIX: Replaced deprecated withOpacity
            color: Colors.black.withAlpha((0.2 * 255).round()),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  // FIX: Replaced deprecated withOpacity
                  color: Colors.white.withAlpha((0.2 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.diamond_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Treasure Hunt',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Admin Command Center',
                      style: TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  // FIX: Replaced deprecated withOpacity
                  color: Colors.white.withAlpha((0.2 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 12,
        // FIX: Replaced deprecated withOpacity
        shadowColor: const Color(0xFF8B4513).withAlpha((0.3 * 255).round()),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFF8DC), Color(0xFFFFE4B5)],
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFD68511),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      // FIX: Replaced deprecated withOpacity
                      color: const Color(
                        0xFFD68511,
                      ).withAlpha((0.3 * 255).round()),
                      offset: const Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Icon(
                  _icons[_selectedIndex],
                  color: Colors.white,
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
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C1810),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getSubtitle(_selectedIndex),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8B4513),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  // FIX: Replaced deprecated withOpacity
                  color: const Color(0xFFFFD700).withAlpha((0.2 * 255).round()),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFD700), width: 1),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFFD700),
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Admin',
                      style: TextStyle(
                        color: Color(0xFF8B4513),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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

  BoxDecoration _buildBackgroundDecoration() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFF8DC), Color(0xFFF5F3F0), Color(0xFFE8E0D6)],
      ),
    );
  }

  Widget _buildPageWrapper(Widget page) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        elevation: 8,
        // FIX: Replaced deprecated withOpacity
        shadowColor: const Color(0xFF8B4513).withAlpha((0.2 * 255).round()),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                // FIX: Replaced deprecated withOpacity
                const Color(0xFFFFF8DC).withAlpha((0.5 * 255).round()),
              ],
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: page,
          ),
        ),
      ),
    );
  }
}
