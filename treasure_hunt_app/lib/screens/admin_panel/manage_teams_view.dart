import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:treasure_hunt_app/models/team_model.dart';

// Enum to define the possible filters for clarity
enum TeamStatusFilter { pending, approved }

class ManageTeamsView extends StatefulWidget {
  const ManageTeamsView({super.key});

  @override
  State<ManageTeamsView> createState() => _ManageTeamsViewState();
}

class _ManageTeamsViewState extends State<ManageTeamsView> {
  // State variable to hold the current filter, defaults to 'pending'
  TeamStatusFilter _currentFilter = TeamStatusFilter.pending;

  // Helper method to build the filter buttons
  Widget _buildFilterButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildFilterButton(TeamStatusFilter.pending, 'Pending'),
          const SizedBox(width: 20),
          _buildFilterButton(TeamStatusFilter.approved, 'Approved'),
        ],
      ),
    );
  }

  // A reusable button widget for the filter
  Widget _buildFilterButton(TeamStatusFilter filter, String text) {
    bool isSelected = _currentFilter == filter;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? Theme.of(context).primaryColor
            : Colors.grey.shade700,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: () {
        setState(() {
          _currentFilter = filter;
        });
      },
      child: Text(text),
    );
  }

  // Helper method to build the correct action buttons based on the filter
  Widget _buildActionButtons(
    BuildContext context,
    DocumentReference docRef,
    Team team,
  ) {
    if (_currentFilter == TeamStatusFilter.pending) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check_circle, color: Colors.green),
            tooltip: 'Approve',
            onPressed: () => docRef.update({'status': 'approved'}),
          ),
          IconButton(
            icon: const Icon(Icons.cancel, color: Colors.red),
            tooltip: 'Reject',
            onPressed: () => docRef.update({'status': 'rejected'}),
          ),
        ],
      );
    } else {
      // Approved filter
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.hourglass_empty, color: Colors.amber),
            tooltip: 'Move to Pending',
            onPressed: () => docRef.update({'status': 'pending'}),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: 'Delete Team',
            onPressed: () => _showDeleteConfirmationDialog(context, docRef),
          ),
        ],
      );
    }
  }

  Future<void> _showDeleteConfirmationDialog(
    BuildContext context,
    DocumentReference teamRef,
  ) async {
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
    final String statusToQuery = _currentFilter == TeamStatusFilter.pending
        ? 'pending'
        : 'approved';

    return Column(
      children: [
        _buildFilterButtons(),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('teams')
                .where('status', isEqualTo: statusToQuery)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text('No teams found with "$statusToQuery" status.'),
                );
              }

              return ListView(
                padding: const EdgeInsets.only(bottom: 90),
                children: snapshot.data!.docs.map((doc) {
                  final team = Team.fromMap(doc.data() as Map<String, dynamic>);
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: ListTile(
                      isThreeLine: true, // NEW: Allow for three lines
                      title: Text(
                        team.teamName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      // UPDATED: Subtitle now shows college and captain
                      subtitle: Text(
                        'College: ${team.collegeName}\nCaptain: ${team.teamCaptainEmail}',
                      ),
                      trailing: _buildActionButtons(
                        context,
                        doc.reference,
                        team,
                      ),
                      onTap: () {
                        // Optional: Show more details on tap
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(team.teamName),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('College: ${team.collegeName}'),
                                const SizedBox(height: 8),
                                Text('Captain: ${team.teamCaptainEmail}'),
                                const SizedBox(height: 8),
                                const Text(
                                  'Members:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                ...team.members.map((m) => Text('- $m')),
                              ],
                            ),
                            actions: [
                              TextButton(
                                child: const Text('Close'),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}
