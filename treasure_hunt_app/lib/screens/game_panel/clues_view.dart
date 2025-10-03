// lib/screens/game_panel/clues_view.dart

// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:treasure_hunt_app/models/team_model.dart';
import 'package:treasure_hunt_app/screens/game_panel/quiz_screen.dart';

class CluesView extends StatelessWidget {
  final Team team;
  const CluesView({super.key, required this.team});

  DocumentReference get _levelsDocRef =>
      FirebaseFirestore.instance.collection('game_settings').doc('levels');

  // A reusable, highly styled button widget for displaying level status.
  Widget _buildLevelButton({
    required BuildContext context,
    required int levelNumber,
    required String levelName,
    required bool isUnlocked,
    required bool isCompleted,
    required VoidCallback onPressed,
  }) {
    bool isLocked = !isUnlocked;
    IconData iconData;
    Color buttonColor, borderColor, iconColor, textColor;
    String topText, bottomText;
    VoidCallback? finalOnPressed;

    if (isCompleted) {
      // Completed State Styling (Green)
      iconData = Icons.check_circle;
      buttonColor = const Color(0xFF1A7431);
      borderColor = Colors.greenAccent;
      iconColor = Colors.white;
      textColor = Colors.white;
      topText = 'LEVEL $levelNumber';
      bottomText = 'COMPLETED';
      finalOnPressed = () {
        final score = team.level1Submission?['score'] ?? 0;
        final total = team.level1Submission?['totalQuestions'] ?? 0;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'You completed this level with a score of $score/$total.',
            ),
          ),
        );
      };
    } else if (isLocked) {
      // Locked State Styling (Grey)
      iconData = Icons.lock;
      buttonColor = const Color(0xFF4A4A4A);
      borderColor = Colors.grey.shade600;
      iconColor = Colors.white.withOpacity(0.5);
      textColor = Colors.white.withOpacity(0.5);
      topText = 'LEVEL $levelNumber';
      bottomText = levelName.toUpperCase();
      finalOnPressed = null; // Button is disabled
    } else {
      // Unlocked State Styling (Amber/Gold)
      iconData = Icons.lock_open;
      buttonColor = Colors.amber.shade700;
      borderColor = Colors.amber;
      iconColor = Colors.white;
      textColor = Colors.white;
      topText = 'LEVEL $levelNumber';
      bottomText = levelName.toUpperCase();
      finalOnPressed = onPressed;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: borderColor, width: 2),
          ),
          disabledBackgroundColor: buttonColor,
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.5),
        ),
        onPressed: finalOnPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconData, color: iconColor, size: 24),
            const SizedBox(width: 12),
            Column(
              children: [
                Text(
                  topText,
                  style: GoogleFonts.cinzel(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  bottomText,
                  style: GoogleFonts.cinzel(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // The main layout is a Column to stack the heading and buttons.
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StreamBuilder<DocumentSnapshot>(
          stream: _levelsDocRef.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
            final isLevel1Unlocked = data['isLevel1Unlocked'] ?? false;
            final isLevel2Unlocked = data['isLevel2Unlocked'] ?? false;
            final isLevel3Unlocked = data['isLevel3Unlocked'] ?? false;

            final hasCompletedLevel1 = team.level1Submission != null;
            final hasCompletedLevel2 = false; // Placeholder
            final hasCompletedLevel3 = false; // Placeholder

            // The content is now wrapped in a Column to hold the heading and the level buttons.
            return Column(
              children: [
                // NEW: A beautiful, stylized heading for the dashboard.
                Text(
                  'Treasure Hunt Dashboard',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      // This creates the golden glow effect.
                      Shadow(
                        blurRadius: 15.0,
                        color: Colors.amber.withOpacity(0.7),
                      ),
                      Shadow(
                        blurRadius: 2.0,
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 25,
                ), // Spacing between heading and buttons
                // The level buttons remain the same.
                _buildLevelButton(
                  context: context,
                  levelNumber: 1,
                  levelName: 'Mind Spark',
                  isUnlocked: isLevel1Unlocked,
                  isCompleted: hasCompletedLevel1,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QuizScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 15),
                _buildLevelButton(
                  context: context,
                  levelNumber: 2,
                  levelName: 'Code Breaker',
                  isUnlocked: isLevel2Unlocked,
                  isCompleted: hasCompletedLevel2,
                  onPressed: () {
                    // TODO: Add navigation to Level 2
                  },
                ),
                const SizedBox(height: 15),
                _buildLevelButton(
                  context: context,
                  levelNumber: 3,
                  levelName: 'The Final Chase',
                  isUnlocked: isLevel3Unlocked,
                  isCompleted: hasCompletedLevel3,
                  onPressed: () {
                    // TODO: Add navigation to Level 3
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
