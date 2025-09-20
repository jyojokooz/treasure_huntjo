import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // <-- ADD THIS IMPORT
import 'package:treasure_hunt_app/screens/auth_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  static const int _splashDurationInSeconds = 5;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: _splashDurationInSeconds),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    _navigateToHome();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _navigateToHome() async {
    await Future.delayed(
      const Duration(seconds: _splashDurationInSeconds),
      () {},
    );
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const AuthWrapper(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          FadeTransition(
            opacity: _fadeAnimation,
            child: Image.asset(
              'assets/images/splash_background.png',
              fit: BoxFit.cover,
            ),
          ),

          // **NEW: Fading Title Text**
          FadeTransition(
            opacity: _fadeAnimation,
            child: Align(
              // Position the text slightly above the center
              alignment: const Alignment(0, -0.4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStyledText("RITU", 80),
                  _buildStyledText("TREASURE HUNT", 50),
                ],
              ),
            ),
          ),

          // Loading Indicator UI (at the bottom)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ... (The loading bar and percentage text code remains unchanged)
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final percentage = (_controller.value * 100).toInt();
                      return Text(
                        'Loading... $percentage%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(blurRadius: 10)],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return LinearProgressIndicator(
                            value: _controller.value,
                            minHeight: 8,
                            backgroundColor: Colors.white.withAlpha(
                              (0.3 * 255).round(),
                            ),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // **NEW HELPER WIDGET for creating the stylized text**
  Widget _buildStyledText(String text, double fontSize) {
    // We use a Stack to layer the text outline behind the gradient fill
    return Stack(
      children: <Widget>[
        // The text outline (the layer behind)
        Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.bangers(
            fontSize: fontSize,
            // Use a Paint object to create the stroke effect
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 6
              ..color = Colors.black, // Outline color
            shadows: [
              Shadow(
                blurRadius: 10.0,
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.5),
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
            style: GoogleFonts.bangers(
              fontSize: fontSize,
              color: Colors
                  .white, // This color is irrelevant, the gradient will override it
            ),
          ),
        ),
      ],
    );
  }
}
