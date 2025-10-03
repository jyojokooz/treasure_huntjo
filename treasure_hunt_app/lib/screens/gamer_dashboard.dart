import 'package:flutter/material.dart';
import 'package:treasure_hunt_app/models/team_model.dart';
import 'package:treasure_hunt_app/screens/game_panel/clues_view.dart';
import 'package:treasure_hunt_app/screens/game_panel/leaderboard_view.dart';
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
  // It's declared as 'late final' because it's initialized in initState.
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Initialize the list of pages here. This is done in initState so we can
    // access `widget.team` and pass the team data to the relevant child widgets.
    _pages = [
      // The CluesView needs team data to check for quiz completion status.
      CluesView(team: widget.team), // Index 0
      // Placeholder for the Map view.
      const Center(
        child: Text(
          'Map View - Coming Soon!',
          style: TextStyle(color: Colors.white70),
        ),
      ), // Index 1
      // The LeaderboardView shows rankings for all teams.
      const LeaderboardView(), // Index 2
      // The TeamView needs team data to display member names, college, etc.
      TeamView(team: widget.team), // Index 3
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
          // Padding is carefully calculated to position the content
          // perfectly inside the transparent area of the frame image.
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
                  // IndexedStack is efficient for bottom navigation. It keeps all
                  // pages in the widget tree but only shows the one at the current index.
                  // This preserves the state of each page when switching tabs.
                  child: IndexedStack(index: _selectedIndex, children: _pages),
                ),
                // The forfeit button remains fixed at the bottom of the frame.
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
