// ===============================
// FILE NAME: manage_levels_view.dart
// FILE PATH: C:\treasurehunt\treasure_huntjo\treasure_hunt_app\lib\screens\admin_panel\manage_levels_view.dart
// ===============================

// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ManageLevelsView extends StatefulWidget {
  const ManageLevelsView({super.key});

  @override
  State<ManageLevelsView> createState() => _ManageLevelsViewState();
}

class _ManageLevelsViewState extends State<ManageLevelsView> {
  final _levelsDocRef = FirebaseFirestore.instance
      .collection('game_settings')
      .doc('levels');

  final _level1TimerDocRef = FirebaseFirestore.instance
      .collection('game_settings')
      .doc('level1_timer');
  final _level1DurationController = TextEditingController(text: '3');

  final _level2TimerDocRef = FirebaseFirestore.instance
      .collection('game_settings')
      .doc('level2_timer');
  final _level2DurationController = TextEditingController(text: '5');

  final _level3TimerDocRef = FirebaseFirestore.instance
      .collection('game_settings')
      .doc('level3_timer');
  final _level3DurationController = TextEditingController(text: '10');

  final _level3SettingsDocRef = FirebaseFirestore.instance
      .collection('game_settings')
      .doc('level3_settings');

  final Map<String, String> _allDepartments = const {
    'cse': 'B.Tech - CSE',
    'barch': 'B.Arch',
    'mech': 'Mechanical',
    'ece': 'ECE',
    'eee': 'EEE',
    'rai': 'RAI',
    'mca': 'MCA',
  };

  @override
  void dispose() {
    _level1DurationController.dispose();
    _level2DurationController.dispose();
    _level3DurationController.dispose();
    super.dispose();
  }

