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

  // NEW: Level 3 References
  final _level3TimerDocRef = FirebaseFirestore.instance
      .collection('game_settings')
      .doc('level3_timer');
  final _level3DurationController = TextEditingController(text: '10');

  @override
  void dispose() {
    _level1DurationController.dispose();
    _level2DurationController.dispose();
    _level3DurationController.dispose(); // NEW
    super.dispose();
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
          // NEW: Card for Level 3 Timer
          _buildCard(
            title: 'Level 3: The Final Chase',
            child: _buildTimerControls(
              timerDocRef: _level3TimerDocRef,
              durationController: _level3DurationController,
              levelName: 'Level 3',
            ),
          ),
        ],
      ),
    );
  }

  // --- REUSABLE WIDGETS ---

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
