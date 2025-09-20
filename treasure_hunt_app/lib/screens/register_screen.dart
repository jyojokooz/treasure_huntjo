import 'package:flutter/material.dart';
import 'package:treasure_hunt_app/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String teamName = '';
  List<String> members = List.filled(4, '');
  String error = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Your Team')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              padding: const EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 50.0,
              ),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    const SizedBox(height: 20.0),
                    const Text(
                      "Your account will be the Team Captain's account.",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Captain\'s Email',
                      ),
                      validator: (val) =>
                          val!.isEmpty ? 'Enter an email' : null,
                      onChanged: (val) {
                        setState(() => email = val);
                      },
                    ),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password'),
                      validator: (val) => val!.length < 6
                          ? 'Enter a password 6+ chars long'
                          : null,
                      onChanged: (val) {
                        setState(() => password = val);
                      },
                    ),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Team Name'),
                      validator: (val) =>
                          val!.isEmpty ? 'Enter your team name' : null,
                      onChanged: (val) {
                        setState(() => teamName = val);
                      },
                    ),
                    const SizedBox(height: 20.0),
                    ...List.generate(4, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Member ${index + 1} Name',
                          ),
                          validator: (val) => val!.isEmpty
                              ? 'Enter member ${index + 1}\'s name'
                              : null,
                          onChanged: (val) {
                            setState(() => members[index] = val);
                          },
                        ),
                      );
                    }),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      child: const Text('Register Team'),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => loading = true);

                          // FIX: Capture the Navigator before the async gap.
                          final navigator = Navigator.of(context);

                          dynamic result = await _auth.registerAndCreateTeam(
                            email,
                            password,
                            teamName,
                            members,
                          );

                          if (!mounted) {
                            return;
                          }

                          if (result == null) {
                            setState(() {
                              error =
                                  'Please supply a valid email or it may already be in use.';
                              loading = false;
                            });
                          } else {
                            // FIX: Use the captured navigator.
                            navigator.pop();
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 12.0),
                    Text(
                      error,
                      style: const TextStyle(color: Colors.red, fontSize: 14.0),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
