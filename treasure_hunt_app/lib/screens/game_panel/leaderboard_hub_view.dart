// ===============================
// FILE NAME: leaderboard_hub_view.dart
// FILE PATH: C:\treasurehunt\treasure_huntjo\treasure_hunt_app\lib\screens\game_panel\leaderboard_hub_view.dart
// ===============================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:treasure_hunt_app/screens/game_panel/level1_leaderboard_view.dart';
import 'package:treasure_hunt_app/screens/game_panel/level2_leaderboard_view.dart';

class LeaderboardHubView extends StatelessWidget {
  const LeaderboardHubView({super.key});

  // A reusable helper widget to create styled buttons for each leaderboard.
  Widget _buildLevelButton(
    BuildContext context,
    String title,
    Widget destinationPage,
    bool enabled,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled
              ? Colors.amber.shade700
              : Colors.grey.shade800,
          foregroundColor: enabled ? Colors.white : Colors.grey.shade500,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        // The button is only clickable if 'enabled' is true.
        onPressed: enabled
            ? () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => destinationPage),
              )
            : null,
        child: Text(
          title,
          style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Main title for the hub screen.
          Text(
            'Leaderboards',
            textAlign: TextAlign.center,
            style: GoogleFonts.cinzel(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 10,
                  color: Colors.amber.withAlpha((0.7 * 255).round()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Button to navigate to the Level 1 Leaderboard.
          _buildLevelButton(
            context,
            'Level 1 Leaderboard',
            const Level1LeaderboardView(),
            true, // Always enabled.
          ),

          // Button to navigate to the Level 2 Leaderboard.
          _buildLevelButton(
            context,
            'Level 2 Leaderboard',
            const Level2LeaderboardView(),
            true, // Now enabled.
          ),

          // Placeholder button for the future Level 3 Leaderboard.
          _buildLevelButton(
            context,
            'Level 3 Leaderboard',
            const Scaffold(body: Center(child: Text("Coming Soon!"))),
            false, // Currently disabled.
          ),
        ],
      ),
    );
  }
}
