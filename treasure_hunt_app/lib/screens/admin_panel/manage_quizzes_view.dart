// lib/screens/admin_panel/manage_quizzes_view.dart

// FIX: Corrected all import statements to use ':' instead of '.'
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:treasure_hunt_app/models/quiz_model.dart';
import 'package:uuid/uuid.dart';

class ManageQuizzesView extends StatefulWidget {
  const ManageQuizzesView({super.key});

  @override
  State<ManageQuizzesView> createState() => _ManageQuizzesViewState();
}

class _ManageQuizzesViewState extends State<ManageQuizzesView> {
  final CollectionReference _quizzesCollection = FirebaseFirestore.instance
      .collection('quizzes');

  void _showQuestionDialog({QuizQuestion? existingQuestion}) {
    final formKey = GlobalKey<FormState>();
    String questionText = existingQuestion?.questionText ?? '';
    List<TextEditingController> optionControllers = List.generate(
      4,
      (index) => TextEditingController(
        text:
            existingQuestion != null && index < existingQuestion.options.length
            ? existingQuestion.options[index]
            : '',
      ),
    );
    int? correctAnswerIndex = existingQuestion?.correctAnswerIndex;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                existingQuestion == null ? 'Add Question' : 'Edit Question',
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        initialValue: questionText,
                        decoration: const InputDecoration(
                          labelText: 'Question Text',
                        ),
                        validator: (val) =>
                            val!.isEmpty ? 'Enter question text' : null,
                        onChanged: (val) => questionText = val,
                      ),
                      const SizedBox(height: 16),
                      ...List.generate(4, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: optionControllers[index],
                                  decoration: InputDecoration(
                                    labelText: 'Option ${index + 1}',
                                  ),
                                  validator: (val) =>
                                      val!.isEmpty ? 'Enter option text' : null,
                                ),
                              ),
                              Radio<int>(
                                value: index,
                                groupValue: correctAnswerIndex,
                                onChanged: (value) {
                                  setDialogState(() {
                                    correctAnswerIndex = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                      if (correctAnswerIndex == null)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Please select a correct answer.',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  child: const Text('Save'),
                  onPressed: () {
                    if (formKey.currentState!.validate() &&
                        correctAnswerIndex != null) {
                      final newQuestion = QuizQuestion(
                        id: existingQuestion?.id ?? const Uuid().v4(),
                        questionText: questionText,
                        options: optionControllers.map((c) => c.text).toList(),
                        correctAnswerIndex: correctAnswerIndex!,
                      );

                      _quizzesCollection
                          .doc('level1')
                          .collection('questions')
                          .doc(newQuestion.id)
                          .set(newQuestion.toMap());
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: _quizzesCollection
                .doc('level1')
                .collection('questions')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 90.0),
                  child: Center(
                    child: Text(
                      'No questions found for Level 1. Add one!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                      ),
                    ),
                  ),
                );
              }

              final questions = snapshot.data!.docs
                  .map(
                    (doc) => QuizQuestion.fromMap(
                      doc.data() as Map<String, dynamic>,
                    ),
                  )
                  .toList();

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 90, top: 8),
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];
                  return Card(
                    // FIX: Replaced deprecated withOpacity
                    color: Colors.white.withAlpha((0.9 * 255).round()),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: ListTile(
                      title: Text(
                        question.questionText,
                        style: const TextStyle(color: Colors.black),
                      ),
                      subtitle: Text(
                        'Correct: ${question.options[question.correctAnswerIndex]}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: Colors.black87,
                            ),
                            onPressed: () =>
                                _showQuestionDialog(existingQuestion: question),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              _quizzesCollection
                                  .doc('level1')
                                  .collection('questions')
                                  .doc(question.id)
                                  .delete();
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          Positioned(
            bottom: 90,
            right: 20,
            child: FloatingActionButton(
              onPressed: () => _showQuestionDialog(),
              elevation: 0,
              // FIX: Replaced deprecated withOpacity
              backgroundColor: Theme.of(
                context,
              ).primaryColor.withAlpha((0.9 * 255).round()),
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
