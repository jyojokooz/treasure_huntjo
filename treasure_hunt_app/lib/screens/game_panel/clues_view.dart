import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CluesView extends StatelessWidget {
  const CluesView({super.key});

  @override
  Widget build(BuildContext context) {
    // This column contains the content that was previously in the GamerDashboard's body
    return Column(
      children: [
        const Expanded(
          child: Center(
            child: Text(
              '// Your current clue and interactive elements will be displayed here. //',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),

        // Button for the first level
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.shade800.withAlpha(200),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: Colors.orange.shade300, width: 2),
            ),
          ),
          onPressed: () {
            // TODO: Add navigation to your Quiz screen here
            debugPrint('Starting Mind Spark Quiz...');
          },
          child: Text(
            'Level 1: Mind Spark',
            style: GoogleFonts.cinzel(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}