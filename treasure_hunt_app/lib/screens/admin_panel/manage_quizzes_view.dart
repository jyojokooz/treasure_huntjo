// ===============================
// FILE NAME: manage_quizzes_view.dart
// FILE PATH: C:\treasurehunt\treasure_huntjo\treasure_hunt_app\lib\screens\admin_panel\manage_quizzes_view.dart
// ===============================

import 'package:flutter/material.dart';
import 'package:treasure_hunt_app/screens/admin_panel/manage_level1_quiz_view.dart';
import 'package:treasure_hunt_app/screens/admin_panel/manage_level2_puzzles_view.dart';
import 'package:treasure_hunt_app/screens/admin_panel/manage_level3_clues_view.dart'; // NEW: Import Level 3 manager

class ManageQuizzesView extends StatelessWidget {
  const ManageQuizzesView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // UPDATED: The number of tabs is now 3
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            color: Colors.transparent,
            child: const TabBar(
              indicatorColor: Colors.amber,
              labelColor: Colors.amber,
              unselectedLabelColor: Colors.white70,
              tabs: [
                Tab(icon: Icon(Icons.quiz_outlined), text: 'Level 1 Quiz'),
                Tab(
                  icon: Icon(Icons.extension_outlined),
                  text: 'Level 2 Puzzles',
                ),
                Tab(
                  icon: Icon(Icons.qr_code_scanner),
                  text: 'Level 3 Clues',
                ), // NEW: Level 3 Tab
              ],
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            ManageLevel1QuizView(),
            ManageLevel2PuzzlesView(),
            ManageLevel3CluesView(), // NEW: Add Level 3 View
          ],
        ),
      ),
    );
  }
}
