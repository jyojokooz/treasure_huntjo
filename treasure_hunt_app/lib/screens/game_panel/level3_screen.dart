// ===============================
// FILE NAME: level3_screen.dart
// FILE PATH: C:\treasurehunt\treasure_huntjo\treasure_hunt_app\lib\screens\game_panel\level3_screen.dart
// ===============================

// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:treasure_hunt_app/models/level3_clue_model.dart';
import 'package:treasure_hunt_app/screens/game_panel/qr_scanner_screen.dart';
import 'package:treasure_hunt_app/services/auth_service.dart';

class Level3Screen extends StatefulWidget {
  const Level3Screen({super.key});

  @override
  State<Level3Screen> createState() => _Level3ScreenState();
}

class _Level3ScreenState extends State<Level3Screen> {
  final _timerDocRef = FirebaseFirestore.instance
      .collection('game_settings')
      .doc('level3_timer');
  final _authService = AuthService();

  // --- THE FIX: Define the controller here so it persists across rebuilds ---
  late final TextEditingController _initialAnswerController;

  StreamSubscription? _timerSubscription;
  Timer? _countdownTimer;
  Duration _timeLeft = Duration.zero;
  bool _timerNotStarted = false;

  bool _isLoading = true;
  bool _isSubmitting = false;
  Map<String, Level3Clue> _allClues = {};
  List<String> _clueOrder = [];

  @override
  void initState() {
    super.initState();
    // --- THE FIX: Initialize the controller once ---
    _initialAnswerController = TextEditingController();
    _initializeLevel();
  }

  @override
  void dispose() {
    _timerSubscription?.cancel();
    _countdownTimer?.cancel();
    // --- THE FIX: Dispose of the controller to prevent memory leaks ---
    _initialAnswerController.dispose();
    super.dispose();
  }

  Future<void> _initializeLevel() async {
    await _fetchLevel3SettingsAndClues();
    _setupTimer();
  }

