// lib/screens/game_panel/quiz_screen.dart

import 'dart:async';
// REMOVED: Unused 'audioplayers' import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:treasure_hunt_app/models/quiz_model.dart';
import 'package:treasure_hunt_app/services/auth_service.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _timerDocRef = FirebaseFirestore.instance
      .collection('game_settings')
      .doc('level1_timer');

  StreamSubscription? _timerSubscription;
  Timer? _countdownTimer;
  Duration _timeLeft = Duration.zero;
  bool _timerNotStarted = false;

  List<QuizQuestion> _questions = [];
  bool _isLoading = true;
  final PageController _pageController = PageController();
  final Map<int, int> _selectedAnswers = {};
  bool _isSubmitting = false;
  // REMOVED: Unused '_audioPlayer' variable

  @override
  void initState() {
    super.initState();
    // REMOVED: Audio player initialization
    _fetchQuestionsAndSetupTimer();
  }

  @override
  void dispose() {
    _timerSubscription?.cancel();
    _countdownTimer?.cancel();
    // REMOVED: Audio player disposal
    super.dispose();
  }

  Future<void> _fetchQuestionsAndSetupTimer() async {
    final questionsSnapshot = await FirebaseFirestore.instance
        .collection('quizzes')
        .doc('level1')
        .collection('questions')
        .get();

    _timerSubscription = _timerDocRef.snapshots().listen((timerSnap) {
      // FIX: Added curly braces to the if statement body.
      if (!mounted) {
        return;
      }

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
              if (!_isSubmitting) {
                _submitAnswers(autoSubmitted: true);
              }
            } else {
              setState(() {
                _timeLeft = Duration(seconds: secondsLeft);
              });
            }
          });
        } else {
          setState(() => _timeLeft = Duration.zero);
          // FIX: Added curly braces to the if statement body.
          if (!_isSubmitting) {
            _submitAnswers(autoSubmitted: true);
          }
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _timerNotStarted
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  "Waiting for the admin to start the timer...",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
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
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Question ${index + 1}/${_questions.length}',
                        style: const TextStyle(color: Colors.orange),
                      ),
                      const SizedBox(height: 8),

                      // REMOVED: Audio player button and logic
                      if (question.imageUrl != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              question.imageUrl!,
                              height: 150,
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
                        question.questionText,
                        style: GoogleFonts.cinzel(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      ...List.generate(question.options.length, (optionIndex) {
                        return Card(
                          // FIX: Replaced deprecated withOpacity
                          color: _selectedAnswers[index] == optionIndex
                              ? Colors.orange.withAlpha((0.5 * 255).round())
                              : Theme.of(context).cardColor,
                          child: ListTile(
                            title: Text(question.options[optionIndex]),
                            onTap: () {
                              setState(() {
                                _selectedAnswers[index] = optionIndex;
                              });
                            },
                          ),
                        );
                      }),
                      const Spacer(),

                      if (isLastQuestion)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed:
                              _isSubmitting ||
                                  _timerNotStarted ||
                                  _selectedAnswers.length != _questions.length
                              ? null
                              : () => _submitAnswers(),
                          child: _isSubmitting
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text('Submit Final Answers'),
                        )
                      else
                        ElevatedButton(
                          onPressed: () {
                            // REMOVED: audioPlayer.stop() call
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            );
                          },
                          child: const Text('Next Question'),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
