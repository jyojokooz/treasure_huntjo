import 'package:flutter/material.dart';
import 'package:treasure_hunt_app/models/team_model.dart';
// **NEW: Import the admin dashboard**
import 'package:treasure_hunt_app/screens/admin_dashboard.dart';
import 'package:treasure_hunt_app/screens/gamer_dashboard.dart';
import 'package:treasure_hunt_app/screens/pending_screen.dart';
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
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
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

        final team = snapshot.data!;

        // **NEW LOGIC: CHECK FOR ADMIN ROLE FIRST!**
        if (team.role == 'admin') {
          return const AdminDashboard();
        }

        // If not an admin, proceed with the normal user flow
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
            return const Scaffold(body: Center(child: Text('Unknown status.')));
        }
      },
    );
  }
}
