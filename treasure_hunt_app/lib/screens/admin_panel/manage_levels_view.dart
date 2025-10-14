// ===============================
// FILE NAME: manage_levels_view.dart
// FILE PATH: C:\treasurehunt\treasure_huntjo\treasure_hunt_app\lib\screens\admin_panel\manage_levels_view.dart
// ===============================

// --- THE FIX IS HERE: Added all necessary imports ---
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
// ---------------------------------------------------

// ignore_for_file: deprecated_member_use, use_build_context_synchronously

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

  // --- Game Control Functions ---

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
    }, SetOptions(merge: true));
    batch.set(_level1TimerDocRef, {'endTime': null}, SetOptions(merge: true));
    batch.set(_level2TimerDocRef, {'endTime': null}, SetOptions(merge: true));
    batch.set(_level3TimerDocRef, {'endTime': null}, SetOptions(merge: true));
    batch.set(_level3SettingsDocRef, {'activeDepartments': []});

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
            ),
          ),
          const SizedBox(height: 20),
          _buildCard(
            title: 'Level 2: Code Breaker',
            child: _buildTimerControls(
              timerDocRef: _level2TimerDocRef,
              durationController: _level2DurationController,
              levelName: 'Level 2',
            ),
          ),
          const SizedBox(height: 20),
          _buildCard(
            title: 'Level 3: The Final Chase',
            child: _buildTimerControls(
              timerDocRef: _level3TimerDocRef,
              durationController: _level3DurationController,
              levelName: 'Level 3',
            ),
          ),
          const SizedBox(height: 20),
          _buildCard(
            title: 'Manage Level 3 Departments',
            child: _buildDepartmentSelector(),
          ),
          const SizedBox(height: 20),
          _buildCard(
            title: 'Game Control',
            child: Column(
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
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildDepartmentSelector() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _level3SettingsDocRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        List<String> activeDepartments = [];
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          activeDepartments = List<String>.from(
            data['activeDepartments'] ?? [],
          );
        }

        return Column(
          children: _allDepartments.entries.map((entry) {
            final deptId = entry.key;
            final deptName = entry.value;
            final isSelected = activeDepartments.contains(deptId);

            return CheckboxListTile(
              title: Text(
                deptName,
                style: const TextStyle(color: Colors.white),
              ),
              value: isSelected,
              onChanged: (bool? value) {
                if (value == true) {
                  _level3SettingsDocRef.set({
                    'activeDepartments': FieldValue.arrayUnion([deptId]),
                  }, SetOptions(merge: true));
                } else {
                  _level3SettingsDocRef.update({
                    'activeDepartments': FieldValue.arrayRemove([deptId]),
                  });
                }
              },
              activeColor: Colors.amber,
              checkColor: Colors.black,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildTimerControls({
    required DocumentReference timerDocRef,
    required TextEditingController durationController,
    required String levelName,
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(
                  isTimerRunning
                      ? Icons.stop_circle_outlined
                      : Icons.play_circle_outline,
                ),
                label: Text(
                  isTimerRunning
                      ? 'Stop & Lock $levelName'
                      : 'Start $levelName',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isTimerRunning
                      ? Colors.redAccent
                      : Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  if (isTimerRunning) {
                    _stopLevel(timerDocRef, levelName);
                  } else {
                    final minutes = int.tryParse(durationController.text);
                    if (minutes != null && minutes > 0) {
                      _startLevel(timerDocRef, minutes, levelName);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid duration.'),
                        ),
                      );
                    }
                  }
                },
              ),
            ),
            if (isTimerRunning)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
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
