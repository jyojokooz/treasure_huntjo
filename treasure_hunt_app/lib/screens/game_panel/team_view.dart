import 'package:flutter/material.dart';
// FIX 1: Corrected the import path from '.' to ':' to find the Team model.
import 'package:treasure_hunt_app/models/team_model.dart';
import 'package:google_fonts/google_fonts.dart';

class TeamView extends StatelessWidget {
  final Team team;
  const TeamView({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      children: [
        // --- TEAM & COLLEGE HEADER ---
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            // FIX 2: Replaced deprecated withOpacity with withAlpha
            color: Colors.black.withAlpha((0.2 * 255).round()),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                team.teamName.toUpperCase(),
                textAlign: TextAlign.center,
                style: GoogleFonts.cinzel(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade100,
                  letterSpacing: 1.5,
                  shadows: [
                    Shadow(
                      // FIX 3: Replaced deprecated withOpacity
                      color: Colors.orange.shade900.withAlpha(
                        (0.7 * 255).round(),
                      ),
                      blurRadius: 10,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    color: Colors.white.withAlpha(180),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    team.collegeName,
                    style: GoogleFonts.imFellEnglish(
                      fontSize: 16,
                      color: Colors.white.withAlpha(200),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // --- THEMATIC DIVIDER ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // FIX 4: Replaced deprecated withOpacity
              Icon(
                Icons.shield_moon_outlined,
                color: Colors.orange.shade200.withAlpha((0.5 * 255).round()),
              ),
              const SizedBox(width: 10),
              Text(
                'The Crew',
                style: GoogleFonts.cinzel(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade200,
                ),
              ),
              const SizedBox(width: 10),
              // FIX 5: Replaced deprecated withOpacity
              Icon(
                Icons.shield_moon_outlined,
                color: Colors.orange.shade200.withAlpha((0.5 * 255).round()),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),

        // --- MEMBERS LIST ---
        ...team.members.map(
          (member) => Card(
            elevation: 4,
            // FIX 6: Replaced deprecated withOpacity
            color: Colors.white.withAlpha((0.08 * 255).round()),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                // FIX 7: Replaced deprecated withOpacity
                color: Colors.white.withAlpha((0.2 * 255).round()),
                width: 1,
              ),
            ),
            margin: const EdgeInsets.symmetric(vertical: 6.0),
            child: ListTile(
              leading: Icon(
                Icons.person_outline,
                color: Colors.orange.shade200,
                size: 28,
              ),
              title: Text(
                member,
                style: GoogleFonts.imFellEnglish(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
