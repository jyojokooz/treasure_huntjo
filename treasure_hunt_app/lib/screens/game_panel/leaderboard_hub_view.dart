// lib/screens/game_panel/leaderboard_hub_view.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:treasure_hunt_app/screens/game_panel/level_leaderboard_view.dart';

class LeaderboardHubView extends StatelessWidget {
  const LeaderboardHubView({super.key});

  Widget _buildLevelButton(
    BuildContext context,
    String title,
    String levelId,
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
        onPressed: enabled
            ? () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LevelLeaderboardView(levelId: levelId),
                ),
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
          Text(
            'Leaderboards',
            textAlign: TextAlign.center,
            style: GoogleFonts.cinzel(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              // FIX: Replaced deprecated withOpacity
              shadows: [
                Shadow(
                  blurRadius: 10,
                  color: Colors.amber.withAlpha((0.7 * 255).round()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          _buildLevelButton(context, 'Level 1 Leaderboard', 'level1', true),
          _buildLevelButton(context, 'Level 2 Leaderboard', 'level2', false),
          _buildLevelButton(context, 'Level 3 Leaderboard', 'level3', false),
        ],
      ),
    );
  }
}
