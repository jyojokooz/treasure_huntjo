// ===============================
// FILE NAME: quiz_model.dart
// FILE PATH: C:\treasurehunt\treasure_huntjo\treasure_hunt_app\lib\models\quiz_model.dart
// ===============================

// NEW: Enum for type-safety, consistent with other models.
enum MediaType { image, video }

class QuizQuestion {
  final String id;
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final String? mediaUrl; // RENAMED from imageUrl for consistency
  final MediaType? mediaType; // NEW: To know if the URL is an image or video

  QuizQuestion({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    this.mediaUrl, // UPDATED
    this.mediaType, // NEW
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questionText': questionText,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'mediaUrl': mediaUrl, // UPDATED
      'mediaType': mediaType?.name, // NEW: Store enum as a string
    };
  }

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    // NEW: Helper to convert string back to MediaType enum.
    MediaType? mediaTypeFromString(String? typeName) {
      if (typeName == null) return null;
      return MediaType.values.firstWhere(
        (e) => e.name == typeName,
        orElse: () =>
            MediaType.image, // Default to image for old data or errors
      );
    }

    return QuizQuestion(
      id: map['id'] ?? '',
      questionText: map['questionText'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctAnswerIndex: map['correctAnswerIndex'] ?? 0,
      // UPDATED: Read from 'mediaUrl' but fall back to 'imageUrl' for backward compatibility.
      mediaUrl: map['mediaUrl'] as String? ?? map['imageUrl'] as String?,
      mediaType: mediaTypeFromString(map['mediaType']), // NEW
    );
  }
}
