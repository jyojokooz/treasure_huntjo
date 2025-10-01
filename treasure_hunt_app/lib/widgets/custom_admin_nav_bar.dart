import 'package:flutter/material.dart';

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
    final Color selectedColor = Colors.orange.shade300;
    const Color iconColor = Colors.black87;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // UPDATED: Now there are 4 items to match the AdminDashboard pages.
          _buildNavItem(
            Icons.group_work_outlined, // Icon for Manage Teams
            0,
            selectedColor,
            iconColor,
          ),
          // NEW: Item for Manage Quizzes
          _buildNavItem(
            Icons.quiz_outlined, // Icon for Manage Quizzes
            1,
            selectedColor,
            iconColor,
          ),
          // NEW: Item for Manage Levels
          _buildNavItem(
            Icons.key_outlined, // Icon for Manage Levels
            2,
            selectedColor,
            iconColor,
          ),
          // UPDATED: Profile is now at index 3
          _buildNavItem(
            Icons.settings_outlined, // Icon for Profile
            3,
            selectedColor,
            iconColor,
          ),
        ],
      ),
    );
  }

  // Helper method to build each item
  Widget _buildNavItem(
    IconData icon,
    int index,
    Color selectedColor,
    Color iconColor,
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
            // Animated circle for the selected item
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              width: isSelected ? 50 : 0,
              height: isSelected ? 50 : 0,
              decoration: BoxDecoration(
                color: selectedColor,
                shape: BoxShape.circle,
              ),
            ),
            Icon(icon, size: 28, color: iconColor),
          ],
        ),
      ),
    );
  }
}
