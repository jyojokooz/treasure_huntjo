// ===============================
// FILE NAME: clues_view.dart
// FILE PATH: C:\treasurehunt\treasure_huntjo\treasure_hunt_app\lib\screens\game_panel\clues_view.dart
// ===============================

// ignore_for_file: deprecated_member_use

import 'dart:async'; // NEW: Import for Timer and StreamSubscription
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:treasure_hunt_app/models/team_model.dart';
import 'package:treasure_hunt_app/screens/game_panel/level2_puzzle_screen.dart';
import 'package:treasure_hunt_app/screens/game_panel/level3_screen.dart';
import 'package:treasure_hunt_app/screens/game_panel/quiz_screen.dart';

// --- CONVERTED TO A STATEFUL WIDGET ---
class CluesView extends StatefulWidget {
  final Team team;
  const CluesView({super.key, required this.team});

  @override
  State<CluesView> createState() => _CluesViewState();
}

class _CluesViewState extends State<CluesView> {
  // NEW: State variables for timers and subscriptions
  StreamSubscription? _level1Sub, _level2Sub, _level3Sub;
  Timer? _level1Timer, _level2Timer, _level3Timer;

  Duration _level1Countdown = Duration.zero;
  Duration _level2Countdown = Duration.zero;
  Duration _level3Countdown = Duration.zero;

  @override
  void initState() {
    super.initState();
    _setupTimerListeners();
  }

  @override
  void dispose() {
    _level1Sub?.cancel();
    _level2Sub?.cancel();
    _level3Sub?.cancel();
    _level1Timer?.cancel();
    _level2Timer?.cancel();
    _level3Timer?.cancel();
    super.dispose();
  }

  // NEW: Helper to format duration into MM:SS
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  // NEW: Central method to set up listeners for all level timers
  void _setupTimerListeners() {
    _setupListenerForLevel(
      'level1',
      (timer) => _level1Timer = timer,
      (sub) => _level1Sub = sub,
      (duration) => setState(() => _level1Countdown = duration),
    );
    _setupListenerForLevel(
      'level2',
      (timer) => _level2Timer = timer,
      (sub) => _level2Sub = sub,
      (duration) => setState(() => _level2Countdown = duration),
    );
    _setupListenerForLevel(
      'level3',
      (timer) => _level3Timer = timer,
      (sub) => _level3Sub = sub,
      (duration) => setState(() => _level3Countdown = duration),
    );
  }

