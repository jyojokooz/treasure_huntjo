// ===============================
// FILE NAME: leaderboard_hub_view.dart
// FILE PATH: C:\treasurehunt\treasure_huntjo\treasure_hunt_app\lib\screens\game_panel\leaderboard_hub_view.dart
// ===============================

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:treasure_hunt_app/screens/game_panel/level1_leaderboard_view.dart';
import 'package:treasure_hunt_app/screens/game_panel/level2_leaderboard_view.dart';

class LeaderboardHubView extends StatefulWidget {
  const LeaderboardHubView({super.key});

  @override
  State<LeaderboardHubView> createState() => _LeaderboardHubViewState();
}

class _LeaderboardHubViewState extends State<LeaderboardHubView> {
  // State variables to track if leaderboards have any content
  bool _hasLevel1Submissions = false;
  bool _hasLevel2Submissions = false;
  bool _isLoading = true;

  // Stream subscriptions to manage listeners
  StreamSubscription? _level1LeaderboardSub;
  StreamSubscription? _level2LeaderboardSub;

  @override
  void initState() {
    super.initState();
    _setupListeners();
  }

  void _setupListeners() {
    // Listener to check if the Level 1 Leaderboard is empty
    _level1LeaderboardSub = FirebaseFirestore.instance
        .collection('teams')
        .where('level1Submission', isNotEqualTo: null)
        .limit(
          1,
        ) // An efficient query to just check if at least one entry exists
        .snapshots()
        .listen((snapshot) {
          if (!mounted) return;
          setState(() {
            _hasLevel1Submissions = snapshot.docs.isNotEmpty;
            if (_isLoading) _isLoading = false; // Mark loading as complete
          });
        });

    // Listener to check if the Level 2 Leaderboard is empty
    _level2LeaderboardSub = FirebaseFirestore.instance
        .collection('teams')
        .where('level2Submission', isNotEqualTo: null)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
          if (!mounted) return;
          setState(() {
            _hasLevel2Submissions = snapshot.docs.isNotEmpty;
            if (_isLoading) _isLoading = false;
          });
        });
  }

  @override
  void dispose() {
    // Cancel all subscriptions to prevent memory leaks
    _level1LeaderboardSub?.cancel();
    _level2LeaderboardSub?.cancel();
    super.dispose();
  }

  // A reusable helper widget to create styled buttons
  Widget _buildLevelButton(
    BuildContext context,
    String title,
    Widget destinationPage,
    bool enabled,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled
              ? Colors.amber.shade700
              : Colors.grey.shade800,
          foregroundColor: enabled ? Colors.white : Colors.grey.shade500,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: enabled
            ? () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => destinationPage),
              )
            : null,
        child: Text(
          title,
          style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Leaderboards',
            textAlign: TextAlign.center,
            style: GoogleFonts.cinzel(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 10,
                  color: Colors.amber.withAlpha((0.7 * 255).round()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          // Show a loading indicator until the initial data is fetched
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // The button is enabled ONLY if there are submissions
                _buildLevelButton(
                  context,
                  'Level 1 Leaderboard',
                  const Level1LeaderboardView(),
                  _hasLevel1Submissions,
                ),
                _buildLevelButton(
                  context,
                  'Level 2 Leaderboard',
                  const Level2LeaderboardView(),
                  _hasLevel2Submissions,
                ),
                _buildLevelButton(
                  context,
                  'Level 3 Leaderboard',
                  const Scaffold(),
                  false,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
