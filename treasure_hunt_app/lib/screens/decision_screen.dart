// ===============================
// FILE NAME: decision_screen.dart
// FILE PATH: C:\treasurehunt\treasure_huntjo\treasure_hunt_app\lib\screens\decision_screen.dart
// ===============================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:treasure_hunt_app/models/team_model.dart';
import 'package:treasure_hunt_app/screens/admin_dashboard.dart';
import 'package:treasure_hunt_app/screens/gamer_dashboard.dart';
import 'package:treasure_hunt_app/screens/pending_screen.dart';
import 'package:treasure_hunt_app/screens/winner_announcement_screen.dart';
import 'package:treasure_hunt_app/services/auth_service.dart';
import 'package:treasure_hunt_app/services/firestore_service.dart';

class DecisionScreen extends StatelessWidget {
  const DecisionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService auth = AuthService();
    final FirestoreService firestoreService = FirestoreService();
    final user = auth.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Error: No user found.')));
    }

    // --- THE FIX IS HERE: The logic has been restructured ---
    // We now fetch the user's team data FIRST, because their role is the highest priority.
    return StreamBuilder<Team?>(
      stream: firestoreService.streamTeam(user.uid),
      builder: (context, teamSnapshot) {
        if (teamSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (teamSnapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${teamSnapshot.error}')),
          );
        }

        if (!teamSnapshot.hasData || teamSnapshot.data == null) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search_off, size: 80, color: Colors.grey),
                    const SizedBox(height: 20),
                    const Text(
                      'Your team data was not found.',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      onPressed: () => auth.signOut(),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final team = teamSnapshot.data!;

        // 1. HIGHEST PRIORITY CHECK: Is the user an admin?
        // If yes, always show the admin dashboard, regardless of game state.
        if (team.role == 'admin') {
          return const AdminDashboard();
        }

        // 2. If not an admin, THEN we check the game's overall state.
        // This StreamBuilder is now nested inside the player's logic path.
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('game_settings')
              .doc('levels')
              .snapshots(),
          builder: (context, gameSettingsSnapshot) {
            if (gameSettingsSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final data =
                gameSettingsSnapshot.data?.data() as Map<String, dynamic>?;
            final bool isGameFinished = data?['isGameFinished'] ?? false;

            // 2a. If the game is finished, show players the winner screen.
            if (isGameFinished) {
              return const WinnerAnnouncementScreen();
            }

            // 2b. If the game is NOT finished, proceed with the normal player status checks.
            switch (team.status) {
              case 'approved':
                return GamerDashboard(team: team);
              case 'pending':
                return PendingScreen(teamName: team.teamName);
              case 'rejected':
                return Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.cancel_outlined,
                          color: Colors.red,
                          size: 80,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Your Team Registration Was Rejected',
                          style: TextStyle(fontSize: 20),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          child: const Text('Logout'),
                          onPressed: () => auth.signOut(),
                        ),
                      ],
                    ),
                  ),
                );
              default:
                return const Scaffold(
                  body: Center(child: Text('Unknown status.')),
                );
            }
          },
        );
      },
    );
  }
}
