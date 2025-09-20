import 'package:cloud_firestore/cloud_firestore.dart';

class Team {
  final String id;
  final String teamName;
  final String teamCaptainUid;
  final String teamCaptainEmail;
  final List<String> members;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime createdAt;
  final String? role;  // **NEW: Add the role field (nullable)**

  Team({
    required this.id,
    required this.teamName,
    required this.teamCaptainUid,
    required this.teamCaptainEmail,
    required this.members,
    required this.status,
    required this.createdAt,
    this.role, // **NEW: Add to constructor**
  });

  factory Team.fromMap(Map<String, dynamic> data) {
    return Team(
      id: data['id'],
      teamName: data['teamName'],
      teamCaptainUid: data['teamCaptainUid'],
      teamCaptainEmail: data['teamCaptainEmail'],
      members: List<String>.from(data['members']),
      status: data['status'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      role: data['role'], // **NEW: Read the role from Firestore**
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teamName': teamName,
      'teamCaptainUid': teamCaptainUid,
      'teamCaptainEmail': teamCaptainEmail,
      'members': members,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'role': role, // **NEW: Write the role to Firestore**
    };
  }
}