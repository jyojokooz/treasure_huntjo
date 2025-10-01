import 'package:cloud_firestore/cloud_firestore.dart';

class Team {
  final String id;
  final String teamName;
  final String collegeName;
  final String teamCaptainUid;
  final String teamCaptainEmail;
  final List<String> members;
  final String status;
  final String role;
  final DateTime createdAt;
  // REMOVED: isLevel1Unlocked, isLevel2Unlocked, isLevel3Unlocked are now global.

  Team({
    required this.id,
    required this.teamName,
    required this.collegeName,
    required this.teamCaptainUid,
    required this.teamCaptainEmail,
    required this.members,
    required this.status,
    this.role = 'user',
    required this.createdAt,
    // REMOVED: Level fields from constructor.
  });

  factory Team.fromMap(Map<String, dynamic> map) {
    return Team(
      id: map['id'] ?? '',
      teamName: map['teamName'] ?? '',
      collegeName: map['collegeName'] ?? '',
      teamCaptainUid: map['teamCaptainUid'] ?? '',
      teamCaptainEmail: map['teamCaptainEmail'] ?? '',
      members: List<String>.from(map['members'] ?? []),
      status: map['status'] ?? 'pending',
      role: map['role'] ?? 'user',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      // REMOVED: Reading level fields from map.
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teamName': teamName,
      'collegeName': collegeName,
      'teamCaptainUid': teamCaptainUid,
      'teamCaptainEmail': teamCaptainEmail,
      'members': members,
      'status': status,
      'role': role,
      'createdAt': createdAt,
      // REMOVED: Writing level fields to map.
    };
  }
}
