// ===============================
// FILE NAME: winner_announcement_screen.dart
// FILE PATH: C:\treasurehunt\treasure_huntjo\treasure_hunt_app\lib\screens\winner_announcement_screen.dart
// ===============================

// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:treasure_hunt_app/models/team_model.dart';
import 'package:treasure_hunt_app/services/auth_service.dart';
import 'package:treasure_hunt_app/services/music_service.dart';

class WinnerAnnouncementScreen extends StatefulWidget {
  const WinnerAnnouncementScreen({super.key});

  @override
  State<WinnerAnnouncementScreen> createState() =>
      _WinnerAnnouncementScreenState();
}

class _WinnerAnnouncementScreenState extends State<WinnerAnnouncementScreen> {
  late ConfettiController _confettiController;
  late Future<List<Team>> _winnersFuture;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 15),
    );
    _winnersFuture = _fetchWinners();
    _playVictorySequence();
  }

  void _playVictorySequence() {
    // Play the confetti animation
    _confettiController.play();
    // Stop background music and play a victory sound
    MusicService.instance.pauseBackgroundMusic();
    MusicService.instance.playVictoryFanfare(); // We will add this method
  }

  Future<List<Team>> _fetchWinners() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('teams')
        .where('level3Submission', isNotEqualTo: null)
        .orderBy('level3Submission.score', descending: true)
        .orderBy('level3Submission.submittedAt')
        .get();

    return snapshot.docs.map((doc) => Team.fromMap(doc.data())).toList();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Image.asset(
            'assets/images/winner_background.png',
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          // Dark Overlay
          Container(color: Colors.black.withOpacity(0.6)),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: Text(
                    'TREASURE HUNT\nCHAMPIONS',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cinzel(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(color: Colors.amber.shade700, blurRadius: 20),
                        const Shadow(
                          color: Colors.black,
                          blurRadius: 5,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<Team>>(
                    future: _winnersFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text(
                            'Awaiting Final Results...',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                            ),
                          ),
                        );
                      }

                      final winners = snapshot.data!;
                      return CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 30.0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (winners.length > 1)
                                    _buildPodium(winners[1], 2),
                                  if (winners.isNotEmpty)
                                    _buildPodium(winners[0], 1),
                                  if (winners.length > 2)
                                    _buildPodium(winners[2], 3),
                                ],
                              ),
                            ),
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final teamIndex = index + 3;
                              if (teamIndex >= winners.length) return null;
                              return _buildRankTile(
                                winners[teamIndex],
                                teamIndex + 1,
                              );
                            }, childCount: winners.length - 3),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ElevatedButton(
                    onPressed: () => AuthService().signOut(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    child: const Text('Logout'),
                  ),
                ),
              ],
            ),
          ),
          // Confetti Animation Layer
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodium(Team team, int rank) {
    final double height = rank == 1 ? 160 : (rank == 2 ? 130 : 110);
    final Color color = rank == 1
        ? Colors.amber
        : (rank == 2 ? Colors.grey.shade400 : Colors.brown.shade400);

    return Container(
      padding: const EdgeInsets.all(8),
      height: height,
      width: MediaQuery.of(context).size.width * 0.28,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(Icons.emoji_events, color: color, size: 40),
          const SizedBox(height: 8),
          Text(
            team.teamName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            "Score: ${team.level3Submission?['score'] ?? 0}",
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildRankTile(Team team, int rank) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            '$rank.',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              team.teamName,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          Text(
            "Score: ${team.level3Submission?['score'] ?? 0}",
            style: const TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
