// ===============================
// FILE NAME: level3_clue_model.dart
// FILE PATH: C:\treasurehunt\treasure_huntjo\treasure_hunt_app\lib\models\level3_clue_model.dart
// ===============================

class Level3Clue {
  final String id; // e.g., 'cse', 'barch'
  final String departmentName; // e.g., 'B.Tech CSE'
  final String question;
  final String answer; // Case-insensitive
  final String qrCodeValue;
  final String nextClueLocationHint;

  Level3Clue({
    required this.id,
    required this.departmentName,
    required this.question,
    required this.answer,
    required this.qrCodeValue,
    required this.nextClueLocationHint,
  });

  factory Level3Clue.fromMap(Map<String, dynamic> map, String documentId) {
    return Level3Clue(
      id: documentId,
      departmentName: map['departmentName'] ?? '',
      question: map['question'] ?? '',
      answer: map['answer'] ?? '',
      qrCodeValue: map['qrCodeValue'] ?? '',
      nextClueLocationHint: map['nextClueLocationHint'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'departmentName': departmentName,
      'question': question,
      'answer': answer,
      'qrCodeValue': qrCodeValue,
      'nextClueLocationHint': nextClueLocationHint,
    };
  }
}
