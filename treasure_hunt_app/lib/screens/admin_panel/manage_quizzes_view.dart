// ===============================
// FILE NAME: manage_quizzes_view.dart
// FILE PATH: C:\treasurehunt\treasure_huntjo\treasure_hunt_app\lib\screens\admin_panel\manage_quizzes_view.dart
// ===============================

// This file now serves as a "Content Manager" hub with tabs.
// The actual UI for each level's content is in separate files.

import 'package:flutter/material.dart';
import 'package:treasure_hunt_app/screens/admin_panel/manage_level1_quiz_view.dart';
import 'package:treasure_hunt_app/screens/admin_panel/manage_level2_puzzles_view.dart';

class ManageQuizzesView extends StatelessWidget {
  const ManageQuizzesView({super.key});

  @override
  Widget build(BuildContext context) {
    // DefaultTabController coordinates the TabBar and the TabBarView.
    return DefaultTabController(
      length: 2, // The number of tabs
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          // We use PreferredSize to create a custom, transparent AppBar for the tabs.
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
              ],
            ),
          ),
        ),
        // TabBarView displays the content for the currently selected tab.
        body: const TabBarView(
          children: [
            // The content for the first tab.
            ManageLevel1QuizView(),

            // The content for the second tab.
            ManageLevel2PuzzlesView(),
          ],
        ),
      ),
    );
  }
}
