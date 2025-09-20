import 'package:flutter/material.dart';
import 'package:treasure_hunt_app/services/auth_service.dart';

class AdminProfileView extends StatelessWidget {
  const AdminProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final userEmail = authService.currentUser?.email ?? 'No email found';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              // FIX: Corrected the icon name from 'shield_person_outlined'
              child: Icon(Icons.shield_outlined, size: 50),
            ),
            const SizedBox(height: 20),
            const Text(
              'Admin Account',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              userEmail,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
              onPressed: () {
                authService.signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}
