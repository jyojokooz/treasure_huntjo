// ===============================
// FILE NAME: puzzle_model.dart
// FILE PATH: C:\treasurehunt\treasure_huntjo\treasure_hunt_app\lib\models\puzzle_model.dart
// ===============================

enum PuzzleType { scramble, riddle, math, quiz }

class Puzzle {
  final String id;
  final PuzzleType type;
  final String prompt;
  final String correctAnswer;
  final List<String>? options;
  final String? mediaUrl; // NEW: Optional field for an image URL.

  Puzzle({
    required this.id,
    required this.type,
    required this.prompt,
    required this.correctAnswer,
    this.options,
    this.mediaUrl, // NEW: Add to constructor.
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'prompt': prompt,
      'correctAnswer': correctAnswer,
      'options': options,
      'mediaUrl': mediaUrl, // NEW: Add to map.
    };
  }

  factory Puzzle.fromMap(Map<String, dynamic> map) {
    PuzzleType typeFromString(String? typeName) {
      return PuzzleType.values.firstWhere(
        (e) => e.name == typeName,
        orElse: () => PuzzleType.riddle,
      );
    }

    return Puzzle(
      id: map['id'] ?? '',
      type: typeFromString(map['type']),
      prompt: map['prompt'] ?? map['scrambledWord'] ?? '',
      correctAnswer: map['correctAnswer'] ?? '',
      options: map['options'] != null
          ? List<String>.from(map['options'])
          : null,
      mediaUrl: map['mediaUrl'] as String?, // NEW: Read from map.
    );
  }
}
