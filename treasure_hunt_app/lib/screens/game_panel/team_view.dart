// lib/screens/game_panel/team_view.dart

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:treasure_hunt_app/models/team_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui'; // Needed for the frosted glass effect (ImageFilter)

class TeamView extends StatelessWidget {
  final Team team;
  const TeamView({super.key, required this.team});

  // This is a reusable helper widget for creating the stylized "frosted glass"
  // effect for each member in the list.
  Widget _buildMemberCard(String memberName) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        // The ImageFilter.blur creates the frosted glass effect.
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            // A very low opacity color allows the background to show through.
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            // A subtle border helps define the edges of the glass card.
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.person_outline,
                color: Colors.amber.shade300,
                size: 22,
              ),
              const SizedBox(width: 12),
              Text(
                memberName,
                style: GoogleFonts.cinzel(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // A ListView ensures the content can scroll if there are many members
    // or if the screen is small, preventing overflow errors.
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
      children: [
        // --- Team Name Header ---
        Text(
          team.teamName.toUpperCase(),
          textAlign: TextAlign.center,
          style: GoogleFonts.cinzel(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.5,
            // This list of shadows creates the golden glow effect.
            shadows: [
              Shadow(color: Colors.amber.withOpacity(0.8), blurRadius: 15),
              const Shadow(
                color: Colors.black,
                blurRadius: 2,
                offset: Offset(1, 1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // --- College Name ---
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              color: Colors.white.withOpacity(0.7),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              team.collegeName,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),

        // --- "THE CREW" Thematic Divider ---
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shield_moon_outlined,
              color: Colors.amber.withOpacity(0.6),
            ),
            const SizedBox(width: 12),
            Text(
              'THE CREW',
              style: GoogleFonts.cinzel(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.amber.withOpacity(0.9),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.shield_moon_outlined,
              color: Colors.amber.withOpacity(0.6),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // --- Members List ---
        // We map over the list of member names and generate a styled card for each one.
        ...team.members.map((member) => _buildMemberCard(member)),
      ],
    );
  }
}
