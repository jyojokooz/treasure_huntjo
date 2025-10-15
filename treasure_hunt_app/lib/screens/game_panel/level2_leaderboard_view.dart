// ===============================
// FILE NAME: level2_leaderboard_view.dart
// FILE PATH: C:\treasurehunt\treasure_huntjo\treasure_hunt_app\lib\screens\game_panel\level2_leaderboard_view.dart
// ===============================

// ignore_for_file: use_build_context_synchronously

import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:treasure_hunt_app/models/puzzle_model.dart';
import 'package:treasure_hunt_app/models/team_model.dart';
import 'package:treasure_hunt_app/services/auth_service.dart';

class Level2LeaderboardView extends StatefulWidget {
  final bool isAdminView;
  const Level2LeaderboardView({super.key, this.isAdminView = false});

  @override
  State<Level2LeaderboardView> createState() => _Level2LeaderboardViewState();
}

class _Level2LeaderboardViewState extends State<Level2LeaderboardView> {
  DateTime? _timerStartTime;
  bool _isLoadingInitialData = true;
  final AuthService _authService = AuthService();
  String? _currentUserTeamId;

  @override
  void initState() {
    super.initState();
    _currentUserTeamId = _authService.currentUser?.uid;
    _fetchTimerStartTime();
  }

  // --- Data Fetching and Reset Logic ---

