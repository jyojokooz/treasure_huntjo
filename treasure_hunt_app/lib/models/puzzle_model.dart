// ===============================
// FILE NAME: puzzle_model.dart
// FILE PATH: C:\treasurehunt\treasure_huntjo\treasure_hunt_app\lib\models\puzzle_model.dart
// ===============================

// NEW: Enums for type-safety.
enum PuzzleType { scramble, riddle, math, quiz }

enum MediaType { image, video }

class Puzzle {
  final String id;
  final PuzzleType type;
  final String prompt;
  final String correctAnswer;
  final List<String>? options;
  final String? mediaUrl;
  final MediaType? mediaType; // NEW: To know if the URL is an image or video.

  Puzzle({
    required this.id,
    required this.type,
    required this.prompt,
    required this.correctAnswer,
    this.options,
    this.mediaUrl,
    this.mediaType, // NEW: Add to constructor.
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'prompt': prompt,
      'correctAnswer': correctAnswer,
      'options': options,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType?.name, // NEW: Store enum as a string.
    };
  }

  factory Puzzle.fromMap(Map<String, dynamic> map) {
    PuzzleType typeFromString(String? typeName) {
      return PuzzleType.values.firstWhere(
        (e) => e.name == typeName,
        orElse: () => PuzzleType.riddle,
      );
    }

    // NEW: Helper to convert string back to MediaType enum.
    MediaType? mediaTypeFromString(String? typeName) {
      if (typeName == null) return null;
      return MediaType.values.firstWhere(
        (e) => e.name == typeName,
        orElse: () => MediaType.image,
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
      mediaUrl: map['mediaUrl'] as String?,
      mediaType: mediaTypeFromString(map['mediaType']), // NEW: Read from map.
    );
  }
}
