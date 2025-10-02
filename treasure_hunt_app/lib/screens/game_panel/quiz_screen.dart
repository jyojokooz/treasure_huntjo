// lib/screens/game_panel/quiz_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
// FIX: Added the missing import for Flutter's material library. This resolves all errors.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:treasure_hunt_app/models/quiz_model.dart';
import 'package:treasure_hunt_app/services/auth_service.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<QuizQuestion> _questions = [];
  bool _isLoading = true;
  final PageController _pageController = PageController();
  final Map<int, int> _selectedAnswers =
      {}; // {questionIndex: selectedOptionIndex}
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('quizzes')
        .doc('level1')
        .collection('questions')
        .get();
    setState(() {
      _questions = snapshot.docs
          .map((doc) => QuizQuestion.fromMap(doc.data()))
          .toList();
      _isLoading = false;
    });
  }

  Future<void> _submitAnswers() async {
    setState(() => _isSubmitting = true);

    int score = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_selectedAnswers.containsKey(i) &&
          _selectedAnswers[i] == _questions[i].correctAnswerIndex) {
        score++;
      }
    }

    final submissionData = {
      'score': score,
      'totalQuestions': _questions.length,
      'submittedAt': Timestamp.now(),
      'answers': _selectedAnswers.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
    };

    final user = AuthService().currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('teams').doc(user.uid).update(
        {'level1Submission': submissionData},
      );
    }

    if (mounted) {
      Navigator.pop(context); // Go back to the clues view
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Level 1 complete! Your score: $score/${_questions.length}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Level 1: Mind Spark'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                final question = _questions[index];
                bool isLastQuestion = index == _questions.length - 1;

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Question ${index + 1}/${_questions.length}',
                        style: const TextStyle(color: Colors.orange),
                      ),
                      const SizedBox(height: 8),
                      if (question.imageUrl != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              question.imageUrl!,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                return progress == null
                                    ? child
                                    : const Center(
                                        child: CircularProgressIndicator(),
                                      );
                              },
                            ),
                          ),
                        ),
                      Text(
                        question.questionText,
                        style: GoogleFonts.cinzel(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ...List.generate(question.options.length, (optionIndex) {
                        return Card(
                          color: _selectedAnswers[index] == optionIndex
                              // ignore: deprecated_member_use
                              ? Colors.orange.withOpacity(0.5)
                              : Theme.of(context).cardColor,
                          child: ListTile(
                            title: Text(question.options[optionIndex]),
                            onTap: () {
                              setState(() {
                                _selectedAnswers[index] = optionIndex;
                              });
                            },
                          ),
                        );
                      }),
                      const Spacer(),
                      if (isLastQuestion)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed:
                              _isSubmitting ||
                                  _selectedAnswers.length != _questions.length
                              ? null
                              : _submitAnswers,
                          child: _isSubmitting
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text('Submit Final Answers'),
                        )
                      else
                        ElevatedButton(
                          onPressed: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            );
                          },
                          child: const Text('Next Question'),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
