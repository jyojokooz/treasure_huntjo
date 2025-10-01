// lib/models/quiz_model.dart

class QuizQuestion {
  final String id;
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  // NEW: Optional fields for media attached to the question.
  final String? mediaUrl;
  final String? mediaType; // Will be 'image', 'audio', or null

  QuizQuestion({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    this.mediaUrl, // NEW
    this.mediaType, // NEW
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questionText': questionText,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'mediaUrl': mediaUrl, // NEW
      'mediaType': mediaType, // NEW
    };
  }

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      id: map['id'] ?? '',
      questionText: map['questionText'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctAnswerIndex: map['correctAnswerIndex'] ?? 0,
      mediaUrl: map['mediaUrl'], // NEW
      mediaType: map['mediaType'], // NEW
    );
  }
}