  Future<void> _fetchLevel3SettingsAndClues() async {
    try {
      final settingsDoc = await FirebaseFirestore.instance
          .collection('game_settings')
          .doc('level3_settings')
          .get();
      final clueOrderFromAdmin = List<String>.from(
        settingsDoc.data()?['clueOrder'] ?? [],
      );

      final snapshot = await FirebaseFirestore.instance
          .collection('game_content/level3/clues')
          .get();
      final fetchedClues = {
        for (var doc in snapshot.docs)
          doc.id: Level3Clue.fromMap(doc.data(), doc.id),
      };

      if (mounted) {
        setState(() {
          _allClues = fetchedClues;
          _clueOrder = clueOrderFromAdmin;
        });
      }
    } catch (e) {
      debugPrint("Error fetching clues or settings: $e");
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

  Future<void> _handleStartingPointAnswer(String answer) async {
    final startingClue = _allClues['starting_point'];
    if (startingClue == null) return;

    if (answer.trim().toLowerCase() == startingClue.answer.toLowerCase()) {
      final user = _authService.currentUser;
      if (user == null) return;
      await FirebaseFirestore.instance.collection('teams').doc(user.uid).set({
        'level3Progress': {
          'solved': ['starting_point'],
          'currentClueId': _clueOrder.first,
        },
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Correct! Your first location hint is revealed.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrect answer. Try again!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _scanQRCode(Level3Clue clueToScan) async {
    final scannedValue = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    );
    if (scannedValue == null) return;

    if (scannedValue == clueToScan.qrCodeValue) {
      _showQuestionDialog(clueToScan);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wrong QR Code!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showQuestionDialog(Level3Clue clue) {
    final answerController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(clue.departmentName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(clue.question),
            const SizedBox(height: 16),
            TextField(
              controller: answerController,
              decoration: const InputDecoration(labelText: 'Your Answer'),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            child: const Text('Submit'),
            onPressed: () {
              if (answerController.text.trim().toLowerCase() ==
                  clue.answer.toLowerCase()) {
                Navigator.pop(dialogContext);
                _markClueAsSolved(clue.id);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Incorrect answer. Try again!'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _markClueAsSolved(String solvedClueId) async {
    final user = _authService.currentUser;
    if (user == null) return;
    final teamRef = FirebaseFirestore.instance
        .collection('teams')
        .doc(user.uid);

    final nextClueIndex = _clueOrder.indexOf(solvedClueId) + 1;
    final String nextClueId = (nextClueIndex >= _clueOrder.length)
        ? 'completed'
        : _clueOrder[nextClueIndex];

    await teamRef.update({
      'level3Progress.solved': FieldValue.arrayUnion([solvedClueId]),
      'level3Progress.currentClueId': nextClueId,
    });

    if (nextClueId == 'completed') {
      _submitScore(autoSubmitted: false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Correct! On to the next clue...'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _submitScore({bool autoSubmitted = false}) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    _countdownTimer?.cancel();
    _timerSubscription?.cancel();
    final user = _authService.currentUser;
    if (user == null) return;
    final teamRef = FirebaseFirestore.instance
        .collection('teams')
        .doc(user.uid);
    final teamSnapshot = await teamRef.get();

    final solvedClues = List<String>.from(
      teamSnapshot.data()?['level3Progress']?['solved'] ?? [],
    );
    final score = solvedClues.where((id) => id != 'starting_point').length;

    final submissionData = {
      'score': score,
      'totalQuestions': _clueOrder.length,
      'submittedAt': Timestamp.now(),
    };
    await teamRef.update({'level3Submission': submissionData});
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            autoSubmitted
                ? 'Time is up! Your final score: $score/${_clueOrder.length}'
                : 'Level 3 complete! Your score: $score/${_clueOrder.length}',
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
    final user = _authService.currentUser;

    Widget bodyContent;
    if (_isLoading) {
      bodyContent = const Center(child: CircularProgressIndicator());
    } else if (_timerNotStarted) {
      bodyContent = const Center(
        child: Text(
          "Waiting for the admin to start the timer...",
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
      );
    } else if (_clueOrder.isEmpty || _allClues['starting_point'] == null) {
      bodyContent = const Center(
        child: Text(
          "Level 3 is not yet configured by the admin.",
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
      );
    } else {
      bodyContent = StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('teams')
            .doc(user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final progressData =
              snapshot.data!.data() as Map<String, dynamic>? ?? {};
          final level3Progress =
              progressData['level3Progress'] as Map<String, dynamic>?;

          if (level3Progress == null) {
            // --- THE FIX: Pass the persistent controller to the build method ---
            return _buildQuestionScreen(
              _allClues['starting_point']!,
              _initialAnswerController,
            );
          }

          final currentClueId = level3Progress['currentClueId'] as String;
          if (currentClueId == 'completed') {
            return const Center(
              child: Text(
                "Congratulations!",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            );
          }

          final currentClue = _allClues[currentClueId]!;
          final lastSolvedId = (level3Progress['solved'] as List).last;
          final lastSolvedClue = _allClues[lastSolvedId]!;

          return _buildScanScreen(currentClue, lastSolvedClue);
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Level 3: The Final Chase'),
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
        child: bodyContent,
      ),
    );
  }

  // --- THE FIX: Accept the controller as a parameter ---
  Widget _buildQuestionScreen(
    Level3Clue clue,
    TextEditingController answerController,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            Text(
              clue.departmentName,
              textAlign: TextAlign.center,
              style: GoogleFonts.cinzel(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(75),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                clue.question,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.white70),
              ),
            ),
            const SizedBox(height: 40),
            TextField(
              // --- THE FIX: Use the passed-in controller ---
              controller: answerController,
              decoration: const InputDecoration(labelText: 'Your Answer'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              // --- THE FIX: Read the text from the passed-in controller ---
              onPressed: () =>
                  _handleStartingPointAnswer(answerController.text),
              child: const Text('Submit Answer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanScreen(Level3Clue currentClue, Level3Clue lastSolvedClue) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Location Confirmed: ${lastSolvedClue.departmentName}',
            textAlign: TextAlign.center,
            style: GoogleFonts.cinzel(fontSize: 16, color: Colors.greenAccent),
          ),
          const Divider(
            color: Colors.white24,
            height: 40,
            indent: 40,
            endIndent: 40,
          ),
          Text(
            'YOUR NEXT DESTINATION:',
            textAlign: TextAlign.center,
            style: GoogleFonts.cinzel(fontSize: 22, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(75),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              lastSolvedClue.nextClueLocationHint,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white70,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Scan QR at Location'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () => _scanQRCode(currentClue),
          ),
        ],
      ),
    );
  }
}
