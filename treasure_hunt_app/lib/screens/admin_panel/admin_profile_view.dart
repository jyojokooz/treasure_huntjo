// ===============================
// FILE NAME: admin_profile_view.dart
// FILE PATH: C:\treasurehunt\treasure_huntjo\treasure_hunt_app\lib\screens\admin_panel\admin_profile_view.dart
// ===============================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:treasure_hunt_app/models/team_model.dart';
import 'package:treasure_hunt_app/services/auth_service.dart';

class AdminProfileView extends StatefulWidget {
  const AdminProfileView({super.key});

  @override
  State<AdminProfileView> createState() => _AdminProfileViewState();
}

class _AdminProfileViewState extends State<AdminProfileView> {
  final AuthService _authService = AuthService();
  static const String _ownerEmail = 'joelraphael6425@gmail.com';

  // Dialog to promote a team captain to an admin
  Future<void> _showPromoteAdminDialog() async {
    final teamsSnapshot = await FirebaseFirestore.instance
        .collection('teams')
        .where('status', isEqualTo: 'approved')
        .where('role', isEqualTo: 'user')
        .get();

    final availableTeams = teamsSnapshot.docs
        .map((doc) => Team.fromMap(doc.data()))
        .toList();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        if (availableTeams.isEmpty) {
          return const AlertDialog(
            title: Text('Promote Admin'),
            content: Text(
              'There are no approved teams available to be promoted to admin.',
            ),
          );
        }
        return SimpleDialog(
          title: const Text('Select a Team Captain to Promote'),
          children: availableTeams.map((team) {
            return SimpleDialogOption(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('teams')
                    .doc(team.id)
                    .update({'role': 'admin'});
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${team.teamName} has been promoted.'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: ListTile(
                title: Text(team.teamName),
                subtitle: Text(team.collegeName),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // Dialog to confirm demotion of an admin
  Future<void> _showDemoteAdminConfirmation(Team adminTeam) async {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Demotion'),
        content: Text(
          'Are you sure you want to demote ${adminTeam.teamName}? They will lose all admin privileges.',
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          TextButton(
            // FIX 1: Corrected typo from 'stylefrom' to 'styleFrom'
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Demote'),
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('teams')
                  .doc(adminTeam.id)
                  .update({'role': 'user'});
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${adminTeam.teamName} has been demoted.'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserUid = _authService.currentUser?.uid;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Card for managing current admins
        _buildCard(
          title: 'Current Administrators',
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('teams')
                .where('role', isEqualTo: 'admin')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No admins found.'));
              }

              final adminTeams = snapshot.data!.docs
                  .map(
                    (doc) => Team.fromMap(doc.data() as Map<String, dynamic>),
                  )
                  .toList();

              // Sort to ensure owner is always at the top
              adminTeams.sort((a, b) {
                if (a.teamCaptainEmail == _ownerEmail) return -1;
                if (b.teamCaptainEmail == _ownerEmail) return 1;
                return a.teamName.compareTo(b.teamName);
              });

              return Column(
                children: adminTeams.map((adminTeam) {
                  final isCurrentUser = adminTeam.id == currentUserUid;
                  final bool isOwner =
                      adminTeam.teamCaptainEmail == _ownerEmail;

                  return ListTile(
                    leading: Icon(
                      isOwner
                          ? Icons.shield_rounded
                          : isCurrentUser
                          ? Icons.shield
                          : Icons.shield_outlined,
                      color: isOwner ? Colors.amber : Colors.white70,
                    ),
                    title: Text(
                      adminTeam.teamName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      adminTeam.teamCaptainEmail,
                      // FIX 2: Replaced deprecated 'withOpacity'
                      style: TextStyle(
                        color: Colors.white.withAlpha((0.7 * 255).round()),
                      ),
                    ),
                    trailing: isOwner
                        ? const Chip(
                            label: Text('Owner'),
                            backgroundColor: Colors.amber,
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : isCurrentUser
                        ? const Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Text(
                              'You',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : TextButton(
                            child: const Text('Demote'),
                            onPressed: () =>
                                _showDemoteAdminConfirmation(adminTeam),
                          ),
                  );
                }).toList(),
              );
            },
          ),
        ),
        const SizedBox(height: 20),

        // Card for actions
        _buildCard(
          title: 'Actions',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.add_moderator_outlined),
                label: const Text('Promote New Admin'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: _showPromoteAdminDialog,
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () {
                  _authService.signOut();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper widget for consistent card styling
  Widget _buildCard({required String title, required Widget child}) {
    return Card(
      // FIX 2: Replaced deprecated 'withOpacity'
      color: Colors.white.withAlpha((0.1 * 255).round()),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Divider(color: Colors.white24, height: 20),
            child,
          ],
        ),
      ),
    );
  }
}
