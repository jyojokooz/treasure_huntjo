import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  // UPDATED: Added collegeName state variable
  String email = '', password = '', teamName = '', collegeName = '', error = '';
  bool loading = false;

  final List<TextEditingController> _memberControllers = [];

  @override
  void initState() {
    super.initState();
    _addMemberController();
    _addMemberController();
  }

  void _addMemberController() {
    _memberControllers.add(TextEditingController());
  }

  @override
  void dispose() {
    for (var controller in _memberControllers) {
      controller.dispose();
    }
    super.dispose();
  }

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
                    'Assemble your team of 2 to 4.',
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
                          // NEW: College Name text field
                          TextFormField(
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration(
                              'College Name',
                              Icons.school_outlined,
                            ),
                            validator: (val) =>
                                val!.isEmpty ? 'Enter your college name' : null,
                            onChanged: (val) =>
                                setState(() => collegeName = val),
                          ),
                          const SizedBox(height: 20),
                          ..._buildMemberFields(),
                          if (_memberControllers.length < 4)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.orange.shade200,
                                ),
                                icon: const Icon(Icons.add_circle_outline),
                                label: const Text('Add Another Member'),
                                onPressed: () {
                                  setState(() {
                                    _addMemberController();
                                  });
                                },
                              ),
                            ),
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
                                        final members = _memberControllers
                                            .map(
                                              (controller) =>
                                                  controller.text.trim(),
                                            )
                                            .toList();

                                        // UPDATED: Pass collegeName to the auth service
                                        dynamic result = await _auth
                                            .registerAndCreateTeam(
                                              email,
                                              password,
                                              teamName,
                                              collegeName,
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
                                          if (mounted) {
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
    for (int i = 0; i < _memberControllers.length; i++) {
      fields.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _memberControllers[i],
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration(
                    i < 2
                        ? 'Member ${i + 1} Name (Required)'
                        : 'Member ${i + 1} Name (Optional)',
                    Icons.person_outline,
                  ),
                  validator: (val) {
                    if (i < 2 && (val == null || val.isEmpty)) {
                      return 'Enter member ${i + 1}\'s name';
                    }
                    return null;
                  },
                ),
              ),
              if (i > 1)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.redAccent,
                    ),
                    onPressed: () {
                      setState(() {
                        _memberControllers[i].dispose();
                        _memberControllers.removeAt(i);
                      });
                    },
                  ),
                ),
            ],
          ),
        ),
      );
    }
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
