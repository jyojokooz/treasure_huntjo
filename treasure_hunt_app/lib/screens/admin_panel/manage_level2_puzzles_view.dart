// ===============================
// FILE NAME: manage_level2_puzzles_view.dart
// FILE PATH: C:\treasurehunt\treasure_huntjo\treasure_hunt_app\lib\screens\admin_panel\manage_level2_puzzles_view.dart
// ===============================

// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:treasure_hunt_app/models/puzzle_model.dart';
import 'package:treasure_hunt_app/screens/game_panel/level2_leaderboard_view.dart';
import 'package:uuid/uuid.dart';

class ManageLevel2PuzzlesView extends StatefulWidget {
  const ManageLevel2PuzzlesView({super.key});

  @override
  State<ManageLevel2PuzzlesView> createState() =>
      _ManageLevel2PuzzlesViewState();
}

class _ManageLevel2PuzzlesViewState extends State<ManageLevel2PuzzlesView> {
  final CollectionReference _puzzlesCollection = FirebaseFirestore.instance
      .collection('game_content')
      .doc('level2')
      .collection('puzzles');

  // This method shows a dialog for adding or editing a puzzle.
  void _showPuzzleDialog({Puzzle? existingPuzzle}) {
    final formKey = GlobalKey<FormState>();
    String scrambledWord = existingPuzzle?.scrambledWord ?? '';
    String correctAnswer = existingPuzzle?.correctAnswer ?? '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(existingPuzzle == null ? 'Add Puzzle' : 'Edit Puzzle'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: scrambledWord,
                  decoration: const InputDecoration(
                    labelText: 'Scrambled Word',
                  ),
                  validator: (val) =>
                      val!.isEmpty ? 'Enter the scrambled word' : null,
                  onChanged: (val) => scrambledWord = val.trim().toUpperCase(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: correctAnswer,
                  decoration: const InputDecoration(
                    labelText: 'Correct Answer',
                  ),
                  validator: (val) =>
                      val!.isEmpty ? 'Enter the correct answer' : null,
                  onChanged: (val) => correctAnswer = val.trim().toUpperCase(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final newPuzzle = Puzzle(
                    id: existingPuzzle?.id ?? const Uuid().v4(),
                    scrambledWord: scrambledWord,
                    correctAnswer: correctAnswer,
                  );

                  // Save the puzzle to Firestore
                  await _puzzlesCollection
                      .doc(newPuzzle.id)
                      .set(newPuzzle.toMap());
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // A Stack is used to place the FloatingActionButton on top of the list.
    return Stack(
      children: [
        Column(
          children: [
            // Button to view the Level 2 Leaderboard.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.leaderboard_outlined),
                  label: const Text('View Level 2 Leaderboard'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const Level2LeaderboardView(isAdminView: true),
                      ),
                    );
                  },
                ),
              ),
            ),
            // The list of puzzles fills the remaining space.
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _puzzlesCollection.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No Level 2 puzzles found. Add one!',
                        // ignore: deprecated_member_use
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                      ),
                    );
                  }

                  final puzzles = snapshot.data!.docs
                      .map(
                        (doc) =>
                            Puzzle.fromMap(doc.data() as Map<String, dynamic>),
                      )
                      .toList();

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 90, top: 8),
                    itemCount: puzzles.length,
                    itemBuilder: (context, index) {
                      final puzzle = puzzles[index];
                      return Card(
                        // ignore: deprecated_member_use
                        color: Colors.white.withOpacity(0.9),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: ListTile(
                          title: Text(
                            puzzle.scrambledWord,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'Answer: ${puzzle.correctAnswer}',
                            // ignore: deprecated_member_use
                            style: TextStyle(
                              // ignore: deprecated_member_use
                              color: Colors.black.withOpacity(0.7),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: Colors.black87,
                                ),
                                onPressed: () =>
                                    _showPuzzleDialog(existingPuzzle: puzzle),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () =>
                                    _puzzlesCollection.doc(puzzle.id).delete(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        // Positioned widget places the FAB correctly within the Stack.
        Positioned(
          bottom: 90, // Lifts the button above the custom nav bar
          right: 20,
          child: FloatingActionButton(
            onPressed: () => _showPuzzleDialog(),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
