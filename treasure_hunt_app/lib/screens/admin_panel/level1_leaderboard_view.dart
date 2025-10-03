import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:treasure_hunt_app/models/quiz_model.dart';
import 'package:treasure_hunt_app/models/team_model.dart';

class Level1LeaderboardView extends StatefulWidget {
  const Level1LeaderboardView({super.key});

  @override
  State<Level1LeaderboardView> createState() => _Level1LeaderboardViewState();
}

class _Level1LeaderboardViewState extends State<Level1LeaderboardView> {
  // A list to hold all the questions for answer checking.
  List<QuizQuestion> _questions = [];
  bool _isLoadingQuestions = true;
  // A state variable to show a loading indicator while resetting.
  bool _isResetting = false;

  @override
  void initState() {
    super.initState();
    // Fetch the quiz questions once when the screen loads.
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

  // This function handles the logic for resetting all scores.
  Future<void> _resetLeaderboard() async {
    // First, show a confirmation dialog to prevent accidental resets.
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

    // If the admin doesn't confirm, do nothing.
    if (confirmed != true) return;

    setState(() => _isResetting = true);

    try {
      final firestore = FirebaseFirestore.instance;
      // Get all teams that have a submission field.
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

      // Use a batch write for efficiency. It updates all documents in one go.
      final batch = firestore.batch();

      for (final doc in teamsWithSubmissions.docs) {
        // For each team, update their document to remove the 'level1Submission' field.
        batch.update(doc.reference, {'level1Submission': FieldValue.delete()});
      }

      // Commit all the updates to the database.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Level 1 Leaderboard'),
        // The reset button is in the top-right corner of the AppBar.
        actions: [
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
        ],
      ),
      body: _isLoadingQuestions
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              // This stream listens for real-time updates to the leaderboard.
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
                  return const Center(
                    child: Text('No teams have completed Level 1 yet.'),
                  );
                }

                final teams = snapshot.data!.docs
                    .map(
                      (doc) => Team.fromMap(doc.data() as Map<String, dynamic>),
                    )
                    .toList();

                return ListView.builder(
                  itemCount: teams.length,
                  itemBuilder: (context, index) {
                    final team = teams[index];
                    final rank = index + 1;
                    final submission = team.level1Submission!;
                    final score = submission['score'];
                    final total = submission['totalQuestions'];
                    final submittedAt = (submission['submittedAt'] as Timestamp)
                        .toDate();
                    final formattedTime = DateFormat(
                      'MMM d, yyyy - hh:mm a',
                    ).format(submittedAt);

                    final teamAnswers =
                        (submission['answers'] as Map<String, dynamic>).map(
                          (key, value) =>
                              MapEntry(int.parse(key), value as int),
                        );

                    // ExpansionTile allows the admin to tap a team to see details.
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: ExpansionTile(
                        leading: CircleAvatar(child: Text('$rank')),
                        title: Text(
                          team.teamName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: Text(
                          'Score: $score/$total',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Submitted: $formattedTime',
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const Divider(height: 20),
                                const Text(
                                  'Answers:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                // Generate a list showing each answer's correctness.
                                ...List.generate(_questions.length, (qIndex) {
                                  if (qIndex >= _questions.length) {
                                    return const SizedBox.shrink(); // Safety check
                                  }
                                  final question = _questions[qIndex];
                                  final teamAnswerIndex = teamAnswers[qIndex];
                                  final correctAnswerIndex =
                                      question.correctAnswerIndex;
                                  final isCorrect =
                                      teamAnswerIndex == correctAnswerIndex;

                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${qIndex + 1}. ${question.questionText}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          'Selected: ${teamAnswerIndex != null ? question.options[teamAnswerIndex] : "Not Answered"}',
                                          style: TextStyle(
                                            color: isCorrect
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),
                                        if (!isCorrect)
                                          Text(
                                            'Correct: ${question.options[correctAnswerIndex]}',
                                            style: const TextStyle(
                                              color: Colors.green,
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
