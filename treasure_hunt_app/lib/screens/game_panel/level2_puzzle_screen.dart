// ===============================
// FILE NAME: level2_puzzle_screen.dart
// FILE PATH: C:\treasurehunt\treasure_huntjo\treasure_hunt_app\lib\screens\game_panel\level2_puzzle_screen.dart
// ===============================

// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:treasure_hunt_app/services/auth_service.dart';

class Level2PuzzleScreen extends StatefulWidget {
  const Level2PuzzleScreen({super.key});

  @override
  State<Level2PuzzleScreen> createState() => _Level2PuzzleScreenState();
}

class _Level2PuzzleScreenState extends State<Level2PuzzleScreen> {
  final _timerDocRef = FirebaseFirestore.instance
      .collection('game_settings')
      .doc('level2_timer');
  final _textController = TextEditingController();
  final _authService = AuthService();

  StreamSubscription? _timerSubscription;
  Timer? _countdownTimer;
  Duration _timeLeft = Duration.zero;
  bool _timerNotStarted = false;
  bool _isLoading = true;
  bool _isSubmitting = false;

  // In a real application, you might fetch these puzzles from Firestore.
  // For this example, we'll hardcode them.
  final List<Map<String, String>> _puzzles = [
    {'scrambled': 'UTFERLT', 'answer': 'FLUTTER'},
    {'scrambled': 'BRIAFSEE', 'answer': 'FIREBASE'},
    {'scrambled': 'TRAD', 'answer': 'DART'},
    {'scrambled': 'TEWIDG', 'answer': 'WIDGET'},
    {'scrambled': 'STELASST', 'answer': 'STATELESS'},
  ];

  int _currentIndex = 0;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _setupTimer();
  }

  @override
  void dispose() {
    _timerSubscription?.cancel();
    _countdownTimer?.cancel();
    _textController.dispose();
    super.dispose();
  }

  void _setupTimer() {
    _timerSubscription = _timerDocRef.snapshots().listen((timerSnap) {
      if (!mounted) return;

      final data = timerSnap.data();
      final endTime = (data?['endTime'] as Timestamp?)?.toDate();

      _countdownTimer?.cancel();

      if (endTime != null) {
        setState(() {
          _timerNotStarted = false;
          _isLoading = false;
        });

        final now = DateTime.now();
        if (endTime.isAfter(now)) {
          _timeLeft = endTime.difference(now);
          _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
            final secondsLeft = _timeLeft.inSeconds - 1;
            if (secondsLeft < 0) {
              timer.cancel();
              if (!_isSubmitting) _submitScore(autoSubmitted: true);
            } else {
              if (mounted) {
                setState(() => _timeLeft = Duration(seconds: secondsLeft));
              }
            }
          });
        } else {
          // Timer has already expired
          setState(() => _timeLeft = Duration.zero);
          if (!_isSubmitting) _submitScore(autoSubmitted: true);
        }
      } else {
        // Timer has been stopped by the admin
        setState(() {
          _timeLeft = Duration.zero;
          _timerNotStarted = true;
          _isLoading = false;
        });
      }
    });
  }

  void _checkAnswer() {
    final submittedAnswer = _textController.text.trim().toUpperCase();
    final correctAnswer = _puzzles[_currentIndex]['answer'];

    if (submittedAnswer == correctAnswer) {
      _score++;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Correct!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Incorrect. The answer was $correctAnswer.'),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    _textController.clear();

    if (_currentIndex < _puzzles.length - 1) {
      setState(() => _currentIndex++);
    } else {
      // This was the last puzzle, submit the score
      _submitScore(autoSubmitted: false);
    }
  }

  Future<void> _submitScore({bool autoSubmitted = false}) async {
    // Prevent multiple submissions
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    _countdownTimer?.cancel();
    _timerSubscription?.cancel();

    final submissionData = {
      'score': _score,
      'totalQuestions': _puzzles.length,
      'submittedAt': Timestamp.now(),
    };

    final user = _authService.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('teams').doc(user.uid).update(
        {'level2Submission': submissionData},
      );
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            autoSubmitted
                ? 'Time is up! Answers auto-submitted. Score: $_score/${_puzzles.length}'
                : 'Level 2 complete! Your score: $_score/${_puzzles.length}',
          ),
          backgroundColor: autoSubmitted ? Colors.orange : Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(_timeLeft.inMinutes.remainder(60));
    final seconds = twoDigits(_timeLeft.inSeconds.remainder(60));
    final timeString = '$minutes:$seconds';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Level 2: Code Breaker'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                timeString,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/quiz_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _timerNotStarted
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    "Waiting for the admin to start the timer...",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Puzzle ${_currentIndex + 1}/${_puzzles.length}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Unscramble the word:',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cinzel(
                        fontSize: 22,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _puzzles[_currentIndex]['scrambled']!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.bangers(
                          fontSize: 50,
                          color: Colors.white,
                          letterSpacing: 8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    TextField(
                      controller: _textController,
                      textAlign: TextAlign.center,
                      autocorrect: false,
                      enableSuggestions: false,
                      textCapitalization: TextCapitalization.characters,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: 'YOUR ANSWER',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade600),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.amber,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isSubmitting ? null : _checkAnswer,
                      child: Text(
                        _currentIndex < _puzzles.length - 1
                            ? 'Submit Answer'
                            : 'Submit Final Answer',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
