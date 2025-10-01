import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageLevelsView extends StatelessWidget {
  const ManageLevelsView({super.key});

  // Helper to get a reference to our single settings document.
  DocumentReference get _levelsDocRef =>
      FirebaseFirestore.instance.collection('game_settings').doc('levels');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _levelsDocRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Get the data, or create an empty map if the document doesn't exist yet.
        final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};

        // Determine the lock status for each level, defaulting to 'false' (locked).
        final isLevel1Unlocked = data['isLevel1Unlocked'] ?? false;
        final isLevel2Unlocked = data['isLevel2Unlocked'] ?? false;
        final isLevel3Unlocked = data['isLevel3Unlocked'] ?? false;

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Global Level Controls',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            _buildLevelToggleRow(
              'Level 1: Mind Spark',
              isLevel1Unlocked,
              () => _levelsDocRef.set(
                {'isLevel1Unlocked': !isLevel1Unlocked},
                SetOptions(merge: true), // Creates doc if it doesn't exist
              ),
            ),
            _buildLevelToggleRow(
              'Level 2: Code Breaker',
              isLevel2Unlocked,
              () => _levelsDocRef.set({
                'isLevel2Unlocked': !isLevel2Unlocked,
              }, SetOptions(merge: true)),
            ),
            _buildLevelToggleRow(
              'Level 3: The Final Chase',
              isLevel3Unlocked,
              () => _levelsDocRef.set({
                'isLevel3Unlocked': !isLevel3Unlocked,
              }, SetOptions(merge: true)),
            ),
          ],
        );
      },
    );
  }

  // A reusable widget for each row in the control panel.
  Widget _buildLevelToggleRow(
    String title,
    bool isUnlocked,
    VoidCallback onPressed,
  ) {
    return Card(
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUnlocked ? Icons.lock_open_rounded : Icons.lock_rounded,
              color: isUnlocked ? Colors.green : Colors.red,
            ),
            Text(
              isUnlocked ? 'UNLOCKED' : 'LOCKED',
              style: TextStyle(
                color: isUnlocked ? Colors.green : Colors.red,
                fontSize: 10,
              ),
            ),
          ],
        ),
        onTap: onPressed,
      ),
    );
  }
}