  // NEW: Reusable logic for listening to a specific level's timer document
  void _setupListenerForLevel(
    String levelId,
    Function(Timer?) setTimer,
    Function(StreamSubscription?) setSubscription,
    Function(Duration) setCountdownDuration,
  ) {
    final docRef = FirebaseFirestore.instance
        .collection('game_settings')
        .doc('${levelId}_timer');

    final subscription = docRef.snapshots().listen((snapshot) {
      if (!mounted || !snapshot.exists) return;

      final data = snapshot.data()!;
      final countdownEndTime = (data['countdownEndTime'] as Timestamp?)
          ?.toDate();

      setTimer(null); // Cancel any existing timer
      setCountdownDuration(Duration.zero);

      if (countdownEndTime != null &&
          countdownEndTime.isAfter(DateTime.now())) {
        setCountdownDuration(countdownEndTime.difference(DateTime.now()));
        final newTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (!mounted) {
            timer.cancel();
            return;
          }
          final remaining = countdownEndTime.difference(DateTime.now());
          if (remaining.isNegative) {
            timer.cancel();
            setCountdownDuration(Duration.zero);
          } else {
            setCountdownDuration(remaining);
          }
        });
        setTimer(newTimer);
      }
    });
    setSubscription(subscription);
  }

  // --- MODIFIED HELPER WIDGET ---
  Widget _buildLevelButton({
    required BuildContext context,
    required int levelNumber,
    required String levelName,
    required bool isUnlocked,
    required bool isCompleted,
    required VoidCallback onPressed,
    required Map<String, dynamic>? submissionData,
    required Duration countdownDuration, // NEW PARAMETER
  }) {
    final bool isCountdownActive = countdownDuration > Duration.zero;
    bool isLocked = !isUnlocked && !isCountdownActive;
    IconData iconData;
    Color buttonColor, borderColor, iconColor, textColor;
    Widget centerContent;
    VoidCallback? finalOnPressed;

    if (isCompleted) {
      iconData = Icons.check_circle;
      buttonColor = const Color(0xFF1A7431);
      borderColor = Colors.greenAccent;
      iconColor = Colors.white;
      textColor = Colors.white;
      centerContent = _buildButtonText(
        'LEVEL $levelNumber',
        'COMPLETED',
        textColor,
      );
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
    } else if (isCountdownActive) {
      // NEW STATE
      iconData = Icons.timer_outlined;
      buttonColor = const Color(0xFF1E3A8A); // A nice blue
      borderColor = Colors.blueAccent;
      iconColor = Colors.white;
      textColor = Colors.white;
      centerContent = _buildButtonText(
        'LEVEL $levelNumber',
        'STARTS IN ${_formatDuration(countdownDuration)}',
        textColor,
      );
      finalOnPressed = null; // Button is disabled during countdown
    } else if (isLocked) {
      iconData = Icons.lock;
      buttonColor = const Color(0xFF4A4A4A);
      borderColor = Colors.grey.shade600;
      iconColor = Colors.white.withOpacity(0.5);
      textColor = Colors.white.withOpacity(0.5);
      centerContent = _buildButtonText(
        'LEVEL $levelNumber',
        levelName.toUpperCase(),
        textColor,
      );
      finalOnPressed = null;
    } else {
      // Unlocked
      iconData = Icons.lock_open;
      buttonColor = Colors.amber.shade700;
      borderColor = Colors.amber;
      iconColor = Colors.white;
      textColor = Colors.white;
      centerContent = _buildButtonText(
        'LEVEL $levelNumber',
        'ENTER',
        textColor,
      );
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
            centerContent,
          ],
        ),
      ),
    );
  }

  // NEW: Helper to build the text part of the button to avoid repetition
  Widget _buildButtonText(String top, String bottom, Color color) {
    return Column(
      children: [
        Text(
          top,
          style: GoogleFonts.cinzel(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
            letterSpacing: 1.2,
          ),
        ),
        Text(
          bottom,
          style: GoogleFonts.cinzel(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
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
          stream: FirebaseFirestore.instance
              .collection('game_settings')
              .doc('level1_timer')
              .snapshots(),
          builder: (context, level1TimerSnap) {
            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('game_settings')
                  .doc('level2_timer')
                  .snapshots(),
              builder: (context, level2TimerSnap) {
                return StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('game_settings')
                      .doc('level3_timer')
                      .snapshots(),
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
                        isLevel2TimerRunning && widget.team.isEligibleForLevel2;

                    // Level 3 Logic
                    final level3TimerData =
                        level3TimerSnap.data?.data() as Map<String, dynamic>? ??
                        {};
                    final level3EndTime =
                        (level3TimerData['endTime'] as Timestamp?)?.toDate();
                    final isLevel3TimerRunning =
                        level3EndTime != null &&
                        level3EndTime.isAfter(DateTime.now());
                    final isLevel3Unlocked =
                        isLevel3TimerRunning && widget.team.isEligibleForLevel3;

                    final hasCompletedLevel1 =
                        widget.team.level1Submission != null;
                    final hasCompletedLevel2 =
                        widget.team.level2Submission != null;
                    final hasCompletedLevel3 =
                        widget.team.level3Submission != null;

                    return Column(
                      children: [
                        _buildLevelButton(
                          context: context,
                          levelNumber: 1,
                          levelName: 'Mind Spark',
                          isUnlocked: isLevel1Unlocked,
                          isCompleted: hasCompletedLevel1,
                          submissionData: widget.team.level1Submission,
                          countdownDuration: _level1Countdown, // NEW
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
                          submissionData: widget.team.level2Submission,
                          countdownDuration: _level2Countdown, // NEW
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Level2PuzzleScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildLevelButton(
                          context: context,
                          levelNumber: 3,
                          levelName: 'The Final Chase',
                          isUnlocked: isLevel3Unlocked,
                          isCompleted: hasCompletedLevel3,
                          submissionData: widget.team.level3Submission,
                          countdownDuration: _level3Countdown, // NEW
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