  // Function to reset a specific level's progress for all teams.
  Future<void> _resetLevelProgress(
    String levelName,
    String submissionField,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Reset for $levelName'),
        content: Text(
          'Are you sure you want to reset all team progress for $levelName? This will delete all scores and submissions for this level, allowing teams to play it again. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.blue),
            child: const Text('Reset Level'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    // Find all teams that have a submission for this specific level
    final teamsSnapshot = await firestore
        .collection('teams')
        .where(submissionField, isNotEqualTo: null)
        .get();

    for (final doc in teamsSnapshot.docs) {
      batch.update(doc.reference, {submissionField: FieldValue.delete()});
    }

    // Also reset progress field for level 3
    if (levelName == 'Level 3') {
      for (final doc in teamsSnapshot.docs) {
        batch.update(doc.reference, {'level3Progress': FieldValue.delete()});
      }
    }

    await batch.commit();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$levelName progress has been reset for all teams!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // Function to end the game and show the winner screen to all players.
  Future<void> _endGameAndAnnounceWinners() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm End Game'),
        content: const Text(
          'Are you sure you want to end the game? This will stop all timers, lock all levels, and redirect all players to the winner announcement screen. This action is final.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('End Game'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final batch = FirebaseFirestore.instance.batch();
      batch.set(_level1TimerDocRef, {'endTime': null}, SetOptions(merge: true));
      batch.set(_level2TimerDocRef, {'endTime': null}, SetOptions(merge: true));
      batch.set(_level3TimerDocRef, {'endTime': null}, SetOptions(merge: true));
      batch.set(_levelsDocRef, {
        'isGameFinished': true,
      }, SetOptions(merge: true));
      await batch.commit();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Game Over! Winners are being announced.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Function to completely reset the game state for a new event.
  Future<void> _resetEntireGame() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('CONFIRM FULL GAME RESET'),
        content: const Text(
          'This will delete ALL team scores and progress for ALL levels, and reset the game to its starting state.\n\nTHIS ACTION CANNOT BE UNDONE.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Reset Everything'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();
    batch.set(_levelsDocRef, {
      'isGameFinished': false,
      // Reset the announcement flags for promotions
      'level2PromotionsComplete': false,
      'level3PromotionsComplete': false,
    }, SetOptions(merge: true));
    batch.set(_level1TimerDocRef, {'endTime': null}, SetOptions(merge: true));
    batch.set(_level2TimerDocRef, {'endTime': null}, SetOptions(merge: true));
    batch.set(_level3TimerDocRef, {'endTime': null}, SetOptions(merge: true));
    batch.set(_level3SettingsDocRef, {
      'activeDepartments': [],
      'clueOrder': [],
    });
    final teamsSnapshot = await firestore.collection('teams').get();
    for (final doc in teamsSnapshot.docs) {
      batch.update(doc.reference, {
        'level1Submission': FieldValue.delete(),
        'level2Submission': FieldValue.delete(),
        'level3Submission': FieldValue.delete(),
        'level3Progress': FieldValue.delete(),
      });
    }
    await batch.commit();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('The game has been fully reset!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // Helper to start a level timer.
  Future<void> _startLevel(
    DocumentReference timerDocRef,
    int minutes,
    String levelName,
  ) async {
    final endTime = DateTime.now().add(Duration(minutes: minutes));
    await timerDocRef.set({
      'durationMinutes': minutes,
      'endTime': Timestamp.fromDate(endTime),
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$levelName has been started!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Helper to stop a level timer.
  Future<void> _stopLevel(
    DocumentReference timerDocRef,
    String levelName,
  ) async {
    await timerDocRef.set({'endTime': null}, SetOptions(merge: true));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$levelName has been stopped and locked.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 90.0),
        children: [
          _buildCard(
            title: 'Level 1: Mind Spark',
            child: _buildTimerControls(
              timerDocRef: _level1TimerDocRef,
              durationController: _level1DurationController,
              levelName: 'Level 1',
              submissionField: 'level1Submission',
            ),
          ),
          const SizedBox(height: 20),
          _buildCard(
            title: 'Level 2: Code Breaker',
            child: _buildTimerControls(
              timerDocRef: _level2TimerDocRef,
              durationController: _level2DurationController,
              levelName: 'Level 2',
              submissionField: 'level2Submission',
            ),
          ),
          const SizedBox(height: 20),
          _buildCard(
            title: 'Level 3: The Final Chase',
            child: _buildTimerControls(
              timerDocRef: _level3TimerDocRef,
              durationController: _level3DurationController,
              levelName: 'Level 3',
              submissionField: 'level3Submission',
            ),
          ),
          const SizedBox(height: 20),
          _buildCard(
            title: 'Manage Level 3 Departments & Order',
            child: _buildDepartmentManager(),
          ),
          const SizedBox(height: 20),
          _buildCard(title: 'Game Control', child: _buildGameControlButtons()),
        ],
      ),
    );
  }

  Widget _buildDepartmentManager() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _level3SettingsDocRef.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        List<String> activeDepartments = [];
        List<String> clueOrder = [];
        if (snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          activeDepartments = List<String>.from(
            data['activeDepartments'] ?? [],
          );
          clueOrder = List<String>.from(data['clueOrder'] ?? []);
        }

        clueOrder.retainWhere((id) => activeDepartments.contains(id));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "1. Select active departments:",
              style: TextStyle(color: Colors.white70),
            ),
            ..._allDepartments.entries.map((entry) {
              return CheckboxListTile(
                title: Text(
                  entry.value,
                  style: const TextStyle(color: Colors.white),
                ),
                value: activeDepartments.contains(entry.key),
                onChanged: (bool? value) async {
                  final settingsSnap = await _level3SettingsDocRef.get();
                  List<String> currentOrder = [];
                  if (settingsSnap.exists) {
                    final data = settingsSnap.data() as Map<String, dynamic>;
                    currentOrder = List<String>.from(data['clueOrder'] ?? []);
                  }

                  if (value == true) {
                    if (!currentOrder.contains(entry.key)) {
                      currentOrder.add(entry.key);
                    }
                  } else {
                    currentOrder.remove(entry.key);
                  }

                  await _level3SettingsDocRef.set({
                    'activeDepartments': value == true
                        ? FieldValue.arrayUnion([entry.key])
                        : FieldValue.arrayRemove([entry.key]),
                    'clueOrder': currentOrder,
                  }, SetOptions(merge: true));
                },
              );
            }),
            const Divider(height: 30),
            const Text(
              "2. Drag to set clue order:",
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 10),
            if (clueOrder.isEmpty)
              const Text(
                'No active departments to order.',
                style: TextStyle(color: Colors.white54),
              )
            else
              ReorderableListView(
                shrinkWrap: true,
                primary: false,
                onReorder: (oldIndex, newIndex) {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  List<String> newOrder = List.from(clueOrder);
                  final String item = newOrder.removeAt(oldIndex);
                  newOrder.insert(newIndex, item);
                  _level3SettingsDocRef.set({
                    'clueOrder': newOrder,
                  }, SetOptions(merge: true));
                },
                children: [
                  for (final clueId in clueOrder)
                    Card(
                      key: ValueKey(clueId),
                      color: Colors.white.withAlpha((0.15 * 255).round()),
                      child: ListTile(
                        leading: const Icon(
                          Icons.drag_handle,
                          color: Colors.white70,
                        ),
                        title: Text(
                          _allDepartments[clueId] ?? 'Unknown',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _buildGameControlButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.celebration),
            label: const Text('Announce Winners & End Game'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: _endGameAndAnnounceWinners,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.replay_circle_filled),
            label: const Text('Reset Game (Play Again)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: _resetEntireGame,
          ),
        ),
      ],
    );
  }

  Widget _buildTimerControls({
    required DocumentReference timerDocRef,
    required TextEditingController durationController,
    required String levelName,
    required String submissionField, // e.g., 'level1Submission'
  }) {
    return StreamBuilder<DocumentSnapshot>(
      stream: timerDocRef.snapshots(),
      builder: (context, timerSnapshot) {
        if (!timerSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final timerData =
            timerSnapshot.data!.data() as Map<String, dynamic>? ?? {};
        final endTime = (timerData['endTime'] as Timestamp?)?.toDate();
        final bool isTimerRunning =
            endTime != null && endTime.isAfter(DateTime.now());

        return Column(
          children: [
            TextField(
              controller: durationController,
              decoration: const InputDecoration(
                labelText: 'Duration in Minutes',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              enabled: !isTimerRunning,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.play_circle_outline),
                    label: const Text('Start'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      disabledBackgroundColor: Colors.grey.shade800,
                    ),
                    onPressed: isTimerRunning
                        ? null
                        : () {
                            final minutes = int.tryParse(
                              durationController.text,
                            );
                            if (minutes != null && minutes > 0) {
                              _startLevel(timerDocRef, minutes, levelName);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please enter a valid duration.',
                                  ),
                                ),
                              );
                            }
                          },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.stop_circle_outlined),
                    label: const Text('End Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      disabledBackgroundColor: Colors.grey.shade800,
                    ),
                    onPressed: isTimerRunning
                        ? () => _stopLevel(timerDocRef, levelName)
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Reset Level Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.replay),
                label: Text('Reset $levelName'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () =>
                    _resetLevelProgress(levelName, submissionField),
              ),
            ),
            if (isTimerRunning)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  '$levelName is LIVE. Ends at ${DateFormat.jm().format(endTime)}',
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.greenAccent,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Card(
      color: Colors.white.withAlpha((0.1 * 255).round()),
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
