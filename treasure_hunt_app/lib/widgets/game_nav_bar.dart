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
      // The bar's background
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(120), // Semi-transparent black
        border: Border(
          top: BorderSide(
            color: Colors.brown.shade200.withAlpha(150), // A light "stone edge" color
            width: 2.0,
          ),
        ),
      ),
      height: 70, // A bit taller for a more prominent feel
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.lightbulb_outline, 'Clues', 0),
          _buildNavItem(Icons.map_outlined, 'Map', 1),
          _buildNavItem(Icons.backpack_outlined, 'Inventory', 2),
          _buildNavItem(Icons.people_outline, 'Team', 3),
        ],
      ),
    );
  }

  // Helper method to build each navigation item
  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = selectedIndex == index;
    final Color color = isSelected ? Colors.orange.shade300 : Colors.brown.shade200;

    return InkWell(
      onTap: () => onItemTapped(index),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Glowing effect for the selected icon
            Icon(
              icon,
              color: color,
              size: 28,
              shadows: isSelected
                  ? [
                      Shadow(
                        color: Colors.orange.shade300,
                        blurRadius: 15.0,
                      ),
                      Shadow(
                        color: Colors.orange.shade300,
                        blurRadius: 25.0,
                      ),
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