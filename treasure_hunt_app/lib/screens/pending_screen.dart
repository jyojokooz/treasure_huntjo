import 'package:flutter/material.dart';
// **FIXED IMPORT**
import 'package:treasure_hunt_app/services/auth_service.dart';

class PendingScreen extends StatelessWidget {
  final String teamName;

  const PendingScreen({super.key, required this.teamName});

  @override
  Widget build(BuildContext context) {
    final AuthService auth = AuthService();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registration Pending"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.hourglass_top_rounded,
                size: 80,
                color: Colors.amber,
              ),
              const SizedBox(height: 20),
              Text(
                'Welcome, Team "$teamName"!',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              const Text(
                'Your registration is complete. Please wait for an admin to approve your team to start the hunt.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
