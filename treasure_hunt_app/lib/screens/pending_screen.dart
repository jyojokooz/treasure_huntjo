import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:treasure_hunt_app/services/auth_service.dart';

class PendingScreen extends StatelessWidget {
  final String teamName;

  const PendingScreen({super.key, required this.teamName});

  @override
  Widget build(BuildContext context) {
    final AuthService auth = AuthService();

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/images/background1.png',
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          // Dark Overlay
          Container(
            // FIX 1: Replaced deprecated withOpacity
            color: Colors.black.withAlpha((0.7 * 255).round()),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.hourglass_top_rounded,
                    size: 80,
                    color: Colors.amber,
                    shadows: [Shadow(blurRadius: 15, color: Colors.amber)],
                  ),
                  const SizedBox(height: 30),

                  // Stylized "PENDING" title
                  _buildStyledText("PENDING", 70),

                  const SizedBox(height: 30),
                  Text(
                    'Welcome, Team "$teamName"!',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Your crew is ready, but the map is still sealed. An admin is reviewing your charter to grant you passage.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Styled Logout Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      // FIX 2: Replaced deprecated withOpacity
                      backgroundColor: Colors.red.shade700.withAlpha(
                        (0.8 * 255).round(),
                      ),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      auth.signOut();
                    },
                    child: const Text('Wait Elsewhere (Logout)'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for creating the stylized text
  Widget _buildStyledText(String text, double fontSize) {
    return Stack(
      children: <Widget>[
        // The text outline (the layer behind)
        Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.bangers(
            fontSize: fontSize,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 6
              ..color = Colors.black, // Outline color
            shadows: [
              Shadow(
                blurRadius: 10.0,
                color: Colors.black.withAlpha(
                  (0.5 * 255).round(),
                ), // Also updated here for consistency
                offset: const Offset(5, 5),
              ),
            ],
          ),
        ),
        // The gradient text fill (the layer on top)
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => LinearGradient(
            colors: [Colors.redAccent, Colors.orange.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.bangers(fontSize: fontSize, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
