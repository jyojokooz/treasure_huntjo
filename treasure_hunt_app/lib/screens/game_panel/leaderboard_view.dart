// lib/screens/game_panel/leaderboard_view.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:treasure_hunt_app/models/team_model.dart';

class LeaderboardView extends StatelessWidget {
  const LeaderboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // Query teams that have submitted, order by score (high to low), then by time (fast to slow)
      stream: FirebaseFirestore.instance
          .collection('teams')
          .where(
            'level1Submission.score',
            isGreaterThan: -1,
          ) // ensures the submission field exists
          .orderBy('level1Submission.score', descending: true)
          .orderBy('level1Submission.submittedAt')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No teams have completed Level 1 yet.'),
          );
        }

        final teams = snapshot.data!.docs
            .map((doc) => Team.fromMap(doc.data() as Map<String, dynamic>))
            .toList();

        return ListView.builder(
          itemCount: teams.length,
          itemBuilder: (context, index) {
            final team = teams[index];
            final rank = index + 1;

            // FIX: Changed the type from 'Icon' to 'Widget'.
            // Now this variable can hold either an Icon or a Text widget.
            Widget rankWidget;

            if (rank == 1) {
              rankWidget = const Icon(
                Icons.emoji_events,
                color: Colors.amber,
                size: 30,
              );
            } else if (rank == 2) {
              rankWidget = Icon(
                Icons.emoji_events,
                color: Colors.grey[400],
                size: 30,
              );
            } else if (rank == 3) {
              rankWidget = Icon(
                Icons.emoji_events,
                color: Colors.brown[400],
                size: 30,
              );
            } else {
              // Now it's valid to assign a Text widget here.
              rankWidget = Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  '$rank.',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                leading: rankWidget, // Use the new widget variable
                title: Text(
                  team.teamName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Text(
                  'Score: ${team.level1Submission?['score'] ?? 0}',
                  style: GoogleFonts.cinzel(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
