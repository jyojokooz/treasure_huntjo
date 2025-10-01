// FIX: Added the missing import for Cloud Firestore. This resolves all 4 errors in this file.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:treasure_hunt_app/models/team_model.dart';

// Enum to define the possible filters for clarity and type safety.
enum TeamStatusFilter { pending, approved }

class ManageTeamsView extends StatefulWidget {
  const ManageTeamsView({super.key});

  @override
  State<ManageTeamsView> createState() => _ManageTeamsViewState();
}

class _ManageTeamsViewState extends State<ManageTeamsView> {
  // State variable to hold the current filter, defaults to 'pending'.
  TeamStatusFilter _currentFilter = TeamStatusFilter.pending;

  // --- HELPER WIDGETS ---

  // Builds the filter buttons ("Pending" / "Approved") at the top of the screen.
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

  // A reusable button widget for the filter bar.
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

  // Builds the action buttons (Approve/Reject) specifically for teams in the pending list.
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

  // --- MAIN BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    // Determine the string to use in the Firestore query based on the selected filter.
    final String statusToQuery = _currentFilter == TeamStatusFilter.pending
        ? 'pending'
        : 'approved';

    return Column(
      children: [
        _buildFilterButtons(),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            // This stream listens for real-time changes in the 'teams' collection,
            // filtered by the currently selected status ('pending' or 'approved').
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

              // If data is available, build the list of teams.
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
                      title: Text(
                        team.teamName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('College: ${team.collegeName}'),
                      // The trailing widget is determined by the current filter.
                      trailing: _currentFilter == TeamStatusFilter.pending
                          // If team is pending, show the approve/reject buttons.
                          ? _buildActionButtons(doc.reference)
                          // If team is approved, no action buttons are needed here.
                          // Level management is now handled globally in a separate tab.
                          : null,
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
