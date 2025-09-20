import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// **FIX: Corrected the typo in this import statement from '.' to ':'**
import 'package:treasure_hunt_app/services/auth_service.dart';
import 'package:treasure_hunt_app/widgets/glassmorphic_container.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  String email = '', password = '', teamName = '', error = '';
  List<String> members = List.filled(4, '');
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
          Container(color: Colors.black.withAlpha((0.6 * 255).round())),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 25.0,
                vertical: 20.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Join the Hunt',
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
                    'Assemble your team of four.',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 30),
                  GlassmorphicContainer(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration(
                              'Team Name',
                              Icons.group_work_outlined,
                            ),
                            validator: (val) =>
                                val!.isEmpty ? 'Enter a team name' : null,
                            onChanged: (val) => setState(() => teamName = val),
                          ),
                          const SizedBox(height: 20),
                          ..._buildMemberFields(),
                          const SizedBox(height: 20),
                          TextFormField(
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration(
                              'Captain\'s Email',
                              Icons.email_outlined,
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
                            onChanged: (val) => setState(() => password = val),
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
                                        dynamic result = await _auth
                                            .registerAndCreateTeam(
                                              email,
                                              password,
                                              teamName,
                                              members,
                                            );

                                        if (!mounted) return;

                                        if (result == null) {
                                          setState(() {
                                            error =
                                                'Please supply a valid email or it may already be in use.';
                                            loading = false;
                                          });
                                        } else {
                                          // The mounted check is already here from our previous fix,
                                          // ensuring the lint warning is also resolved.
                                          if (mounted) {
                                            // ignore: use_build_context_synchronously
                                            Navigator.pop(context);
                                          }
                                        }
                                      }
                                    },
                                    child: const Text('Register Team'),
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
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Already have a team? Back to Login',
                      style: TextStyle(color: Colors.orange.shade200),
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

  List<Widget> _buildMemberFields() {
    List<Widget> fields = [];
    for (int i = 0; i < 4; i++) {
      fields.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: TextFormField(
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration(
              'Member ${i + 1} Name',
              Icons.person_outline,
            ),
            validator: (val) =>
                val!.isEmpty ? 'Enter member ${i + 1}\'s name' : null,
            onChanged: (val) => setState(() => members[i] = val),
          ),
        ),
      );
    }
    fields.removeLast();
    fields.add(
      TextFormField(
        style: const TextStyle(color: Colors.white),
        decoration: _inputDecoration('Member 4 Name', Icons.person_outline),
        validator: (val) => val!.isEmpty ? 'Enter member 4\'s name' : null,
        onChanged: (val) => setState(() => members[3] = val),
      ),
    );
    return fields;
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
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
