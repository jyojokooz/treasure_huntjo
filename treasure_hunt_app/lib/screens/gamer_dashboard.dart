import 'package:flutter/material.dart';
import 'package:treasure_hunt_app/models/team_model.dart';
import 'package:treasure_hunt_app/screens/game_panel/clues_view.dart';
// Import the new shared leaderboard view from its correct location.
import 'package:treasure_hunt_app/screens/game_panel/level1_leaderboard_view.dart';
import 'package:treasure_hunt_app/screens/game_panel/team_view.dart';
import 'package:treasure_hunt_app/services/auth_service.dart';
import 'package:treasure_hunt_app/widgets/game_nav_bar.dart';

class GamerDashboard extends StatefulWidget {
  // This dashboard requires the team's data to function correctly.
  final Team team;
  const GamerDashboard({super.key, required this.team});

  @override
  State<GamerDashboard> createState() => _GamerDashboardState();
}

class _GamerDashboardState extends State<GamerDashboard> {
  // Tracks the currently selected tab in the bottom navigation bar.
  int _selectedIndex = 0;

  // A list of all the different pages/views the user can switch between.
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Initialize the list of pages here to pass the required 'team' data.
    _pages = [
      // Index 0: The CluesView, which needs team data to check submission status.
      CluesView(team: widget.team),

      // Index 1: Placeholder for the Map view.
      const Center(
        child: Text(
          'Map View - Coming Soon!',
          style: TextStyle(color: Colors.white70),
        ),
      ),

      // Index 2: The new shared leaderboard. We explicitly pass 'isAdminView: false'
      // to ensure the player does not see the "Reset Leaderboard" button.
      const Level1LeaderboardView(isAdminView: false),

      // Index 3: The TeamView, which needs team data to display member names, etc.
      TeamView(team: widget.team),
    ];
  }

  // This function is called when a navigation bar item is tapped.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AuthService auth = AuthService();
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      // Allows the body to extend behind the semi-transparent navigation bar.
      extendBody: true,
      bottomNavigationBar: GameNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      body: Container(
        // Sets the main background frame for the dashboard.
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/dashboard_frame.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          // Padding is calculated to position the content inside the frame.
          child: Padding(
            padding: EdgeInsets.only(
              top: screenSize.height * 0.22,
              bottom: screenSize.height * 0.08,
              left: screenSize.width * 0.12,
              right: screenSize.width * 0.12,
            ),
            child: Column(
              children: [
                // The main content area that switches between pages.
                Expanded(
                  // IndexedStack efficiently manages the state of each tab.
                  child: IndexedStack(index: _selectedIndex, children: _pages),
                ),
                // The "Forfeit" button at the bottom.
                TextButton.icon(
                  icon: Icon(Icons.exit_to_app, color: Colors.red.shade300),
                  label: Text(
                    'Forfeit',
                    style: TextStyle(
                      color: Colors.red.shade300,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onPressed: () => auth.signOut(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
