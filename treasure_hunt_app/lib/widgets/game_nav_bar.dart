// ===============================
// FILE NAME: game_nav_bar.dart
// FILE PATH: C:\treasurehunt\treasure_huntjo\treasure_hunt_app\lib\widgets\game_nav_bar.dart
// ===============================

import 'package:flutter/material.dart';

class GameNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const GameNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(120),
        border: Border(
          top: BorderSide(
            color: Colors.brown.shade200.withAlpha(150),
            width: 2.0,
          ),
        ),
      ),
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // THE FIX: The order of indices has changed now that "Map" is gone.
          _buildNavItem(Icons.lightbulb_outline, 'Clues', 0),
          _buildNavItem(
            Icons.leaderboard_outlined,
            'Scores',
            1,
          ), // Renamed for clarity
          _buildNavItem(Icons.people_outline, 'Team', 2),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = selectedIndex == index;
    final Color color = isSelected
        ? Colors.orange.shade300
        : Colors.brown.shade200;

    return InkWell(
      onTap: () => onItemTapped(index),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
              shadows: isSelected
                  ? [
                      Shadow(color: Colors.orange.shade300, blurRadius: 15.0),
                      Shadow(color: Colors.orange.shade300, blurRadius: 25.0),
                    ]
                  : [],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
