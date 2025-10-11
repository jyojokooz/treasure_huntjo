// lib/screens/game_panel/level_leaderboard_view.dart

import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// FIX: Removed unused 'intl' import.
import 'package:treasure_hunt_app/models/quiz_model.dart';
import 'package:treasure_hunt_app/models/team_model.dart';

class LevelLeaderboardView extends StatefulWidget {
  final String levelId;
  const LevelLeaderboardView({super.key, required this.levelId});

  @override
  State<LevelLeaderboardView> createState() => _LevelLeaderboardViewState();
}

class _LevelLeaderboardViewState extends State<LevelLeaderboardView> {
  DateTime? _timerStartTime;
  List<QuizQuestion> _questions = [];
  bool _isLoadingInitialData = true;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    await _fetchTimerStartTime();
    await _fetchQuestions();
    if (mounted) {
      setState(() {
        _isLoadingInitialData = false;
      });
    }
  }

  Future<void> _fetchTimerStartTime() async {
    try {
      final timerDoc = await FirebaseFirestore.instance
          .collection('game_settings')
          .doc('${widget.levelId}_timer')
          .get();
      if (timerDoc.exists) {
        final data = timerDoc.data()!;
        final endTime = (data['endTime'] as Timestamp?)?.toDate();
        final duration = data['durationMinutes'] as int?;
        if (endTime != null && duration != null) {
          _timerStartTime = endTime.subtract(Duration(minutes: duration));
        }
      }
    } catch (e) {
      debugPrint("Error fetching timer start time: $e");
    }
  }

  Future<void> _fetchQuestions() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(widget.levelId)
          .collection('questions')
          .get();
      if (mounted) {
        _questions = snapshot.docs
            .map((doc) => QuizQuestion.fromMap(doc.data()))
            .toList();
      }
    } catch (e) {
      debugPrint("Error fetching questions: $e");
    }
  }

  String _formatDuration(Duration duration) {
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
        // FIX: Replaced deprecated withOpacity.
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

  Widget _buildExpansionDetails(Map<String, dynamic> submission) {
    final teamAnswers = (submission['answers'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(int.parse(key), value as int),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 20, color: Colors.white24),
          const Text(
            'Answer Breakdown',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ...List.generate(_questions.length, (qIndex) {
            if (qIndex >= _questions.length) return const SizedBox.shrink();

            final question = _questions[qIndex];
            final teamAnswerIndex = teamAnswers[qIndex];
            final correctAnswerIndex = question.correctAnswerIndex;
            return _buildAnswerDetailRow(
              qIndex,
              question,
              teamAnswerIndex,
              correctAnswerIndex,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAnswerDetailRow(
    int qIndex,
    QuizQuestion question,
    int? teamAnswerIndex,
    int correctAnswerIndex,
  ) {
    final isCorrect = teamAnswerIndex == correctAnswerIndex;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${qIndex + 1}. ${question.questionText}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.greenAccent : Colors.redAccent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Selected: ${teamAnswerIndex != null ? question.options[teamAnswerIndex] : "Not Answered"}',
                  // FIX: Replaced deprecated withOpacity.
                  style: TextStyle(
                    color: Colors.white.withAlpha((0.9 * 255).round()),
                  ),
                ),
              ),
            ],
          ),
          if (!isCorrect)
            Padding(
              padding: const EdgeInsets.only(top: 4.0, left: 28.0),
              child: Text(
                'Correct: ${question.options[correctAnswerIndex]}',
                style: const TextStyle(color: Colors.greenAccent),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Level ${widget.levelId.replaceAll('level', '')} Leaderboard',
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                      .where('${widget.levelId}Submission', isNotEqualTo: null)
                      .orderBy(
                        '${widget.levelId}Submission.score',
                        descending: true,
                      )
                      .orderBy('${widget.levelId}Submission.submittedAt')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          'No submissions yet for Level ${widget.levelId.replaceAll('level', '')}.',
                          style: const TextStyle(color: Colors.white70),
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
                        final submission = team.level1Submission!;
                        final submittedAt =
                            (submission['submittedAt'] as Timestamp).toDate();
                        final timeTaken = _timerStartTime != null
                            ? submittedAt.difference(_timerStartTime!)
                            : Duration.zero;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(
                                decoration: BoxDecoration(
                                  // FIX: Replaced deprecated withOpacity.
                                  color: Colors.white.withAlpha(
                                    (0.1 * 255).round(),
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                  // FIX: Replaced deprecated withOpacity.
                                  border: Border.all(
                                    color: Colors.white.withAlpha(
                                      (0.2 * 255).round(),
                                    ),
                                  ),
                                ),
                                child: ExpansionTile(
                                  leading: _buildRankWidget(index + 1),
                                  title: Text(
                                    team.teamName,
                                    style: GoogleFonts.cinzel(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  // FIX: Replaced deprecated withOpacity.
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
                                  iconColor: Colors.white54,
                                  collapsedIconColor: Colors.white54,
                                  children: [
                                    _buildExpansionDetails(submission),
                                  ],
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
