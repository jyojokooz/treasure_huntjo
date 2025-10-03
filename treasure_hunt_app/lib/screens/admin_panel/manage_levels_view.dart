// lib/screens/admin_panel/manage_levels_view.dart

// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// FIX: Corrected the import path from 'package.' to 'package:' to find the services library.
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
  final _timerDocRef = FirebaseFirestore.instance
      .collection('game_settings')
      .doc('level1_timer');
  final _durationController = TextEditingController(text: '3');

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _startLevel1() async {
    final minutes = int.tryParse(_durationController.text);
    if (minutes == null || minutes <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid duration in minutes.'),
          ),
        );
      }
      return;
    }

    final batch = FirebaseFirestore.instance.batch();

    batch.set(_levelsDocRef, {
      'isLevel1Unlocked': true,
    }, SetOptions(merge: true));

    final endTime = DateTime.now().add(Duration(minutes: minutes));
    batch.set(_timerDocRef, {
      'durationMinutes': minutes,
      'endTime': Timestamp.fromDate(endTime),
    });

    await batch.commit();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Level 1 has been started!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _stopLevel1() async {
    final batch = FirebaseFirestore.instance.batch();

    batch.set(_levelsDocRef, {
      'isLevel1Unlocked': false,
    }, SetOptions(merge: true));
    batch.set(_timerDocRef, {'endTime': null}, SetOptions(merge: true));

    await batch.commit();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Level 1 has been stopped and locked.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildCard(
            title: 'Level 1: Mind Spark',
            child: StreamBuilder<DocumentSnapshot>(
              stream: _timerDocRef.snapshots(),
              builder: (context, timerSnapshot) {
                if (!timerSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                // FIX: Removed unnecessary cast.
                final timerData =
                    timerSnapshot.data!.data() as Map<String, dynamic>? ?? {};
                final endTime = (timerData['endTime'] as Timestamp?)?.toDate();
                final bool isTimerRunning =
                    endTime != null && endTime.isAfter(DateTime.now());

                return Column(
                  children: [
                    TextField(
                      controller: _durationController,
                      decoration: const InputDecoration(
                        labelText: 'Duration in Minutes',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(color: Colors.white70),
                      ),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      // This class is now correctly defined because of the fixed import.
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
                              ? 'Stop & Lock Level 1'
                              : 'Start Level 1',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isTimerRunning
                              ? Colors.redAccent
                              : Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: isTimerRunning ? _stopLevel1 : _startLevel1,
                      ),
                    ),
                    if (isTimerRunning)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Level 1 is LIVE. Ends at ${DateFormat.jm().format(endTime)}',
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.greenAccent,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 20),
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
                      'Level 2: Code Breaker',
                      data['isLevel2Unlocked'] ?? false,
                      'isLevel2Unlocked',
                    ),
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
        // FIX: Replaced deprecated 'activeColor' with modern properties.
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
