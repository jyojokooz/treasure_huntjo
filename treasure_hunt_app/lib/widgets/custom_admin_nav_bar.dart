import 'package:flutter/material.dart';
import 'dart:ui'; // Needed for BackdropFilter

class CustomAdminNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomAdminNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    // NEW: Define colors for the dark theme
    final Color selectedColor = Colors.amber;
    // ignore: deprecated_member_use
    final Color unselectedIconColor = Colors.white.withOpacity(0.7);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      // Use a ClipRRect to enable the blur effect
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          // NEW: Frosted glass effect
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            height: 65,
            decoration: BoxDecoration(
              // NEW: Semi-transparent color for the glass effect
              // ignore: deprecated_member_use
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
              // ignore: deprecated_member_use
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  Icons.groups_outlined,
                  0,
                  selectedColor,
                  unselectedIconColor,
                ),
                _buildNavItem(
                  Icons.quiz_outlined,
                  1,
                  selectedColor,
                  unselectedIconColor,
                ),
                _buildNavItem(
                  Icons.key_outlined,
                  2,
                  selectedColor,
                  unselectedIconColor,
                ),
                _buildNavItem(
                  Icons.settings_outlined,
                  3,
                  selectedColor,
                  unselectedIconColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    int index,
    Color selectedColor,
    Color unselectedIconColor,
  ) {
    bool isSelected = selectedIndex == index;

    return InkWell(
      onTap: () => onItemTapped(index),
      borderRadius: BorderRadius.circular(30),
      child: SizedBox(
        width: 60,
        height: 60,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              width: isSelected ? 45 : 0,
              height: isSelected ? 45 : 0,
              decoration: BoxDecoration(
                color: selectedColor,
                shape: BoxShape.circle,
              ),
            ),
            // NEW: Icon color changes based on selection
            Icon(
              icon,
              size: 28,
              color: isSelected ? Colors.black : unselectedIconColor,
            ),
          ],
        ),
      ),
    );
  }
}
