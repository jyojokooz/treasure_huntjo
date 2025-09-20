import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:treasure_hunt_app/screens/register_screen.dart';
import 'package:treasure_hunt_app/services/auth_service.dart';
import 'package:treasure_hunt_app/widgets/glassmorphic_container.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String error = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/background.png',
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          // Dark Overlay
          Container(
            // FIX 1: Replaced deprecated withOpacity
            color: Colors.black.withAlpha((0.6 * 255).round()),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome, Adventurer!',
                      style: GoogleFonts.cinzel(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          const Shadow(blurRadius: 10, color: Colors.orange),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Your next clue awaits.',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 40),
                    GlassmorphicContainer(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              style: const TextStyle(color: Colors.white),
                              decoration: _inputDecoration(
                                'Email',
                                Icons.person_outline,
                              ),
                              validator: (val) =>
                                  val!.isEmpty ? 'Enter an email' : null,
                              onChanged: (val) => setState(() => email = val),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              style: const TextStyle(color: Colors.white),
                              obscureText: true,
                              decoration: _inputDecoration(
                                'Password',
                                Icons.lock_outline,
                              ),
                              validator: (val) => val!.length < 6
                                  ? 'Password must be 6+ chars'
                                  : null,
                              onChanged: (val) =>
                                  setState(() => password = val),
                            ),
                            const SizedBox(height: 30),
                            loading
                                ? const CircularProgressIndicator(
                                    color: Colors.orange,
                                  )
                                : SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: _buttonStyle(),
                                      onPressed: () async {
                                        if (_formKey.currentState!.validate()) {
                                          setState(() => loading = true);
                                          dynamic result = await _auth.signIn(
                                            email,
                                            password,
                                          );
                                          if (result == null && mounted) {
                                            setState(() {
                                              error =
                                                  'Could not sign in with those credentials';
                                              loading = false;
                                            });
                                          }
                                        }
                                      },
                                      child: const Text('Enter the Gates'),
                                    ),
                                  ),
                            if (error.isNotEmpty) ...[
                              const SizedBox(height: 15),
                              Text(
                                error,
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Don't have a team? Join the Hunt!",
                        style: TextStyle(color: Colors.orange.shade200),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        // FIX 2: Replaced deprecated withOpacity
        borderSide: BorderSide(
          color: Colors.white.withAlpha((0.3 * 255).round()),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.orange),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.orange.shade700,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}
