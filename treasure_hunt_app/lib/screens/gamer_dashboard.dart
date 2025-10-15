// ===============================
// FILE NAME: gamer_dashboard.dart
// FILE PATH: C:\treasurehunt\treasure_huntjo\treasure_hunt_app\lib\screens\gamer_dashboard.dart
// ===============================

import 'package:flutter/material.dart';
import 'package:treasure_hunt_app/models/team_model.dart';
import 'package:treasure_hunt_app/screens/game_panel/clues_view.dart';
import 'package:treasure_hunt_app/screens/game_panel/leaderboard_hub_view.dart';
import 'package:treasure_hunt_app/screens/game_panel/team_view.dart';
import 'package:treasure_hunt_app/services/auth_service.dart';
import 'package:treasure_hunt_app/widgets/game_nav_bar.dart';

class GamerDashboard extends StatefulWidget {
  final Team team;
  const GamerDashboard({super.key, required this.team});

  @override
  State<GamerDashboard> createState() => _GamerDashboardState();
}

class _GamerDashboardState extends State<GamerDashboard> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // THE FIX: Removed the "Map" view from the list of pages.
    _pages = [
      CluesView(team: widget.team),
      const LeaderboardHubView(),
      TeamView(team: widget.team),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AuthService auth = AuthService();

    return Scaffold(
      extendBody: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      extendBodyBehindAppBar: true,
      bottomNavigationBar: GameNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/dashboard_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                Expanded(
                  child: IndexedStack(index: _selectedIndex, children: _pages),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 100.0),
                  child: TextButton.icon(
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
