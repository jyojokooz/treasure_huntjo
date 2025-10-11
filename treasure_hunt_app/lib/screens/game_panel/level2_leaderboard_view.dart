// ===============================
// FILE NAME: level2_leaderboard_view.dart
// FILE PATH: C:\treasurehunt\treasure_huntjo\treasure_hunt_app\lib\screens\game_panel\level2_leaderboard_view.dart
// ===============================

import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:treasure_hunt_app/models/team_model.dart';

class Level2LeaderboardView extends StatefulWidget {
  const Level2LeaderboardView({super.key});

  @override
  State<Level2LeaderboardView> createState() => _Level2LeaderboardViewState();
}

class _Level2LeaderboardViewState extends State<Level2LeaderboardView> {
  DateTime? _timerStartTime;
  bool _isLoadingInitialData = true;

  @override
  void initState() {
    super.initState();
    _fetchTimerStartTime();
  }

  // Fetches the timer settings to calculate the start time of the level.
  // This is crucial for calculating how long each team took to finish.
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

  // Formats a Duration object into a "mm:ss" string.
  String _formatDuration(Duration duration) {
    if (duration == Duration.zero) return '--:--';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  // Creates a styled widget for the rank, with special icons for the top 3.
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
                  // Query for teams with Level 2 submissions, ordered by score then time.
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

                        // Calculate the time taken by the team.
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
                                  color: Colors.white.withAlpha(
                                    (0.1 * 255).round(),
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.white.withAlpha(
                                      (0.2 * 255).round(),
                                    ),
                                  ),
                                ),
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
