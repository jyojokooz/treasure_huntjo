import 'package:flutter/material.dart';
import 'package:treasure_hunt_app/models/team_model.dart';
import 'package:treasure_hunt_app/screens/game_panel/clues_view.dart';
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
    _pages = [
      // FIX: Removed the 'team' parameter from CluesView() since it no longer needs it.
      const CluesView(), // Index 0

      const Center(
        child: Text(
          'Map View - Coming Soon!',
          style: TextStyle(color: Colors.white70),
        ),
      ), // Index 1

      const Center(
        child: Text(
          'Inventory - Coming Soon!',
          style: TextStyle(color: Colors.white70),
        ),
      ), // Index 2
      // TeamView still needs the team data to display member info.
      TeamView(team: widget.team), // Index 3
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
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: GameNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/dashboard_frame.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              top: screenSize.height * 0.22,
              bottom: screenSize.height * 0.08,
              left: screenSize.width * 0.12,
              right: screenSize.width * 0.12,
            ),
            child: Column(
              children: [
                Expanded(
                  child: IndexedStack(index: _selectedIndex, children: _pages),
                ),
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
