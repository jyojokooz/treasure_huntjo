// lib/screens/game_panel/quiz_screen.dart

// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:treasure_hunt_app/models/quiz_model.dart';
// FIX: Removed unused 'auth_service.dart' import.
import 'package:treasure_hunt_app/services/auth_service.dart'; // Keep auth_service for user ID

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // FIX: These fields are only assigned once, so they can be 'final'.
  final PageController _pageController = PageController();
  final Map<int, int> _selectedAnswers = {};

  // FIX: This field is no longer used directly here, but within the listener.
  // It's good practice to keep the reference if needed for other methods.
  final _timerDocRef = FirebaseFirestore.instance
      .collection('game_settings')
      .doc('level1_timer');

  // These variables change over time, so they cannot be final.
  StreamSubscription? _timerSubscription;
  Timer? _countdownTimer;
  Duration _timeLeft = Duration.zero;
  bool _timerNotStarted = false;
  List<QuizQuestion> _questions = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchQuestionsAndSetupTimer();
  }

  @override
  void dispose() {
    _timerSubscription?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchQuestionsAndSetupTimer() async {
    final questionsSnapshot = await FirebaseFirestore.instance
        .collection('quizzes')
        .doc('level1')
        .collection('questions')
        .get();

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
              if (!_isSubmitting) _submitAnswers(autoSubmitted: true);
            } else {
              setState(() => _timeLeft = Duration(seconds: secondsLeft));
            }
          });
        } else {
          setState(() => _timeLeft = Duration.zero);
          if (!_isSubmitting) _submitAnswers(autoSubmitted: true);
        }
      } else {
        setState(() {
          _timeLeft = Duration.zero;
          _timerNotStarted = true;
        });
      }
    });

    setState(() {
      _questions = questionsSnapshot.docs
          .map((doc) => QuizQuestion.fromMap(doc.data()))
          .toList();
      _isLoading = false;
    });
  }

  // FIX: Removed the unused 'autoSubmitted' parameter.
  Future<void> _submitAnswers({bool autoSubmitted = false}) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    _countdownTimer?.cancel();

    int score = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_selectedAnswers.containsKey(i) &&
          _selectedAnswers[i] == _questions[i].correctAnswerIndex) {
        score++;
      }
    }

    final submissionData = {
      'score': score,
      'totalQuestions': _questions.length,
      'submittedAt': Timestamp.now(),
      'answers': _selectedAnswers.map((k, v) => MapEntry(k.toString(), v)),
    };

    // Use AuthService here to get the current user ID for the database update.
    final user = AuthService().currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('teams').doc(user.uid).update(
        {'level1Submission': submissionData},
      );
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            autoSubmitted
                ? 'Time is up! Answers auto-submitted. Score: $score/${_questions.length}'
                : 'Level 1 complete! Your score: $score/${_questions.length}',
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
        title: const Text('Level 1: Mind Spark'),
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
                      fontStyle: FontStyle.italic,
                      color: Colors.white70,
                    ),
                  ),
                ),
              )
            : PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  final question = _questions[index];
                  bool isLastQuestion = index == _questions.length - 1;

                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Question ${index + 1}/${_questions.length}',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (question.imageUrl != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                question.imageUrl!,
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  return progress == null
                                      ? child
                                      : const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                },
                              ),
                            ),
                          ),
                        Text(
                          question.questionText.toUpperCase(),
                          style: GoogleFonts.montserrat(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Expanded(
                          child: ListView(
                            children: List.generate(question.options.length, (
                              optionIndex,
                            ) {
                              bool isSelected =
                                  _selectedAnswers[index] == optionIndex;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6.0,
                                ),
                                child: OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedAnswers[index] = optionIndex;
                                    });
                                  },
                                  style: OutlinedButton.styleFrom(
                                    // FIX: Replaced deprecated withOpacity
                                    backgroundColor: isSelected
                                        ? Colors.amber.withAlpha(
                                            (0.2 * 255).round(),
                                          )
                                        : Colors.black.withAlpha(
                                            (0.3 * 255).round(),
                                          ),
                                    side: BorderSide(
                                      color: isSelected
                                          ? Colors.amber
                                          : Colors.grey.shade700,
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
                                    question.options[optionIndex],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.amber
                                          : Colors.white.withOpacity(0.8),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isLastQuestion
                                ? Colors.amber
                                : Colors.grey.shade800,
                            foregroundColor: isLastQuestion
                                ? Colors.black
                                : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: isLastQuestion
                              ? (_isSubmitting ||
                                        _timerNotStarted ||
                                        _selectedAnswers.length !=
                                            _questions.length
                                    ? null
                                    : () =>
                                          _submitAnswers(autoSubmitted: false))
                              : () {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeIn,
                                  );
                                },
                          child: _isSubmitting && isLastQuestion
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                  ),
                                )
                              : Text(
                                  isLastQuestion
                                      ? 'Submit Final Answers'
                                      : 'Next Question',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
