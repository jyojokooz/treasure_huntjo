import 'package:cloud_firestore/cloud_firestore.dart';

class Team {
  final String id;
  final String teamName;
  final String collegeName; // NEW: Added college name property
  final String teamCaptainUid;
  final String teamCaptainEmail;
  final List<String> members;
  final String status;
  final String role;
  final DateTime createdAt;

  Team({
    required this.id,
    required this.teamName,
    required this.collegeName, // NEW: Added to constructor
    required this.teamCaptainUid,
    required this.teamCaptainEmail,
    required this.members,
    required this.status,
    this.role = 'user', // Default role is 'user'
    required this.createdAt,
  });

  // Factory constructor to create a Team from a map (e.g., from Firestore)
  factory Team.fromMap(Map<String, dynamic> map) {
    return Team(
      id: map['id'] ?? '',
      teamName: map['teamName'] ?? '',
      collegeName: map['collegeName'] ?? '', // NEW: Read from map
      teamCaptainUid: map['teamCaptainUid'] ?? '',
      teamCaptainEmail: map['teamCaptainEmail'] ?? '',
      members: List<String>.from(map['members'] ?? []),
      status: map['status'] ?? 'pending',
      role: map['role'] ?? 'user',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // Method to convert a Team object to a map (e.g., for writing to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teamName': teamName,
      'collegeName': collegeName, // NEW: Add to map
      'teamCaptainUid': teamCaptainUid,
      'teamCaptainEmail': teamCaptainEmail,
      'members': members,
      'status': status,
      'role': role,
      'createdAt': createdAt,
    };
  }
}
