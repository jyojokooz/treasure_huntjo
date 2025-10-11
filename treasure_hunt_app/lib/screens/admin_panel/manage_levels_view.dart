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

  // --- Level 1 References ---
  final _level1TimerDocRef = FirebaseFirestore.instance
      .collection('game_settings')
      .doc('level1_timer');
  final _level1DurationController = TextEditingController(text: '3');

  // --- Level 2 References ---
  final _level2TimerDocRef = FirebaseFirestore.instance
      .collection('game_settings')
      .doc('level2_timer');
  final _level2DurationController = TextEditingController(text: '5');

  @override
  void dispose() {
    _level1DurationController.dispose();
    _level2DurationController.dispose();
    super.dispose();
  }

  // --- Level 1 Methods ---
  Future<void> _startLevel1() async {
    final minutes = int.tryParse(_level1DurationController.text);
    if (minutes == null || minutes <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid duration in minutes.'),
        ),
      );
      return;
    }

    final batch = FirebaseFirestore.instance.batch();
    batch.set(_levelsDocRef, {
      'isLevel1Unlocked': true,
    }, SetOptions(merge: true));
    final endTime = DateTime.now().add(Duration(minutes: minutes));
    batch.set(_level1TimerDocRef, {
      'durationMinutes': minutes,
      'endTime': Timestamp.fromDate(endTime),
    });
    await batch.commit();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Level 1 has been started!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _stopLevel1() async {
    final batch = FirebaseFirestore.instance.batch();
    batch.set(_levelsDocRef, {
      'isLevel1Unlocked': false,
    }, SetOptions(merge: true));
    batch.set(_level1TimerDocRef, {'endTime': null}, SetOptions(merge: true));
    await batch.commit();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Level 1 has been stopped and locked.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  // --- Level 2 Methods ---
  Future<void> _startLevel2() async {
    final minutes = int.tryParse(_level2DurationController.text);
    if (minutes == null || minutes <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid duration.')),
      );
      return;
    }

    final batch = FirebaseFirestore.instance.batch();
    batch.set(_levelsDocRef, {
      'isLevel2Unlocked': true,
    }, SetOptions(merge: true));
    final endTime = DateTime.now().add(Duration(minutes: minutes));
    batch.set(_level2TimerDocRef, {
      'durationMinutes': minutes,
      'endTime': Timestamp.fromDate(endTime),
    });
    await batch.commit();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Level 2 has been started!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _stopLevel2() async {
    final batch = FirebaseFirestore.instance.batch();
    batch.set(_levelsDocRef, {
      'isLevel2Unlocked': false,
    }, SetOptions(merge: true));
    batch.set(_level2TimerDocRef, {'endTime': null}, SetOptions(merge: true));
    await batch.commit();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Level 2 has been stopped and locked.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Card for Level 1 Timer
          _buildCard(
            title: 'Level 1: Mind Spark',
            child: _buildTimerControls(
              timerDocRef: _level1TimerDocRef,
              durationController: _level1DurationController,
              onStart: _startLevel1,
              onStop: _stopLevel1,
              levelName: 'Level 1',
            ),
          ),
          const SizedBox(height: 20),

          // Card for Level 2 Timer
          _buildCard(
            title: 'Level 2: Code Breaker',
            child: _buildTimerControls(
              timerDocRef: _level2TimerDocRef,
              durationController: _level2DurationController,
              onStart: _startLevel2,
              onStop: _stopLevel2,
              levelName: 'Level 2',
            ),
          ),
          const SizedBox(height: 20),

          // Card for Level 3 Toggle
          _buildCard(
            title: 'Other Levels',
            child: StreamBuilder<DocumentSnapshot>(
              stream: _levelsDocRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final data =
                    snapshot.data!.data() as Map<String, dynamic>? ?? {};
                return Column(
                  children: [
                    _buildLevelToggleRow(
                      'Level 3: The Final Chase',
                      data['isLevel3Unlocked'] ?? false,
                      'isLevel3Unlocked',
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- REUSABLE WIDGETS ---

  // A reusable widget for any level's timer controls
  Widget _buildTimerControls({
    required DocumentReference timerDocRef,
    required TextEditingController durationController,
    required Future<void> Function() onStart,
    required Future<void> Function() onStop,
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
                onPressed: isTimerRunning ? onStop : onStart,
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

  Widget _buildLevelToggleRow(String title, bool isUnlocked, String fieldName) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Switch.adaptive(
        value: isUnlocked,
        onChanged: (value) =>
            _levelsDocRef.set({fieldName: value}, SetOptions(merge: true)),
        activeTrackColor: Colors.amber.shade700,
        inactiveTrackColor: Colors.grey.shade800,
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.amber;
          }
          return Colors.grey.shade400;
        }),
      ),
    );
  }
}
