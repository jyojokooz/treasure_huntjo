import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:treasure_hunt_app/models/team_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Create or update a team document
  Future<void> createTeam(Team team) async {
    await _db.collection('teams').doc(team.id).set(team.toMap());
  }

  // NEW: Get a single snapshot of a team's data
  Future<Team?> getTeam(String uid) async {
    final snapshot = await _db.collection('teams').doc(uid).get();
    if (snapshot.exists) {
      return Team.fromMap(snapshot.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Stream a single team's data for real-time updates
  Stream<Team?> streamTeam(String uid) {
    return _db.collection('teams').doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return Team.fromMap(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    });
  }
}
