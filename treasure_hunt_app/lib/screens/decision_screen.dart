import 'package:flutter/material.dart';
import 'package:treasure_hunt_app/models/team_model.dart';
import 'package:treasure_hunt_app/screens/gamer_dashboard.dart';
import 'package:treasure_hunt_app/screens/pending_screen.dart';
import 'package:treasure_hunt_app/services/auth_service.dart';
import 'package:treasure_hunt_app/services/firestore_service.dart';

class DecisionScreen extends StatelessWidget {
  const DecisionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // We can instantiate our services here to use them throughout the build method
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

        // **MODIFIED SECTION BELOW**
        if (!snapshot.hasData || snapshot.data == null) {
          // This is the screen that gets a new logout button.
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.search_off, // A more descriptive icon
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Your team data was not found.',
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'This can happen if registration did not complete. Please log out and try again.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    // **THE NEW LOGOUT BUTTON**
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      onPressed: () {
                        auth.signOut();
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final team = snapshot.data!;

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
