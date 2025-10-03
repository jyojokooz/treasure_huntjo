import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:treasure_hunt_app/models/team_model.dart';
import 'package:treasure_hunt_app/screens/game_panel/quiz_screen.dart';

class CluesView extends StatelessWidget {
  // We need the team data to check for previous submissions.
  final Team team;
  const CluesView({super.key, required this.team});

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
        final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
        final isLevel1Unlocked = data['isLevel1Unlocked'] ?? false;
        final isLevel2Unlocked = data['isLevel2Unlocked'] ?? false;
        final isLevel3Unlocked = data['isLevel3Unlocked'] ?? false;

        // NEW: Check if the team has already completed Level 1.
        final bool hasCompletedLevel1 = team.level1Submission != null;

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
                  // NEW: Pass the completion status to the button builder.
                  isCompleted: hasCompletedLevel1,
                  onPressed: () {
                    // This logic now only runs if the level is not completed.
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QuizScreen(),
                      ),
                    );
                  },
                ),
                // Other levels remain the same for now
                _buildLevelButton(
                  context: context,
                  levelNumber: 2,
                  levelName: 'Code Breaker',
                  isUnlocked: isLevel2Unlocked,
                  isCompleted: false, // Placeholder
                  onPressed: () {},
                ),
                _buildLevelButton(
                  context: context,
                  levelNumber: 3,
                  levelName: 'The Final Chase',
                  isUnlocked: isLevel3Unlocked,
                  isCompleted: false, // Placeholder
                  onPressed: () {},
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // UPDATED: The button builder now handles a "completed" state.
  Widget _buildLevelButton({
    required BuildContext context,
    required int levelNumber,
    required String levelName,
    required bool isUnlocked,
    required bool isCompleted, // NEW parameter
    required VoidCallback onPressed,
  }) {
    final bool isLocked = !isUnlocked;
    IconData icon;
    Color buttonColor;
    Color sideColor;
    VoidCallback? finalOnPressed;

    if (isCompleted) {
      icon = Icons.check_circle;
      buttonColor = Colors.green.shade800.withAlpha(220);
      sideColor = Colors.green.shade300;
      // NEW: When completed, tapping the button shows the score.
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
      icon = Icons.lock_outline;
      buttonColor = Colors.grey.shade800.withAlpha(200);
      sideColor = Colors.grey.shade600;
      finalOnPressed = null; // Disabled
    } else {
      icon = Icons.lock_open_outlined;
      buttonColor = Colors.orange.shade800.withAlpha(220);
      sideColor = Colors.orange.shade300;
      finalOnPressed = onPressed; // The original action
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        icon: Icon(icon, color: isLocked ? Colors.white54 : Colors.white),
        label: Column(
          children: [
            Text('Level $levelNumber', style: GoogleFonts.cinzel(fontSize: 14)),
            Text(
              isCompleted ? 'Completed' : levelName,
              style: GoogleFonts.cinzel(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: sideColor, width: 2),
          ),
          disabledBackgroundColor: Colors.grey.shade800.withAlpha(200),
          disabledForegroundColor: Colors.white54,
        ),
        onPressed: finalOnPressed,
      ),
    );
  }
}
