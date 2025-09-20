import 'package:cloud_firestore/cloud_firestore.dart';
// **FIXED IMPORT**
import 'package:treasure_hunt_app/models/team_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createTeam(Team team) {
    return _db.collection('teams').doc(team.id).set(team.toMap());
  }

  Stream<Team?> streamTeam(String teamId) {
    return _db
        .collection('teams')
        .doc(teamId)
        .snapshots()
        .map(
          (snapshot) => snapshot.exists ? Team.fromMap(snapshot.data()!) : null,
        );
  }
}
