import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:treasure_hunt_app/models/team_model.dart';

class ApprovedTeamsView extends StatelessWidget {
  const ApprovedTeamsView({super.key});

  // Function to show a confirmation dialog before deleting a team
  Future<void> _showDeleteConfirmationDialog(BuildContext context, DocumentReference teamRef) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to permanently delete this team?'),
                Text('This action cannot be undone.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () {
                teamRef.delete(); // Delete the document
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // **THE KEY CHANGE: Query for 'approved' teams**
      stream: FirebaseFirestore.instance
          .collection('teams')
          .where('status', isEqualTo: 'approved')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No teams have been approved yet.'));
        }

        return ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 90), // Avoid overlap with nav bar
          children: snapshot.data!.docs.map((doc) {
            final team = Team.fromMap(doc.data() as Map<String, dynamic>);
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                title: Text(team.teamName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Captain: ${team.teamCaptainEmail}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Button to move the team back to 'pending'
                    IconButton(
                      icon: const Icon(Icons.hourglass_empty, color: Colors.amber),
                      tooltip: 'Move to Pending',
                      onPressed: () => doc.reference.update({'status': 'pending'}),
                    ),
                    // Button to delete the team (with confirmation)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: 'Delete Team',
                      onPressed: () => _showDeleteConfirmationDialog(context, doc.reference),
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