import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  // State variables
  List<QuizQuestion> _questions = [];
  bool _isLoading = true;
  final PageController _pageController = PageController();
  final Map<int, int> _selectedAnswers =
      {}; // Key: questionIndex, Value: selectedOptionIndex
  bool _isSubmitting = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  @override
  void dispose() {
    // Important: Dispose controllers and players to free up resources.
    _pageController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // Fetches the quiz questions for Level 1 from Firestore.
  Future<void> _fetchQuestions() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('quizzes')
          .doc('level1')
          .collection('questions')
          .get();
      if (mounted) {
        setState(() {
          _questions = snapshot.docs
              .map((doc) => QuizQuestion.fromMap(doc.data()))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching questions: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not load quiz. Please go back and try again.'),
          ),
        );
      }
    }
  }

  // Calculates score and saves the submission to the team's document.
  Future<void> _submitAnswers() async {
    setState(() => _isSubmitting = true);
    await _audioPlayer.stop(); // Stop any playing audio on submission

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

  // A helper widget to build and display media (image or audio).
  Widget _buildMediaWidget(QuizQuestion question) {
    if (question.mediaUrl == null || question.mediaUrl!.isEmpty) {
      return const SizedBox.shrink(); // No media, show nothing.
    }

    Widget mediaContent;
    switch (question.mediaType) {
      case 'image':
        mediaContent = ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(question.mediaUrl!, fit: BoxFit.contain),
        );
        break;
      case 'audio':
        mediaContent = Card(
          elevation: 2,
          child: ListTile(
            leading: const Icon(Icons.volume_up),
            title: const Text('Play Audio Question'),
            onTap: () {
              _audioPlayer.play(UrlSource(question.mediaUrl!));
            },
          ),
        );
        break;
      default:
        mediaContent = const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.3,
        ),
        child: mediaContent,
      ),
    );
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
          : _questions.isEmpty
          ? const Center(
              child: Text("No questions available for this level yet."),
            )
          : PageView.builder(
              controller: _pageController,
              // This prevents users from swiping between questions.
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
                      const SizedBox(height: 16),
                      // Display media if it exists for this question.
                      _buildMediaWidget(question),
                      Text(
                        question.questionText,
                        style: GoogleFonts.cinzel(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Use Expanded and ListView for options to prevent overflow.
                      Expanded(
                        child: ListView.builder(
                          itemCount: question.options.length,
                          itemBuilder: (context, optionIndex) {
                            return Card(
                              color: _selectedAnswers[index] == optionIndex
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
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Conditional button: "Submit" on the last question, "Next" otherwise.
                      if (isLastQuestion)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          // Disable button while submitting or if not all questions are answered.
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
