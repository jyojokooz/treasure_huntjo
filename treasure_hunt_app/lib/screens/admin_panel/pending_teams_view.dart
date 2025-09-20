import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:treasure_hunt_app/models/team_model.dart';

class PendingTeamsView extends StatelessWidget {
  const PendingTeamsView({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('teams')
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No teams are pending approval.'));
        }

        return ListView(
          padding: const EdgeInsets.only(
            top: 8,
            bottom: 90,
          ), // Padding to avoid overlap with nav bar
          children: snapshot.data!.docs.map((doc) {
            final team = Team.fromMap(doc.data() as Map<String, dynamic>);
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                title: Text(
                  team.teamName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Captain: ${team.teamCaptainEmail}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      tooltip: 'Approve',
                      onPressed: () =>
                          doc.reference.update({'status': 'approved'}),
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      tooltip: 'Reject',
                      onPressed: () =>
                          doc.reference.update({'status': 'rejected'}),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
