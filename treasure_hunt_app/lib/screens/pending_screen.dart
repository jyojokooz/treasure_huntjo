import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:treasure_hunt_app/services/auth_service.dart';
import 'package:treasure_hunt_app/services/firestore_service.dart';

// No changes needed to convert it to a StatefulWidget, it's already correct.
class PendingScreen extends StatefulWidget {
  final String teamName;

  const PendingScreen({super.key, required this.teamName});

  @override
  State<PendingScreen> createState() => _PendingScreenState();
}

class _PendingScreenState extends State<PendingScreen> {
  final AuthService _auth = AuthService();
  final FirestoreService _firestore = FirestoreService();
  bool _isRefreshing = false;

  // --- THE FIX IS IN THIS FUNCTION ---
  // It is now much simpler and safer.
  Future<void> _refreshStatus() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      final user = _auth.currentUser;
      // If user is null, they've likely been logged out. Do nothing.
      if (user == null) return;

      // Fetch the latest team data once.
      final team = await _firestore.getTeam(user.uid);

      // CRITICAL FIX: Check if the widget is still mounted *after* the await call.
      // If the user logged out while we were waiting, this will be false and we'll safely exit.
      if (!mounted) return;

      // SIMPLIFIED LOGIC:
      // We only show a message if the status is still pending.
      // We no longer navigate from here. The DecisionScreen handles that automatically.
      if (team?.status == 'pending') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your team is still pending approval.'),
            backgroundColor: Colors.blueGrey,
          ),
        );
      }
      // If status is 'approved' or 'rejected', we do nothing here.
      // The StreamBuilder in DecisionScreen will automatically detect the change and navigate.
    } finally {
      // Use a 'finally' block to ensure the loading state is always turned off,
      // even if an error occurs.
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // The build method remains mostly the same.
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/background1.png',
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Container(color: Colors.black.withAlpha((0.7 * 255).round())),
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
                  _buildStyledText("PENDING", 70),
                  const SizedBox(height: 30),
                  Text(
                    'Welcome, Team "${widget.teamName}"!',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'An admin is reviewing your charter. This page will update automatically when you are approved.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    icon: _isRefreshing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.refresh),
                    label: const Text('Check Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
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
                    onPressed: _isRefreshing ? null : _refreshStatus,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
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
                    ),
                    onPressed: () {
                      _auth.signOut();
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

  Widget _buildStyledText(String text, double fontSize) {
    return Stack(
      children: <Widget>[
        Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.bangers(
            fontSize: fontSize,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 6
              ..color = Colors.black,
            shadows: [
              Shadow(
                blurRadius: 10.0,
                color: Colors.black.withAlpha((0.5 * 255).round()),
                offset: const Offset(5, 5),
              ),
            ],
          ),
        ),
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
