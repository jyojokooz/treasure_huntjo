// ===============================
// FILE NAME: manage_level3_clues_view.dart
// FILE PATH: C:\treasurehunt\treasure_huntjo\treasure_hunt_app\lib\screens\admin_panel\manage_level3_clues_view.dart
// ===============================

// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:treasure_hunt_app/models/level3_clue_model.dart';
import 'package:treasure_hunt_app/screens/game_panel/level3_leaderboard_view.dart';

class ManageLevel3CluesView extends StatefulWidget {
  const ManageLevel3CluesView({super.key});

  @override
  State<ManageLevel3CluesView> createState() => _ManageLevel3CluesViewState();
}

class _ManageLevel3CluesViewState extends State<ManageLevel3CluesView> {
  final CollectionReference _cluesCollection = FirebaseFirestore.instance
      .collection('game_content')
      .doc('level3')
      .collection('clues');

  final Map<String, String> _allDepartments = const {
    'cse': 'B.Tech - CSE',
    'barch': 'B.Arch',
    'mech': 'Mechanical',
    'ece': 'ECE',
    'eee': 'EEE',
    'rai': 'RAI',
    'mca': 'MCA',
  };

  void _showClueDialog({
    Level3Clue? existingClue,
    required String clueId,
    required String deptName,
  }) {
    final formKey = GlobalKey<FormState>();
    String question = existingClue?.question ?? '';
    String answer = existingClue?.answer ?? '';
    String qrCodeValue =
        existingClue?.qrCodeValue ?? 'treasure-hunt-level3-$clueId';
    String nextClueHint = existingClue?.nextClueLocationHint ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Clue for $deptName'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: question,
                    decoration: const InputDecoration(labelText: 'Question'),
                    validator: (val) =>
                        val!.isEmpty ? 'Enter a question' : null,
                    onChanged: (val) => question = val,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: answer,
                    decoration: const InputDecoration(
                      labelText: 'Answer (Case Insensitive)',
                    ),
                    validator: (val) =>
                        val!.isEmpty ? 'Enter the answer' : null,
                    onChanged: (val) => answer = val,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: qrCodeValue,
                    decoration: const InputDecoration(
                      labelText: 'QR Code Value',
                    ),
                    validator: (val) =>
                        val!.isEmpty ? 'Enter a unique QR value' : null,
                    onChanged: (val) => qrCodeValue = val,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: nextClueHint,
                    decoration: const InputDecoration(
                      labelText: 'Hint for Next Location',
                    ),
                    validator: (val) => val!.isEmpty ? 'Enter a hint' : null,
                    onChanged: (val) => nextClueHint = val,
                    maxLines: 2,
                  ),
                ],
              ),
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
                  final newClue = Level3Clue(
                    id: clueId,
                    departmentName: deptName,
                    question: question,
                    answer: answer,
                    qrCodeValue: qrCodeValue,
                    nextClueLocationHint: nextClueHint,
                  );
                  await _cluesCollection.doc(clueId).set(newClue.toMap());
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.leaderboard_outlined),
              label: const Text('View Level 3 Leaderboard'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const Level3LeaderboardView(isAdminView: true),
                  ),
                );
              },
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('game_settings')
                .doc('level3_settings')
                .snapshots(),
            builder: (context, settingsSnapshot) {
              // --- THE FIX IS HERE ---
              // We create a default empty list.
              List<String> activeDepartments = [];
              // We only try to read the data IF the document actually exists.
              if (settingsSnapshot.hasData && settingsSnapshot.data!.exists) {
                final data =
                    settingsSnapshot.data!.data() as Map<String, dynamic>? ??
                    {};
                activeDepartments = List<String>.from(
                  data['activeDepartments'] ?? [],
                );
              }
              // If the document doesn't exist, `activeDepartments` remains an empty list, preventing the crash.

              return StreamBuilder<QuerySnapshot>(
                stream: _cluesCollection.snapshots(),
                builder: (context, cluesSnapshot) {
                  if (cluesSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final clues = cluesSnapshot.hasData
                      ? {
                          for (var doc in cluesSnapshot.data!.docs)
                            doc.id: Level3Clue.fromMap(
                              doc.data() as Map<String, dynamic>,
                              doc.id,
                            ),
                        }
                      : <String, Level3Clue>{};

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 90),
                    children: _allDepartments.entries.map((entry) {
                      final clueId = entry.key;
                      final deptName = entry.value;
                      final clue = clues[clueId];
                      final bool isActive = activeDepartments.contains(clueId);

                      return Card(
                        color: isActive
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.2),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: ListTile(
                          title: Text(
                            deptName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isActive ? Colors.white : Colors.grey,
                            ),
                          ),
                          subtitle: Text(
                            isActive
                                ? (clue?.question ?? 'No question set yet.')
                                : '(Inactive)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isActive
                                  ? Colors.white.withOpacity(0.7)
                                  : Colors.grey.shade600,
                            ),
                          ),
                          trailing: Icon(
                            Icons.edit_outlined,
                            color: isActive
                                ? Colors.white70
                                : Colors.grey.shade700,
                          ),
                          onTap: () => _showClueDialog(
                            existingClue: clue,
                            clueId: clueId,
                            deptName: deptName,
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
