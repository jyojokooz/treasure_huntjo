// ===============================
// FILE NAME: clues_view.dart
// FILE PATH: C:\treasurehunt\treasure_huntjo\treasure_hunt_app\lib\screens\game_panel\clues_view.dart
// ===============================

// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:treasure_hunt_app/models/team_model.dart';
import 'package:treasure_hunt_app/screens/game_panel/level2_puzzle_screen.dart';
import 'package:treasure_hunt_app/screens/game_panel/level3_screen.dart'; // NEW
import 'package:treasure_hunt_app/screens/game_panel/quiz_screen.dart';

class CluesView extends StatelessWidget {
  final Team team;
  const CluesView({super.key, required this.team});

  DocumentReference get _level1TimerRef => FirebaseFirestore.instance
      .collection('game_settings')
      .doc('level1_timer');
  DocumentReference get _level2TimerRef => FirebaseFirestore.instance
      .collection('game_settings')
      .doc('level2_timer');
  DocumentReference get _level3TimerRef => FirebaseFirestore.instance
      .collection('game_settings')
      .doc('level3_timer'); // NEW

  Widget _buildLevelButton({
    required BuildContext context,
    required int levelNumber,
    required String levelName,
    required bool isUnlocked,
    required bool isCompleted,
    required VoidCallback onPressed,
    required Map<String, dynamic>? submissionData,
  }) {
    bool isLocked = !isUnlocked;
    IconData iconData;
    Color buttonColor, borderColor, iconColor, textColor;
    String topText, bottomText;
    VoidCallback? finalOnPressed;

    if (isCompleted) {
      iconData = Icons.check_circle;
      buttonColor = const Color(0xFF1A7431);
      borderColor = Colors.greenAccent;
      iconColor = Colors.white;
      textColor = Colors.white;
      topText = 'LEVEL $levelNumber';
      bottomText = 'COMPLETED';
      finalOnPressed = () {
        final score = submissionData?['score'] ?? 0;
        final total = submissionData?['totalQuestions'] ?? 0;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'You completed Level $levelNumber with a score of $score/$total.',
            ),
          ),
        );
      };
    } else if (isLocked) {
      iconData = Icons.lock;
      buttonColor = const Color(0xFF4A4A4A);
      borderColor = Colors.grey.shade600;
      iconColor = Colors.white.withOpacity(0.5);
      textColor = Colors.white.withOpacity(0.5);
      topText = 'LEVEL $levelNumber';
      bottomText = levelName.toUpperCase();
      finalOnPressed = null;
    } else {
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Treasure Hunt Dashboard',
          textAlign: TextAlign.center,
          style: GoogleFonts.cinzel(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(blurRadius: 15.0, color: Colors.amber.withOpacity(0.7)),
              Shadow(
                blurRadius: 2.0,
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(1, 1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),
        StreamBuilder<DocumentSnapshot>(
          stream: _level1TimerRef.snapshots(),
          builder: (context, level1TimerSnap) {
            return StreamBuilder<DocumentSnapshot>(
              stream: _level2TimerRef.snapshots(),
              builder: (context, level2TimerSnap) {
                // NEW: Wrap with Level 3 Timer StreamBuilder
                return StreamBuilder<DocumentSnapshot>(
                  stream: _level3TimerRef.snapshots(),
                  builder: (context, level3TimerSnap) {
                    if (!level1TimerSnap.hasData ||
                        !level2TimerSnap.hasData ||
                        !level3TimerSnap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Level 1 Logic
                    final level1TimerData =
                        level1TimerSnap.data?.data() as Map<String, dynamic>? ??
                        {};
                    final level1EndTime =
                        (level1TimerData['endTime'] as Timestamp?)?.toDate();
                    final isLevel1Unlocked =
                        level1EndTime != null &&
                        level1EndTime.isAfter(DateTime.now());

                    // Level 2 Logic
                    final level2TimerData =
                        level2TimerSnap.data?.data() as Map<String, dynamic>? ??
                        {};
                    final level2EndTime =
                        (level2TimerData['endTime'] as Timestamp?)?.toDate();
                    final isLevel2TimerRunning =
                        level2EndTime != null &&
                        level2EndTime.isAfter(DateTime.now());
                    final isLevel2Unlocked =
                        isLevel2TimerRunning && team.isEligibleForLevel2;

                    // NEW: Level 3 Logic
                    final level3TimerData =
                        level3TimerSnap.data?.data() as Map<String, dynamic>? ??
                        {};
                    final level3EndTime =
                        (level3TimerData['endTime'] as Timestamp?)?.toDate();
                    final isLevel3TimerRunning =
                        level3EndTime != null &&
                        level3EndTime.isAfter(DateTime.now());
                    final isLevel3Unlocked =
                        isLevel3TimerRunning && team.isEligibleForLevel3;

                    final hasCompletedLevel1 = team.level1Submission != null;
                    final hasCompletedLevel2 = team.level2Submission != null;
                    final hasCompletedLevel3 =
                        team.level3Submission != null; // NEW

                    return Column(
                      children: [
                        _buildLevelButton(
                          context: context,
                          levelNumber: 1,
                          levelName: 'Mind Spark',
                          isUnlocked: isLevel1Unlocked,
                          isCompleted: hasCompletedLevel1,
                          submissionData: team.level1Submission,
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const QuizScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildLevelButton(
                          context: context,
                          levelNumber: 2,
                          levelName: 'Code Breaker',
                          isUnlocked: isLevel2Unlocked,
                          isCompleted: hasCompletedLevel2,
                          submissionData: team.level2Submission,
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Level2PuzzleScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        // NEW: Level 3 Button
                        _buildLevelButton(
                          context: context,
                          levelNumber: 3,
                          levelName: 'The Final Chase',
                          isUnlocked: isLevel3Unlocked,
                          isCompleted: hasCompletedLevel3,
                          submissionData: team.level3Submission,
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Level3Screen(),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
