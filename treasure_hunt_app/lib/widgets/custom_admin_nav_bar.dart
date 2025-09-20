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
          // We now have 3 items
          _buildNavItem(
            Icons.group_work_outlined,
            0,
            selectedColor,
          ), // Manage Teams
          _buildNavItem(
            Icons.notifications_none_outlined,
            1,
            selectedColor,
          ), // Notifications
          _buildNavItem(Icons.settings_outlined, 2, selectedColor), // Profile
        ],
      ),
    );
  }

  // Helper method to build each item
  Widget _buildNavItem(IconData icon, int index, Color selectedColor) {
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
            if (isSelected)
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: selectedColor,
                  shape: BoxShape.circle,
                ),
              ),
            Icon(icon, size: 28, color: Colors.black87),
          ],
        ),
      ),
    );
  }
}
