// ===============================
// FILE NAME: gamer_dashboard.dart
// FILE PATH: C:\treasurehunt\treasure_huntjo\treasure_hunt_app\lib\screens\gamer_dashboard.dart
// ===============================

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:treasure_hunt_app/models/team_model.dart';
import 'package:treasure_hunt_app/screens/game_panel/clues_view.dart';
import 'package:treasure_hunt_app/screens/game_panel/leaderboard_hub_view.dart';
import 'package:treasure_hunt_app/screens/game_panel/team_view.dart';
import 'package:treasure_hunt_app/services/auth_service.dart';
import 'package:treasure_hunt_app/services/firestore_service.dart';
import 'package:treasure_hunt_app/widgets/game_nav_bar.dart';

class GamerDashboard extends StatefulWidget {
  final Team team;
  const GamerDashboard({super.key, required this.team});

  @override
  State<GamerDashboard> createState() => _GamerDashboardState();
}

class _GamerDashboardState extends State<GamerDashboard> {
  int _selectedIndex = 0;

  late Team _currentTeam;
  final AuthService _auth = AuthService();
  final FirestoreService _firestore = FirestoreService();

  StreamSubscription? _teamSubscription;
  StreamSubscription? _gameSettingsSubscription;

  bool _hasShownLevel2Rejection = false;
  bool _hasShownLevel3Rejection = false;

  @override
  void initState() {
    super.initState();
    _currentTeam = widget.team;

    _listenForTeamUpdates();
    _listenForAnnouncements();
  }

  void _listenForTeamUpdates() {
    final user = _auth.currentUser;
    if (user == null) return;

    _teamSubscription = _firestore.streamTeam(user.uid).listen((newTeamData) {
      if (!mounted || newTeamData == null) return;

      if (!_currentTeam.isEligibleForLevel2 &&
          newTeamData.isEligibleForLevel2) {
        _showPromotionDialog(2);
      }
      if (!_currentTeam.isEligibleForLevel3 &&
          newTeamData.isEligibleForLevel3) {
        _showPromotionDialog(3);
      }

      setState(() {
        _currentTeam = newTeamData;
      });
    });
  }

  // --- THIS METHOD CONTAINS THE FIX ---
  void _listenForAnnouncements() {
    _gameSettingsSubscription = FirebaseFirestore.instance
        .collection('game_settings')
        .doc('levels')
        .snapshots()
        .listen((snapshot) {
          if (!mounted || !snapshot.exists) return;

          final data = snapshot.data() as Map<String, dynamic>;
          final bool lvl2Announced = data['level2PromotionsComplete'] ?? false;
          final bool lvl3Announced = data['level3PromotionsComplete'] ?? false;

          // --- Level 2 Logic ---
          if (lvl2Announced) {
            // If announcements are active, check if we need to show the rejection popup.
            if (!_currentTeam.isEligibleForLevel2 &&
                !_hasShownLevel2Rejection) {
              setState(() => _hasShownLevel2Rejection = true);
              _showRejectionDialog(2);
            }
          } else {
            // If announcements have been reset by the admin, we must also reset our local flag.
            if (_hasShownLevel2Rejection) {
              setState(() => _hasShownLevel2Rejection = false);
            }
          }

          // --- Level 3 Logic (same pattern) ---
          if (lvl3Announced) {
            // If announcements are active, check for rejection.
            if (!_currentTeam.isEligibleForLevel3 &&
                !_hasShownLevel3Rejection) {
              setState(() => _hasShownLevel3Rejection = true);
              _showRejectionDialog(3);
            }
          } else {
            // If announcements are reset, reset our local flag.
            if (_hasShownLevel3Rejection) {
              setState(() => _hasShownLevel3Rejection = false);
            }
          }
        });
  }

  void _showPromotionDialog(int level) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Congratulations!'),
        content: Text(
          'Your team has been promoted to Level $level! The next challenge is now unlocked.',
        ),
        actions: [
          TextButton(
            child: const Text('Awesome!'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showRejectionDialog(int level) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Level $level Update'),
        content: const Text(
          'The results are in. Unfortunately, your team was not selected to advance to the next level this time. Thank you for participating!',
        ),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _teamSubscription?.cancel();
    _gameSettingsSubscription?.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      CluesView(team: _currentTeam),
      const LeaderboardHubView(),
      TeamView(team: _currentTeam),
    ];

    return Scaffold(
      extendBody: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      extendBodyBehindAppBar: true,
      bottomNavigationBar: GameNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/dashboard_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                Expanded(
                  child: IndexedStack(index: _selectedIndex, children: pages),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 100.0),
                  child: TextButton.icon(
                    icon: Icon(Icons.exit_to_app, color: Colors.red.shade300),
                    label: Text(
                      'Forfeit',
                      style: TextStyle(
                        color: Colors.red.shade300,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    onPressed: () => _auth.signOut(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
