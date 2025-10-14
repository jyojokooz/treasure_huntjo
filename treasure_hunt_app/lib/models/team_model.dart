// ===============================
// FILE NAME: team_model.dart
// FILE PATH: C:\treasurehunt\treasure_huntjo\treasure_hunt_app\lib\models\team_model.dart
// ===============================

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
  final bool isEligibleForLevel2;
  final bool isEligibleForLevel3; // NEW: Field for Level 3 eligibility

  final Map<String, dynamic>? level1Submission;
  final Map<String, dynamic>? level2Submission;
  final Map<String, dynamic>?
  level3Submission; // NEW: Field for Level 3 results

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
    this.level1Submission,
    this.level2Submission,
    this.level3Submission, // NEW: Add to constructor
    this.isEligibleForLevel2 = false,
    this.isEligibleForLevel3 = false, // NEW: Add to constructor
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
      level1Submission: map['level1Submission'] as Map<String, dynamic>?,
      level2Submission: map['level2Submission'] as Map<String, dynamic>?,
      level3Submission: map['level3Submission'] as Map<String, dynamic>?, // NEW
      isEligibleForLevel2: map['isEligibleForLevel2'] ?? false,
      isEligibleForLevel3: map['isEligibleForLevel3'] ?? false, // NEW
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
      'level1Submission': level1Submission,
      'level2Submission': level2Submission,
      'level3Submission': level3Submission, // NEW
      'isEligibleForLevel2': isEligibleForLevel2,
      'isEligibleForLevel3': isEligibleForLevel3, // NEW
    };
  }
}
