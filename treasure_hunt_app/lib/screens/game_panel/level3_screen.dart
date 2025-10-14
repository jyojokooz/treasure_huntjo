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
    _initializeLevel();
  }

  @override
  void dispose() {
    _timerSubscription?.cancel();
    _countdownTimer?.cancel();
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
      // THE FIX: Get the ordered list of clues from the admin settings.
      final clueOrderFromAdmin = List<String>.from(
        settingsDoc.data()?['clueOrder'] ?? [],
      );

      if (clueOrderFromAdmin.isEmpty) {
        if (mounted) {
          setState(() => _clueOrder = []);
        }
        return;
      }

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
              if (!_isSubmitting) {
                _submitScore(autoSubmitted: true);
              }
            } else if (mounted) {
              setState(() => _timeLeft = Duration(seconds: secondsLeft));
            }
          });
        } else {
          setState(() => _timeLeft = Duration.zero);
          if (!_isSubmitting) {
            _submitScore(autoSubmitted: true);
          }
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

  // --- NEW LOGIC for handling the sequential game flow ---

  Future<void> _scanQRCode(
    Level3Clue clueToScan, {
    bool isInitialScan = false,
  }) async {
    final scannedValue = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    );
    if (scannedValue == null) return;

    if (scannedValue == clueToScan.qrCodeValue) {
      if (isInitialScan) {
        // If it's the first scan, create the progress tracker for the team
        final user = _authService.currentUser;
        if (user == null) return;
        await FirebaseFirestore.instance
            .collection('teams')
            .doc(user.uid)
            .update({
              'level3Progress': {
                'solved': [],
                'currentClueId': _clueOrder.first,
              },
            });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You have begun! Find your first destination.'),
            backgroundColor: Colors.blue,
          ),
        );
      } else {
        // For all other scans, show the question dialog
        _showQuestionDialog(clueToScan);
      }
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

    // Use a transaction to safely read and update the team's progress
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final teamSnapshot = await transaction.get(teamRef);
      final currentProgress =
          teamSnapshot.data()?['level3Progress'] as Map<String, dynamic>? ?? {};
      final solvedClues = List<String>.from(currentProgress['solved'] ?? []);

      if (!solvedClues.contains(solvedClueId)) {
        solvedClues.add(solvedClueId);
      }

      final nextClueIndex = _clueOrder.indexOf(solvedClueId) + 1;

      if (nextClueIndex >= _clueOrder.length) {
        // Last clue solved
        transaction.update(teamRef, {
          'level3Progress.solved': solvedClues,
          'level3Progress.currentClueId': 'completed',
        });
      } else {
        // Move to the next clue
        transaction.update(teamRef, {
          'level3Progress.solved': solvedClues,
          'level3Progress.currentClueId': _clueOrder[nextClueIndex],
        });
      }
    });

    final nextClueIndex = _clueOrder.indexOf(solvedClueId) + 1;
    if (nextClueIndex >= _clueOrder.length) {
      _submitScore(autoSubmitted: false); // Finished the hunt
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

    final teamSnapshot = await FirebaseFirestore.instance
        .collection('teams')
        .doc(user.uid)
        .get();
    final solvedClues = List<String>.from(
      teamSnapshot.data()?['level3Progress']?['solved'] ?? [],
    );

    final submissionData = {
      'score': solvedClues.length,
      'totalQuestions': _clueOrder.length,
      'submittedAt': Timestamp.now(),
    };

    await FirebaseFirestore.instance.collection('teams').doc(user.uid).update({
      'level3Submission': submissionData,
    });

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            autoSubmitted
                ? 'Time is up! Your final score: ${solvedClues.length}/${_clueOrder.length}'
                : 'Level 3 complete! Your score: ${solvedClues.length}/${_clueOrder.length}',
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
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Error: Not logged in")));
    }

    bool canPlay = !_isLoading && !_timerNotStarted && _clueOrder.isNotEmpty;

    if (!_isLoading && _clueOrder.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Level 3: The Final Chase'),
          backgroundColor: Colors.transparent,
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/quiz_background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: const Center(
            child: Text(
              "Level 3 is not yet configured by the admin.",
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
          ),
        ),
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
        child: canPlay
            ? StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('teams')
                    .doc(user.uid)
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
                    // State 1: User has not started Level 3 yet
                    final initialClue = _allClues[_clueOrder.first]!;
                    return _buildInitialScanScreen(initialClue);
                  }

                  final solvedClues = List<String>.from(
                    level3Progress['solved'] ?? [],
                  );
                  String currentClueId =
                      level3Progress['currentClueId'] ?? _clueOrder.first;

                  if (currentClueId == 'completed') {
                    // State 3: User has finished all clues
                    return const Center(
                      child: Text(
                        "Congratulations! You've finished Level 3.",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    );
                  }

                  // State 2: User is in the middle of the hunt
                  final currentClue = _allClues[currentClueId]!;
                  final lastSolvedDeptName = solvedClues.isEmpty
                      ? null
                      : _allClues[solvedClues.last]?.departmentName;

                  return _buildClueScreen(
                    solvedClues,
                    currentClue,
                    lastSolvedDeptName,
                  );
                },
              )
            : Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(
                        _timerNotStarted
                            ? "Waiting for the admin to start the timer..."
                            : "No active departments configured for Level 3.",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                        ),
                      ),
              ),
      ),
    );
  }

  // --- Helper Widgets to build different UI states ---

  Widget _buildInitialScanScreen(Level3Clue initialClue) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Level 3 Begins',
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
              color: Colors.black.withAlpha((0.3 * 255).round()),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "Proceed to the starting location and scan the first QR code to begin your final chase!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withAlpha((0.7 * 255).round()),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Scan to Begin'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () => _scanQRCode(initialClue, isInitialScan: true),
          ),
        ],
      ),
    );
  }

  Widget _buildClueScreen(
    List<String> solvedClues,
    Level3Clue currentClue,
    String? lastSolvedDeptName,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Clue ${solvedClues.length + 1}/${_clueOrder.length}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Show the location they just confirmed
          if (lastSolvedDeptName != null) ...[
            Text(
              'LOCATION CONFIRMED:',
              textAlign: TextAlign.center,
              style: GoogleFonts.cinzel(
                fontSize: 16,
                color: Colors.greenAccent,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              lastSolvedDeptName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(
              color: Colors.white24,
              height: 40,
              indent: 40,
              endIndent: 40,
            ),
          ],

          // Show the hint for the NEXT location
          Text(
            solvedClues.isEmpty
                ? 'YOUR FIRST DESTINATION:'
                : 'YOUR NEXT DESTINATION:',
            textAlign: TextAlign.center,
            style: GoogleFonts.cinzel(fontSize: 22, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha((0.3 * 255).round()),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _allClues[_clueOrder[solvedClues.length]]?.nextClueLocationHint ??
                  "Error: Hint not found.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withAlpha((0.7 * 255).round()),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Scan QR Code'),
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
