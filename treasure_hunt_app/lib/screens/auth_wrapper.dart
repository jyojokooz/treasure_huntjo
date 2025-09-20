import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:treasure_hunt_app/screens/decision_screen.dart';
import 'package:treasure_hunt_app/screens/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    // If user is logged in, show DecisionScreen, otherwise show LoginScreen
    if (user != null) {
      // **FIX:** Removed 'const' from here
      return DecisionScreen();
    } else {
      // **FIX:** Removed 'const' from here
      return LoginScreen();
    }
  }
}
