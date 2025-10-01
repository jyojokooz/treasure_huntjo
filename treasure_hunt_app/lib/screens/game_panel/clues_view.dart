import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CluesView extends StatelessWidget {
  // This view is now self-contained and no longer needs the 'team' object passed to it.
  const CluesView({super.key});

  // A private getter to easily reference the single global document
  // that controls the lock status for all levels.
  DocumentReference get _levelsDocRef =>
      FirebaseFirestore.instance.collection('game_settings').doc('levels');

  @override
  Widget build(BuildContext context) {
    // The entire view is wrapped in a StreamBuilder. This widget listens for
    // real-time changes to our global 'levels' document in Firestore.
    // If an admin unlocks a level, this stream will get the new data, and the
    // UI will automatically rebuild to show the unlocked state.
    return StreamBuilder<DocumentSnapshot>(
      stream: _levelsDocRef.snapshots(),
      builder: (context, snapshot) {
        // Show a loading indicator while fetching the initial data.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Handle potential errors, such as permission issues.
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading game state.'));
        }

        // Safely access the data. If the 'levels' document doesn't exist yet,
        // we default to an empty map to avoid null errors.
        final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};

        // Read the boolean lock status for each level from the data.
        // If a field doesn't exist in the document, we default to 'false' (locked).
        final isLevel1Unlocked = data['isLevel1Unlocked'] ?? false;
        final isLevel2Unlocked = data['isLevel2Unlocked'] ?? false;
        final isLevel3Unlocked = data['isLevel3Unlocked'] ?? false;

        return Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Build the button for Level 1, passing in its global lock status.
                _buildLevelButton(
                  context: context,
                  levelNumber: 1,
                  levelName: 'Mind Spark',
                  isUnlocked: isLevel1Unlocked,
                  onPressed: () {
                    debugPrint('Navigating to Level 1...');
                    // TODO: Add navigation to the Level 1 screen.
                  },
                ),
                // Build the button for Level 2.
                _buildLevelButton(
                  context: context,
                  levelNumber: 2,
                  levelName: 'Code Breaker',
                  isUnlocked: isLevel2Unlocked,
                  onPressed: () {
                    debugPrint('Navigating to Level 2...');
                    // TODO: Add navigation to the Level 2 screen.
                  },
                ),
                // Build the button for Level 3.
                _buildLevelButton(
                  context: context,
                  levelNumber: 3,
                  levelName: 'The Final Chase',
                  isUnlocked: isLevel3Unlocked,
                  onPressed: () {
                    debugPrint('Navigating to Level 3...');
                    // TODO: Add navigation to the Level 3 screen.
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // This reusable helper widget builds a styled button for a single level.
  // Its appearance (color, icon, enabled/disabled state) is determined by the
  // 'isUnlocked' boolean passed to it.
  Widget _buildLevelButton({
    required BuildContext context,
    required int levelNumber,
    required String levelName,
    required bool isUnlocked,
    required VoidCallback onPressed,
  }) {
    final bool isLocked = !isUnlocked;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        icon: Icon(
          isLocked ? Icons.lock_outline : Icons.lock_open_outlined,
          color: isLocked ? Colors.white54 : Colors.white,
        ),
        label: Column(
          children: [
            Text(
              'Level $levelNumber',
              style: GoogleFonts.cinzel(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: isLocked ? Colors.white54 : Colors.white,
              ),
            ),
            Text(
              levelName,
              style: GoogleFonts.cinzel(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isLocked ? Colors.white54 : Colors.white,
              ),
            ),
          ],
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isLocked
              ? Colors.grey.shade800.withAlpha(200)
              : Colors.orange.shade800.withAlpha(220),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isLocked ? Colors.grey.shade600 : Colors.orange.shade300,
              width: 2,
            ),
          ),
          disabledBackgroundColor: Colors.grey.shade800.withAlpha(200),
          disabledForegroundColor: Colors.white54,
        ),
        onPressed: isLocked ? null : onPressed,
      ),
    );
  }
}
