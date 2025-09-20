import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:treasure_hunt_app/models/team_model.dart';

class TeamView extends StatelessWidget {
  final Team team;
  const TeamView({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          'Team: ${team.teamName.toUpperCase()}',
          textAlign: TextAlign.center,
          style: GoogleFonts.specialElite(
            fontSize: 22,
            color: Colors.white.withAlpha(230),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Divider(color: Colors.white.withAlpha(100)),
        const SizedBox(height: 15),
        Text(
          'Your Crew',
          style: GoogleFonts.specialElite(
            fontSize: 18,
            color: Colors.white.withAlpha(200),
            decoration: TextDecoration.underline,
          ),
        ),
        const SizedBox(height: 10),
        ...team.members.map((member) => Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_outline, color: Colors.white.withAlpha(150), size: 18),
              const SizedBox(width: 8),
              Text(
                member,
                style: GoogleFonts.specialElite(
                  fontSize: 16,
                  color: Colors.white.withAlpha(220),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}