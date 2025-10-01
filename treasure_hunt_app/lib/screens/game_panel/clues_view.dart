// lib/screens/game_panel/clues_view.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:treasure_hunt_app/screens/game_panel/quiz_screen.dart'; // Import the quiz screen

class CluesView extends StatelessWidget {
  const CluesView({super.key});

  DocumentReference get _levelsDocRef =>
      FirebaseFirestore.instance.collection('game_settings').doc('levels');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _levelsDocRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading game state.'));
        }

        final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
        final isLevel1Unlocked = data['isLevel1Unlocked'] ?? false;
        final isLevel2Unlocked = data['isLevel2Unlocked'] ?? false;
        final isLevel3Unlocked = data['isLevel3Unlocked'] ?? false;

        return Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLevelButton(
                  context: context,
                  levelNumber: 1,
                  levelName: 'Mind Spark',
                  isUnlocked: isLevel1Unlocked,
                  onPressed: () {
                    debugPrint('Navigating to Level 1...');
                    // This is the navigation to the quiz screen.
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QuizScreen(),
                      ),
                    );
                  },
                ),
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
