// ===============================
// FILE NAME: level3_leaderboard_view.dart
// FILE PATH: C:\treasurehunt\treasure_huntjo\treasure_hunt_app\lib\screens\game_panel\level3_leaderboard_view.dart
// ===============================

// ignore_for_file: use_build_context_synchronously

import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:treasure_hunt_app/models/team_model.dart';
import 'package:treasure_hunt_app/services/auth_service.dart';

class Level3LeaderboardView extends StatefulWidget {
  final bool isAdminView;
  const Level3LeaderboardView({super.key, this.isAdminView = false});

  @override
  State<Level3LeaderboardView> createState() => _Level3LeaderboardViewState();
}

class _Level3LeaderboardViewState extends State<Level3LeaderboardView> {
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
          .doc('level3_timer') // Correct timer doc
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
      debugPrint("Error fetching Lvl 3 timer start time: $e");
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
            'Are you sure you want to reset the Level 3 leaderboard? This will delete all scores and submission times for this level. This action cannot be undone.',
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
          .where('level3Submission', isNotEqualTo: null) // Correct field
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
        batch.update(doc.reference, {
          'level3Submission': FieldValue.delete(),
        }); // Correct field
      }
      await batch.commit();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Level 3 leaderboard has been reset.'),
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
        title: const Text('Level 3 Leaderboard'),
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
                      .where(
                        'level3Submission',
                        isNotEqualTo: null,
                      ) // Correct field
                      .orderBy('level3Submission.score', descending: true)
                      .orderBy('level3Submission.submittedAt')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No submissions yet for Level 3.',
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
                        final submission = team.level3Submission!;
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
                                                  _Level3TeamDetailsScreen(
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

// =======================================================================
// A simpler details screen for Level 3
// =======================================================================
class _Level3TeamDetailsScreen extends StatelessWidget {
  final Team team;
  const _Level3TeamDetailsScreen({required this.team});

  @override
  Widget build(BuildContext context) {
    final submission = team.level3Submission!;
    final submittedAt = (submission['submittedAt'] as Timestamp).toDate();

    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('${team.teamName} - Lvl 3'),
          backgroundColor: Colors.black,
        ),
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                color: Colors.grey[900],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Icon(
                            Icons.scoreboard_outlined,
                            color: Colors.amber,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          const Text('Final Score'),
                          const SizedBox(height: 4),
                          Text(
                            '${submission['score']}/${submission['totalQuestions']}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            color: Colors.amber,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          const Text('Submitted At'),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('MMM d, hh:mm a').format(submittedAt),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Level 3 is a sequential QR hunt. The score reflects the number of clues successfully solved before the time expired.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
