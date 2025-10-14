// ===============================
// FILE NAME: level2_puzzle_screen.dart
// FILE PATH: C:\treasurehunt\treasure_huntjo\treasure_hunt_app\lib\screens\game_panel\level2_puzzle_screen.dart
// ===============================

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:treasure_hunt_app/models/puzzle_model.dart';
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

  List<Puzzle> _puzzles = [];
  int _currentIndex = 0;
  int _score = 0;

  final Map<String, String> _submittedAnswers = {};

  @override
  void initState() {
    super.initState();
    _initializeLevel();
  }

  @override
  void dispose() {
    _timerSubscription?.cancel();
    _countdownTimer?.cancel();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _initializeLevel() async {
    await _fetchPuzzles();
    _setupTimer();
  }

  Future<void> _fetchPuzzles() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('game_content')
          .doc('level2')
          .collection('puzzles')
          .get();
      if (mounted) {
        setState(() {
          _puzzles = snapshot.docs
              .map((doc) => Puzzle.fromMap(doc.data()))
              .toList();
          _puzzles.shuffle();
        });
      }
    } catch (e) {
      debugPrint("Error fetching puzzles: $e");
    }
  }

  // --- THE FIX IS HERE: Standardized and more robust timer logic ---
  void _setupTimer() {
    _timerSubscription = _timerDocRef.snapshots().listen((timerSnap) {
      if (!mounted) return;
      final data = timerSnap.data();
      final endTime = (data?['endTime'] as Timestamp?)?.toDate();
      _countdownTimer?.cancel();

      if (endTime != null) {
        // This block runs if the admin has started the timer
        setState(() => _timerNotStarted = false);
        final now = DateTime.now();
        if (endTime.isAfter(now)) {
          // Timer is active and counting down
          _timeLeft = endTime.difference(now);
          _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
            final secondsLeft = _timeLeft.inSeconds - 1;
            if (secondsLeft < 0) {
              timer.cancel();
              if (!_isSubmitting) _submitScore(autoSubmitted: true);
            } else if (mounted) {
              setState(() => _timeLeft = Duration(seconds: secondsLeft));
            }
          });
        } else {
          // Timer has already expired
          setState(() => _timeLeft = Duration.zero);
          if (!_isSubmitting) _submitScore(autoSubmitted: true);
        }
      } else {
        // This block runs if the timer has NOT been started by the admin
        setState(() {
          _timeLeft = Duration.zero;
          _timerNotStarted = true;
        });
      }

      setState(() => _isLoading = false);
    });
  }

  void _checkAnswer() {
    if (_puzzles.isEmpty) return;

    final submittedAnswer = _textController.text.trim().toUpperCase();
    final currentPuzzle = _puzzles[_currentIndex];
    final correctAnswer = currentPuzzle.correctAnswer;

    _submittedAnswers[currentPuzzle.id] = submittedAnswer.isEmpty
        ? "SKIPPED"
        : submittedAnswer;

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
      _submitScore(autoSubmitted: false);
    }
  }

  Future<void> _submitScore({bool autoSubmitted = false}) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    _countdownTimer?.cancel();
    _timerSubscription?.cancel();

    if (autoSubmitted) {
      for (final puzzle in _puzzles) {
        if (!_submittedAnswers.containsKey(puzzle.id)) {
          _submittedAnswers[puzzle.id] = "TIME UP";
        }
      }
    }

    final submissionData = {
      'score': _score,
      'totalQuestions': _puzzles.length,
      'submittedAt': Timestamp.now(),
      'answers': _submittedAnswers,
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
                ? 'Time is up! Your score: $_score/${_puzzles.length}'
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

    final bool canPlay =
        !_isLoading && !_timerNotStarted && _puzzles.isNotEmpty;

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
        child: canPlay
            ? Padding(
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
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _puzzles[_currentIndex].scrambledWord,
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
                          // ignore: deprecated_member_use
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
              )
            : Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(
                        _timerNotStarted
                            ? "Waiting for the admin to start the timer..."
                            : "No puzzles have been added for this level yet.",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
              ),
      ),
    );
  }
}
