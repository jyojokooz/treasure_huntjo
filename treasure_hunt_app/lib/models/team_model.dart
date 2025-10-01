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

  // This field will store the team's submission data for the Level 1 quiz.
  // It's a map that can contain fields like 'score', 'totalQuestions', and 'submittedAt'.
  // It is nullable because a team that hasn't played Level 1 won't have this data.
  final Map<String, dynamic>? level1Submission;

  Team({
    required this.id,
    required this.teamName,
    required this.collegeName,
    required this.teamCaptainUid,
    required this.teamCaptainEmail,
    required this.members,
    required this.status,
    this.role = 'user', // Default role is 'user'
    required this.createdAt,
    this.level1Submission, // Optional parameter for quiz data
  });

  // A factory constructor to create a Team instance from a Firestore document map.
  // This is used whenever you read data from the database.
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
      // Firestore stores dates as Timestamps, so we need to convert it.
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      // Read the submission data. It will be null if the field doesn't exist.
      level1Submission: map['level1Submission'] as Map<String, dynamic>?,
    );
  }

  // A method to convert a Team instance into a map.
  // This is used whenever you write data to the database.
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
      // Write the submission data to the map.
      'level1Submission': level1Submission,
    };
  }
}
