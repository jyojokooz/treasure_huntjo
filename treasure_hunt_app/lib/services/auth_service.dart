import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:treasure_hunt_app/models/team_model.dart';
import 'package:treasure_hunt_app/services/firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  Stream<User?> get user => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      debugPrint("SIGN IN FAILED: ${e.toString()}");
      return null;
    }
  }

  // UPDATED: Added 'collegeName' parameter
  Future<User?> registerAndCreateTeam(
    String email,
    String password,
    String teamName,
    String collegeName,
    List<String> members,
  ) async {
    User? user;
    try {
      // Step 1: Create the user in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = result.user;

      if (user != null) {
        // Step 2: Create the team document in Firestore
        Team newTeam = Team(
          id: user.uid,
          teamName: teamName,
          collegeName: collegeName, // NEW: Pass collegeName to the model
          teamCaptainUid: user.uid,
          teamCaptainEmail: email,
          members: members,
          status: 'pending',
          createdAt: DateTime.now(),
        );
        await _firestoreService.createTeam(newTeam);

        // Only return the user if BOTH steps were successful
        return user;
      }
      return null;
    } catch (e) {
      debugPrint("REGISTRATION FAILED: ${e.toString()}");

      // CRITICAL FIX: If anything fails, delete the created user to roll back.
      if (user != null) {
        await user.delete();
        debugPrint("Rollback: Deleted partially created user.");
      }

      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
