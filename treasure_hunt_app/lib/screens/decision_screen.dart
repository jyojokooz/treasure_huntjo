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

        if (team.role == 'admin') {
          return const AdminDashboard();
        }

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

            if (isGameFinished) {
              return const WinnerAnnouncementScreen();
            }

            switch (team.status) {
              case 'approved':
                // --- THE FIX ---
                // Removed the ValueKey. We now pass the initial team data,
                // and the dashboard will handle its own updates via a direct stream.
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
