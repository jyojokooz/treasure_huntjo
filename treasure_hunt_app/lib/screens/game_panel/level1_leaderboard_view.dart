// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:treasure_hunt_app/models/quiz_model.dart';
import 'package:treasure_hunt_app/models/team_model.dart';

class Level1LeaderboardView extends StatefulWidget {
  // A boolean to determine if the view is for an admin.
  // Defaults to false, making it safe to use for players.
  final bool isAdminView;

  const Level1LeaderboardView({super.key, this.isAdminView = false});

  @override
  State<Level1LeaderboardView> createState() => _Level1LeaderboardViewState();
}

class _Level1LeaderboardViewState extends State<Level1LeaderboardView> {
  List<QuizQuestion> _questions = [];
  bool _isLoadingQuestions = true;
  bool _isResetting = false;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  // Fetches all Level 1 questions from Firestore to compare against team answers.
  Future<void> _fetchQuestions() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('quizzes')
          .doc('level1')
          .collection('questions')
          .get();
      if (mounted) {
        setState(() {
          _questions = snapshot.docs
              .map((doc) => QuizQuestion.fromMap(doc.data()))
              .toList();
          _isLoadingQuestions = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load questions: $e')));
        setState(() => _isLoadingQuestions = false);
      }
    }
  }

  // Handles the logic for resetting all scores after confirmation.
  Future<void> _resetLeaderboard() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Reset'),
        content: const Text(
          'Are you sure you want to reset the Level 1 Leaderboard? This will delete all scores and submission times for all teams, allowing them to play again. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isResetting = true);

    try {
      final firestore = FirebaseFirestore.instance;
      final teamsWithSubmissions = await firestore
          .collection('teams')
          .where('level1Submission', isNotEqualTo: null)
          .get();

      if (teamsWithSubmissions.docs.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('No scores to reset.')));
        }
        setState(() => _isResetting = false);
        return;
      }

      final batch = firestore.batch();
      for (final doc in teamsWithSubmissions.docs) {
        batch.update(doc.reference, {'level1Submission': FieldValue.delete()});
      }
      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Leaderboard has been reset successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error resetting leaderboard: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResetting = false);
      }
    }
  }

  // --- UI Helper Widgets ---

  Widget _buildRankWidget(int rank) {
    switch (rank) {
      case 1:
        return const CircleAvatar(
          backgroundColor: Colors.amber,
          child: Icon(Icons.emoji_events, color: Colors.white),
        );
      case 2:
        return CircleAvatar(
          backgroundColor: Colors.grey.shade400,
          child: const Icon(Icons.emoji_events, color: Colors.white),
        );
      case 3:
        return CircleAvatar(
          backgroundColor: Colors.brown.shade400,
          child: const Icon(Icons.emoji_events, color: Colors.white),
        );
      default:
        return CircleAvatar(
          // ignore: duplicate_ignore
          // ignore: deprecated_member_use
          backgroundColor: Colors.white.withOpacity(0.2),
          child: Text(
            '$rank',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
    }
  }

  Widget _buildExpansionDetails(Map<String, dynamic> submission) {
    final score = submission['score'];
    final total = submission['totalQuestions'];
    final submittedAt = (submission['submittedAt'] as Timestamp).toDate();
    final formattedTime = DateFormat('MMM d, hh:mm a').format(submittedAt);
    final teamAnswers = (submission['answers'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(int.parse(key), value as int),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  Icons.scoreboard_outlined,
                  'Score',
                  '$score/$total',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatCard(
                  Icons.timer_outlined,
                  'Submitted',
                  formattedTime,
                ),
              ),
            ],
          ),
          const Divider(height: 30, color: Colors.white24),
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

  Widget _buildStatCard(IconData icon, String label, String value) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, color: Colors.amber, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
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
                  style: TextStyle(color: Colors.white.withOpacity(0.9)),
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
      appBar: AppBar(
        title: const Text('Level 1 Leaderboard'),
        // The AppBar background is transparent so it blends with any parent widget.
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Conditionally show the reset button ONLY if it's the admin view.
        actions: widget.isAdminView
            ? [
                if (_isResetting)
                  const Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.delete_sweep_outlined),
                    tooltip: 'Reset Leaderboard',
                    onPressed: _resetLeaderboard,
                  ),
              ]
            : null, // No actions for the player view.
      ),
      // The background is only applied if it's the admin's standalone view.
      // For players, it's transparent, letting the dashboard's background show through.
      backgroundColor: widget.isAdminView
          ? const Color(0xFF141E30)
          : Colors.transparent,
      body: Container(
        // For the admin view, we add a gradient to match the app bar.
        // For the player view, this container is effectively invisible.
        decoration: widget.isAdminView
            ? const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF141E30), Color(0xFF243B55)],
                ),
              )
            : null,
        child: _isLoadingQuestions
            ? const Center(child: CircularProgressIndicator())
            : StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('teams')
                    .where('level1Submission', isNotEqualTo: null)
                    .orderBy('level1Submission.score', descending: true)
                    .orderBy('level1Submission.submittedAt')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No teams have completed Level 1 yet.',
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
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
                    padding: const EdgeInsets.all(8.0),
                    itemCount: teams.length,
                    itemBuilder: (context, index) {
                      final team = teams[index];
                      final rank = index + 1;
                      final submission = team.level1Submission!;

                      return Card(
                        color: Colors.white.withOpacity(0.1),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: ExpansionTile(
                          leading: _buildRankWidget(rank),
                          title: Text(
                            team.teamName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          trailing: Text(
                            'Score: ${submission['score']}/${submission['totalQuestions']}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.amber,
                            ),
                          ),
                          iconColor: Colors.white54,
                          collapsedIconColor: Colors.white54,
                          children: [_buildExpansionDetails(submission)],
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
