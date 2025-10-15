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
  int? _selectedQuizOption;

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
          .collection('game_content/level2/puzzles')
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

  void _setupTimer() {
    _timerSubscription = _timerDocRef.snapshots().listen((timerSnap) {
      if (!mounted) return;
      final data = timerSnap.data();
      final endTime = (data?['endTime'] as Timestamp?)?.toDate();
      _countdownTimer?.cancel();
      if (endTime != null) {
        setState(() => _timerNotStarted = false);
        final now = DateTime.now();
        if (endTime.isAfter(now)) {
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
          setState(() => _timeLeft = Duration.zero);
          if (!_isSubmitting) _submitScore(autoSubmitted: true);
        }
      } else {
        setState(() {
          _timeLeft = Duration.zero;
          _timerNotStarted = true;
        });
      }
      setState(() => _isLoading = false);
    });
  }

  void _checkAnswer({String? quizAnswer}) {
    if (_puzzles.isEmpty) return;
    final currentPuzzle = _puzzles[_currentIndex];

    String submittedAnswer;
    if (currentPuzzle.type == PuzzleType.quiz) {
      submittedAnswer = quizAnswer ?? "SKIPPED";
    } else {
      submittedAnswer = _textController.text.trim().toUpperCase();
    }

    final correctAnswer = currentPuzzle.correctAnswer.toUpperCase();
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

    _moveToNext();
  }

  void _moveToNext() {
    _textController.clear();
    setState(() => _selectedQuizOption = null);

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

  // REWRITE: This now includes the media display logic.
  Widget _buildPuzzleUI(Puzzle puzzle) {
    return Column(
      children: [
        // NEW: Conditionally display the image if the URL exists.
        if (puzzle.mediaUrl != null && puzzle.mediaUrl!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                puzzle.mediaUrl!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  return progress == null
                      ? child
                      : const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        // The rest of the UI is built based on the puzzle type
        Builder(
          builder: (context) {
            switch (puzzle.type) {
              case PuzzleType.quiz:
                return _buildQuizPuzzle(puzzle);
              case PuzzleType.scramble:
                return _buildScramblePuzzle(puzzle);
              case PuzzleType.riddle:
              case PuzzleType.math:
                return _buildTextPuzzle(puzzle);
            }
          },
        ),
      ],
    );
  }

  Widget _buildQuizPuzzle(Puzzle puzzle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          puzzle.prompt,
          textAlign: TextAlign.center,
          style: GoogleFonts.cinzel(fontSize: 22, color: Colors.white),
        ),
        const SizedBox(height: 32),
        ...List.generate(puzzle.options!.length, (optionIndex) {
          bool isSelected = _selectedQuizOption == optionIndex;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: OutlinedButton(
              onPressed: () {
                setState(() => _selectedQuizOption = optionIndex);
                Future.delayed(
                  const Duration(milliseconds: 300),
                  () => _checkAnswer(
                    quizAnswer: puzzle.options![optionIndex].toUpperCase(),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: isSelected
                    ? Colors.amber.withAlpha(50)
                    : Colors.black.withAlpha(75),
                side: BorderSide(
                  color: isSelected ? Colors.amber : Colors.grey.shade700,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 16,
                ),
              ),
              child: Text(
                puzzle.options![optionIndex],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected
                      ? Colors.amber
                      : Colors.white.withAlpha((0.8 * 255).round()),
                  fontSize: 16,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTextPuzzle(Puzzle puzzle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          puzzle.prompt,
          textAlign: TextAlign.center,
          style: GoogleFonts.cinzel(fontSize: 22, color: Colors.white),
        ),
        const SizedBox(height: 40),
        _buildAnswerTextField(),
        const SizedBox(height: 30),
        _buildSubmitButton(),
      ],
    );
  }

  Widget _buildScramblePuzzle(Puzzle puzzle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Unscramble the word:',
          textAlign: TextAlign.center,
          style: GoogleFonts.cinzel(fontSize: 22, color: Colors.white),
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
            puzzle.prompt,
            textAlign: TextAlign.center,
            style: GoogleFonts.bangers(
              fontSize: 50,
              color: Colors.white,
              letterSpacing: 8,
            ),
          ),
        ),
        const SizedBox(height: 40),
        _buildAnswerTextField(isScramble: true),
        const SizedBox(height: 30),
        _buildSubmitButton(),
      ],
    );
  }

  Widget _buildAnswerTextField({bool isScramble = false}) {
    return TextField(
      controller: _textController,
      textAlign: TextAlign.center,
      autocorrect: false,
      enableSuggestions: false,
      textCapitalization: isScramble
          ? TextCapitalization.characters
          : TextCapitalization.none,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        hintText: 'YOUR ANSWER',
        hintStyle: TextStyle(
          color: Colors.white.withAlpha((0.5 * 255).round()),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade600),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.amber, width: 2),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: _isSubmitting ? null : () => _checkAnswer(),
      child: Text(
        _currentIndex < _puzzles.length - 1
            ? 'Submit Answer'
            : 'Submit Final Answer',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(_timeLeft.inMinutes.remainder(60));
    final seconds = twoDigits(_timeLeft.inSeconds.remainder(60));
    final timeString = '$minutes:$seconds';
    final canPlay = !_isLoading && !_timerNotStarted && _puzzles.isNotEmpty;

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
            ? SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
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
                      _buildPuzzleUI(_puzzles[_currentIndex]),
                    ],
                  ),
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
