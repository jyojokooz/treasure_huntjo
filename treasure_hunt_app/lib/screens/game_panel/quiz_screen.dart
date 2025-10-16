// ===============================
// FILE NAME: quiz_screen.dart
// FILE PATH: C:\treasurehunt\treasure_huntjo\treasure_hunt_app\lib\screens\game_panel\quiz_screen.dart
// ===============================

// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:treasure_hunt_app/models/quiz_model.dart';
import 'package:treasure_hunt_app/services/auth_service.dart';
import 'package:treasure_hunt_app/services/music_service.dart';
import 'package:video_player/video_player.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final PageController _pageController = PageController();
  final AuthService _auth = AuthService();

  Map<int, int> _selectedAnswers = {};
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
    MusicService.instance.pauseBackgroundMusic();
    _initializeLevel();
  }

  @override
  void dispose() {
    MusicService.instance.resumeBackgroundMusic();
    _timerSubscription?.cancel();
    _countdownTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initializeLevel() async {
    final user = _auth.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final teamRef = FirebaseFirestore.instance
        .collection('teams')
        .doc(user.uid);
    final teamDoc = await teamRef.get();
    final progress = teamDoc.data()?['level1Progress'] as Map<String, dynamic>?;

    List<QuizQuestion> allQuestions = [];
    final questionsSnapshot = await FirebaseFirestore.instance
        .collection('quizzes/level1/questions')
        .get();
    allQuestions = questionsSnapshot.docs
        .map((doc) => QuizQuestion.fromMap(doc.data()))
        .toList();

    if (progress != null) {
      final questionOrder = List<String>.from(progress['questionOrder'] ?? []);
      _questions = questionOrder
          .map(
            (id) => allQuestions.firstWhere(
              (q) => q.id == id,
              orElse: () => allQuestions.first,
            ),
          )
          .toList();
      _selectedAnswers =
          (progress['answers'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(int.parse(k), v as int),
          ) ??
          {};

      final initialPage = _selectedAnswers.keys.length;
      if (initialPage > 0 && initialPage < _questions.length) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController.hasClients) {
            _pageController.jumpToPage(initialPage);
          }
        });
      }
    } else {
      allQuestions.shuffle();
      _questions = allQuestions;

      final questionOrder = _questions.map((q) => q.id).toList();
      await teamRef.set({
        'level1Progress': {'questionOrder': questionOrder, 'answers': {}},
      }, SetOptions(merge: true));
    }

    if (mounted) setState(() => _isLoading = false);
    _setupTimer();
  }

  Future<void> _saveAnswer(int questionIndex, int answerIndex) async {
    setState(() {
      _selectedAnswers[questionIndex] = answerIndex;
    });

    final user = _auth.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('teams').doc(user.uid).set({
      'level1Progress': {
        'answers': _selectedAnswers.map((k, v) => MapEntry(k.toString(), v)),
      },
    }, SetOptions(merge: true));

    if (questionIndex < _questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  Future<void> _setupTimer() async {
    final timerDocRef = FirebaseFirestore.instance
        .collection('game_settings')
        .doc('level1_timer');
    _timerSubscription = timerDocRef.snapshots().listen((timerSnap) {
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
            } else if (mounted) {
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

    final user = _auth.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('teams').doc(user.uid).update(
        {
          'level1Submission': submissionData,
          'level1Progress': FieldValue.delete(),
        },
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

                  // --- THE FIX IS HERE ---
                  // We wrap the entire page content in a SingleChildScrollView
                  // to prevent overflows when media content is tall.
                  return SingleChildScrollView(
                    child: Padding(
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
                          if (question.mediaUrl != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 24.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: question.mediaType == MediaType.video
                                    ? _VideoPlayerWidget(
                                        key: ValueKey(question.id),
                                        url: question.mediaUrl!,
                                      )
                                    : Image.network(
                                        question.mediaUrl!,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        loadingBuilder:
                                            (
                                              context,
                                              child,
                                              progress,
                                            ) => progress == null
                                            ? child
                                            : const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
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
                          // The ListView of options is no longer in an Expanded widget.
                          // `shrinkWrap` and `NeverScrollableScrollPhysics` are added
                          // to make it work correctly inside the SingleChildScrollView.
                          ListView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
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
                                  onPressed: () =>
                                      _saveAnswer(index, optionIndex),
                                  style: OutlinedButton.styleFrom(
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
                          const SizedBox(height: 20),
                          if (isLastQuestion)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                disabledBackgroundColor: Colors.grey.shade800,
                              ),
                              onPressed:
                                  _isSubmitting ||
                                      _timerNotStarted ||
                                      _selectedAnswers.length !=
                                          _questions.length
                                  ? null
                                  : () => _submitAnswers(autoSubmitted: false),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.black,
                                      ),
                                    )
                                  : const Text(
                                      'Submit Final Answers',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _VideoPlayerWidget extends StatefulWidget {
  final String url;
  const _VideoPlayerWidget({super.key, required this.url});

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _initializeVideoPlayerFuture = _controller
        .initialize()
        .then((_) {
          if (mounted) {
            setState(() {
              _controller.setLooping(true);
              _controller.play();
              _isPlaying = true;
            });
          }
        })
        .catchError((error) {
          debugPrint("Video Player Error: $error");
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError || !_controller.value.isInitialized) {
            return const SizedBox(
              height: 180,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.redAccent,
                      size: 48,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Could not load video",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            );
          }

          return AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: GestureDetector(
              onTap: _togglePlayPause,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  VideoPlayer(_controller),
                  AnimatedOpacity(
                    opacity: _isPlaying ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white.withAlpha((0.8 * 255).round()),
                      size: 64,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const SizedBox(
            height: 180,
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
