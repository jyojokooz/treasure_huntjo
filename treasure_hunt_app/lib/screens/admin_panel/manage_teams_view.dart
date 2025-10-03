import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:treasure_hunt_app/models/team_model.dart';

enum TeamStatusFilter { pending, approved }

class ManageTeamsView extends StatefulWidget {
  const ManageTeamsView({super.key});
  @override
  State<ManageTeamsView> createState() => _ManageTeamsViewState();
}

class _ManageTeamsViewState extends State<ManageTeamsView> {
  TeamStatusFilter _currentFilter = TeamStatusFilter.pending;

  @override
  Widget build(BuildContext context) {
    final String statusToQuery = _currentFilter == TeamStatusFilter.pending
        ? 'pending'
        : 'approved';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
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
                    child: Text(
                      'No teams found with "$statusToQuery" status.',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                      ),
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.only(bottom: 90),
                  children: snapshot.data!.docs.map((doc) {
                    final team = Team.fromMap(
                      doc.data() as Map<String, dynamic>,
                    );

                    return Card(
                      // ignore: deprecated_member_use
                      color: Colors.white.withOpacity(0.9),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: ListTile(
                        title: Text(
                          team.teamName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          'College: ${team.collegeName}',
                          style: const TextStyle(color: Colors.black87),
                        ),

                        // FIX: This logic block correctly determines which buttons to show.
                        trailing: _currentFilter == TeamStatusFilter.pending
                            // If the team is 'pending', show approve/reject buttons.
                            ? _buildActionButtons(doc.reference)
                            // If the team is 'approved', show the "move to pending" button.
                            : IconButton(
                                icon: const Icon(
                                  Icons.undo_rounded,
                                  color: Colors.orange,
                                ),
                                tooltip: 'Move back to Pending',
                                onPressed: () {
                                  // Show a confirmation dialog before making the change.
                                  _showMoveToPendingConfirmation(
                                    context,
                                    doc.reference,
                                    team.teamName,
                                  );
                                },
                              ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Methods ---

  // NEW: A confirmation dialog for moving a team back to pending.
  Future<void> _showMoveToPendingConfirmation(
    BuildContext context,
    DocumentReference teamRef,
    String teamName,
  ) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Action'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Are you sure you want to move team "$teamName" back to the pending list?',
                ),
                const Text(
                  'Their access to the game will be revoked until they are approved again.',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.orange),
              child: const Text('Move to Pending'),
              onPressed: () {
                teamRef.update({'status': 'pending'});
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

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

  Widget _buildActionButtons(DocumentReference docRef) {
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
  }
}
