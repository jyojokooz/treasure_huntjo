// ===============================
// FILE NAME: puzzle_model.dart
// FILE PATH: C:\treasurehunt\treasure_huntjo\treasure_hunt_app\lib\models\puzzle_model.dart
// ===============================

class Puzzle {
  final String id;
  final String scrambledWord;
  final String correctAnswer;

  Puzzle({
    required this.id,
    required this.scrambledWord,
    required this.correctAnswer,
  });

  // Convert a Puzzle object into a map.
  // This is used when writing data to Firestore.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'scrambledWord': scrambledWord,
      'correctAnswer': correctAnswer,
    };
  }

  // Create a Puzzle object from a map (a Firestore document).
  // This is used when reading data from Firestore.
  factory Puzzle.fromMap(Map<String, dynamic> map) {
    return Puzzle(
      id: map['id'] ?? '',
      scrambledWord: map['scrambledWord'] ?? '',
      correctAnswer: map['correctAnswer'] ?? '',
    );
  }
}