  Future<void> _fetchTimerStartTime() async {
    try {
      final timerDoc = await FirebaseFirestore.instance
          .collection('game_settings')
          .doc('level2_timer')
          .get();
      if (timerDoc.exists) {
        final data = timerDoc.data()!;
        final endTime = (data['endTime'] as Timestamp?)?.toDate();
        final duration = data['durationMinutes'] as int?;
        if (endTime != null && duration != null) {
          if (mounted) {
            setState(() {
              _timerStartTime = endTime.subtract(Duration(minutes: duration));
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching Lvl 2 timer start time: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoadingInitialData = false);
      }
    }
  }

  Future<void> _showResetConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Reset'),
          content: const Text(
            'Are you sure you want to reset the Level 2 leaderboard? This will delete all scores and submission times for this level. This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Reset'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _resetLeaderboard();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _resetLeaderboard() async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Resetting leaderboard...')));
    try {
      final teamsWithSubmissions = await FirebaseFirestore.instance
          .collection('teams')
          .where('level2Submission', isNotEqualTo: null)
          .get();
      if (teamsWithSubmissions.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No submissions found to reset.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      final batch = FirebaseFirestore.instance.batch();
      for (final doc in teamsWithSubmissions.docs) {
        batch.update(doc.reference, {'level2Submission': FieldValue.delete()});
      }
      await batch.commit();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Level 2 leaderboard has been reset.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // --- UI Helper Widgets ---

  String _formatDuration(Duration duration) {
    if (duration <= Duration.zero) return '--:--';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Widget _buildRankWidget(int rank) {
    Color color;
    IconData icon = Icons.military_tech;
    if (rank == 1) {
      color = Colors.amber;
      icon = Icons.emoji_events;
    } else if (rank == 2) {
      color = Colors.grey.shade400;
    } else if (rank == 3) {
      color = Colors.brown.shade400;
    } else {
      return CircleAvatar(
        radius: 22,
        backgroundColor: Colors.white.withAlpha((0.1 * 255).round()),
        child: Text(
          '$rank',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    return CircleAvatar(
      radius: 22,
      backgroundColor: color,
      child: Icon(icon, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Level 2 Leaderboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (widget.isAdminView)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Reset Leaderboard',
              onPressed: _showResetConfirmationDialog,
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/dashboard_background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: _isLoadingInitialData
              ? const Center(child: CircularProgressIndicator())
              : StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('teams')
                      .where('level2Submission', isNotEqualTo: null)
                      .orderBy('level2Submission.score', descending: true)
                      .orderBy('level2Submission.submittedAt')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No submissions yet for Level 2.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      );
                    }

                    final teams = snapshot.data!.docs
                        .map(
                          (doc) =>
                              Team.fromMap(doc.data() as Map<String, dynamic>),
                        )
                        .toList();

                    return ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: teams.length,
                      itemBuilder: (context, index) {
                        final team = teams[index];
                        final submission = team.level2Submission!;
                        final submittedAt =
                            (submission['submittedAt'] as Timestamp).toDate();
                        final timeTaken = _timerStartTime != null
                            ? submittedAt.difference(_timerStartTime!)
                            : Duration.zero;
                        final bool isCurrentUserTeam =
                            team.id == _currentUserTeamId;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(
                                    (0.1 * 255).round(),
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: isCurrentUserTeam
                                        ? Colors.amber
                                        : Colors.white.withAlpha(
                                            (0.2 * 255).round(),
                                          ),
                                    width: isCurrentUserTeam ? 2.0 : 1.0,
                                  ),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(15),
                                  onTap:
                                      (widget.isAdminView || isCurrentUserTeam)
                                      ? () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  _Level2TeamDetailsScreen(
                                                    team: team,
                                                  ),
                                            ),
                                          );
                                        }
                                      : null,
                                  child: ListTile(
                                    leading: _buildRankWidget(index + 1),
                                    title: Text(
                                      team.teamName,
                                      style: GoogleFonts.cinzel(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Time: ${_formatDuration(timeTaken)}',
                                      style: TextStyle(
                                        color: Colors.white.withAlpha(
                                          (0.7 * 255).round(),
                                        ),
                                      ),
                                    ),
                                    trailing: Text(
                                      'Score: ${submission['score']}/${submission['totalQuestions']}',
                                      style: const TextStyle(
                                        color: Colors.amber,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _Level2TeamDetailsScreen extends StatefulWidget {
  final Team team;
  const _Level2TeamDetailsScreen({required this.team});

  @override
  State<_Level2TeamDetailsScreen> createState() =>
      _Level2TeamDetailsScreenState();
}

class _Level2TeamDetailsScreenState extends State<_Level2TeamDetailsScreen> {
  late final Future<List<Puzzle>> _puzzlesFuture;

  @override
  void initState() {
    super.initState();
    _puzzlesFuture = _fetchAllPuzzles();
  }

  Future<List<Puzzle>> _fetchAllPuzzles() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('game_content/level2/puzzles')
        .get();
    return snapshot.docs.map((doc) => Puzzle.fromMap(doc.data())).toList();
  }

  @override
  Widget build(BuildContext context) {
    final submission = widget.team.level2Submission!;
    final submittedAt = (submission['submittedAt'] as Timestamp).toDate();
    final userAnswers = Map<String, String>.from(submission['answers'] ?? {});

    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Level 2 Breakdown'),
          backgroundColor: Colors.black,
        ),
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.grey[900],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.amber,
                        child: Icon(Icons.emoji_events, color: Colors.black),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          widget.team.teamName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'Score: ${submission['score']}/${submission['totalQuestions']}',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      color: Colors.grey[900],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.scoreboard_outlined,
                              color: Colors.amber,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            const Text('Score'),
                            const SizedBox(height: 4),
                            Text(
                              '${submission['score']}/${submission['totalQuestions']}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Card(
                      color: Colors.grey[900],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.timer_outlined,
                              color: Colors.amber,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            const Text('Submitted'),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('MMM d, hh:mm a').format(submittedAt),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Answer Breakdown',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(color: Colors.grey),
              FutureBuilder<List<Puzzle>>(
                future: _puzzlesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text("Could not load puzzle breakdown.");
                  }

                  final allPuzzles = snapshot.data!;
                  allPuzzles.sort(
                    // FIX: Changed scrambledWord to prompt for sorting
                    (a, b) => a.prompt.compareTo(b.prompt),
                  );

                  return Column(
                    children: List.generate(allPuzzles.length, (index) {
                      final puzzle = allPuzzles[index];
                      final userAnswer =
                          userAnswers[puzzle.id] ?? "Not Answered";
                      final isCorrect = userAnswer == puzzle.correctAnswer;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // FIX: Changed scrambledWord to prompt for display
                            Text('${index + 1}. Unscramble: ${puzzle.prompt}'),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  isCorrect
                                      ? Icons.check_circle_outline
                                      : Icons.highlight_off,
                                  color: isCorrect ? Colors.green : Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: Text('Selected: $userAnswer')),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
