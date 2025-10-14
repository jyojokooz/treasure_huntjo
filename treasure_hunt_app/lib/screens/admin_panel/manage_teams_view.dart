// ===============================
// FILE NAME: manage_teams_view.dart
// FILE PATH: C:\treasurehunt\treasure_huntjo\treasure_hunt_app\lib\screens\admin_panel\manage_teams_view.dart
// ===============================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:treasure_hunt_app/models/team_model.dart';

// Enum for type-safe filtering of the team list.
enum TeamStatusFilter { pending, approved }

class ManageTeamsView extends StatefulWidget {
  const ManageTeamsView({super.key});
  @override
  State<ManageTeamsView> createState() => _ManageTeamsViewState();
}

class _ManageTeamsViewState extends State<ManageTeamsView> {
  // State variable to track the currently selected filter.
  TeamStatusFilter _currentFilter = TeamStatusFilter.pending;

  @override
  Widget build(BuildContext context) {
    // Determine the string for the Firestore query based on the active filter.
    final String statusToQuery = _currentFilter == TeamStatusFilter.pending
        ? 'pending'
        : 'approved';

    // The Scaffold is made transparent to allow the AdminDashboard's background to show.
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // The "Pending" / "Approved" filter buttons at the top.
          _buildFilterButtons(),

          // The main content area that displays the list of teams.
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('teams')
                  .where('status', isEqualTo: statusToQuery)
                  .snapshots(),
              builder: (context, snapshot) {
                // Show a loading indicator while data is being fetched.
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // Show a message if there are no teams in the current list.
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No teams found with "$statusToQuery" status.',
                      style: TextStyle(
                        // ignore: deprecated_member_use
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                // If data exists, build the list of team cards.
                return ListView(
                  padding: const EdgeInsets.only(bottom: 90),
                  children: snapshot.data!.docs.map((doc) {
                    final team = Team.fromMap(
                      doc.data() as Map<String, dynamic>,
                    );

                    return Card(
                      // ignore: deprecated_member_use
                      color: Colors.white.withOpacity(0.1),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: ListTile(
                        title: Text(
                          team.teamName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          'College: ${team.collegeName}',
                          style: TextStyle(
                            // ignore: deprecated_member_use
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        // This conditional logic displays the correct action buttons
                        // based on the currently selected filter.
                        trailing: _currentFilter == TeamStatusFilter.pending
                            ? _buildPendingActionButtons(doc.reference)
                            : _buildApprovedActionButtons(
                                context,
                                doc.reference,
                                team,
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

  // Displays a confirmation dialog before revoking a team's 'approved' status.
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

  // Builds the filter button row with styling for the dark theme.
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

  // Builds a single, styled filter button.
  Widget _buildFilterButton(TeamStatusFilter filter, String text) {
    bool isSelected = _currentFilter == filter;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.amber : Colors.grey.shade800,
        foregroundColor: isSelected ? Colors.black : Colors.white70,
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

  // Builds the approve and reject icon buttons for the pending list.
  Widget _buildPendingActionButtons(DocumentReference docRef) {
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

  // Builds the controls for the 'Approved' teams list, including the Lvl 2 switch.
  Widget _buildApprovedActionButtons(
    BuildContext context,
    DocumentReference docRef,
    Team team,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Level 2 eligibility switch
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Lvl 2',
              style: TextStyle(fontSize: 10, color: Colors.white70),
            ),
            Switch(
              value: team.isEligibleForLevel2,
              onChanged: (value) =>
                  docRef.update({'isEligibleForLevel2': value}),
              activeThumbColor: Colors.amber,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
        const SizedBox(width: 4),
        // NEW: Level 3 eligibility switch
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Lvl 3',
              style: TextStyle(fontSize: 10, color: Colors.white70),
            ),
            Switch(
              value: team.isEligibleForLevel3,
              onChanged: (value) =>
                  docRef.update({'isEligibleForLevel3': value}),
              activeThumbColor: Colors.amber,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
        const SizedBox(width: 8),
        // Move back to pending button
        IconButton(
          icon: const Icon(Icons.undo_rounded, color: Colors.amber),
          tooltip: 'Move back to Pending',
          onPressed: () {
            _showMoveToPendingConfirmation(context, docRef, team.teamName);
          },
        ),
      ],
    );
  }
}
