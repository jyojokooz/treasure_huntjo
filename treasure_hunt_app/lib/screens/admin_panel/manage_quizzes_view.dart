// lib/screens/admin_panel/manage_quizzes_view.dart

// FIX: Corrected the import from 'dart.io' to 'dart:io'.
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../models/quiz_model.dart';
import '../../services/image_upload_service.dart';
import 'level1_leaderboard_view.dart';

class ManageQuizzesView extends StatefulWidget {
  const ManageQuizzesView({super.key});
  @override
  State<ManageQuizzesView> createState() => _ManageQuizzesViewState();
}

class _ManageQuizzesViewState extends State<ManageQuizzesView> {
  final CollectionReference _quizzesCollection = FirebaseFirestore.instance
      .collection('quizzes');
  final ImageUploadService _uploadService = ImageUploadService();

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

    XFile? pickedImage;
    String? imageUrl = existingQuestion?.imageUrl;
    bool isUploading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> pickImage() async {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(
                source: ImageSource.gallery,
              );
              // FIX: Added curly braces to the if statement body.
              if (image != null) {
                setDialogState(() => pickedImage = image);
              }
            }

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
                      if (pickedImage != null)
                        Image.file(File(pickedImage!.path), height: 100)
                      else if (imageUrl != null)
                        Image.network(imageUrl!, height: 100),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.image),
                            label: Text(
                              imageUrl == null && pickedImage == null
                                  ? 'Add Image'
                                  : 'Change Image',
                            ),
                            onPressed: pickImage,
                          ),
                          if (imageUrl != null || pickedImage != null)
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => setDialogState(() {
                                pickedImage = null;
                                imageUrl = null;
                              }),
                            ),
                        ],
                      ),
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
                        return Row(
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
                              // ignore: deprecated_member_use
                              // ignore: deprecated_member_use
                              // ignore: deprecated_member_use
                              groupValue: correctAnswerIndex,
                              // ignore: deprecated_member_use
                              onChanged: (value) => setDialogState(
                                () => correctAnswerIndex = value,
                              ),
                            ),
                          ],
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isUploading
                      ? null
                      : () async {
                          if (formKey.currentState!.validate() &&
                              correctAnswerIndex != null) {
                            setDialogState(() => isUploading = true);
                            String? finalImageUrl = imageUrl;

                            if (pickedImage != null) {
                              finalImageUrl = await _uploadService.uploadImage(
                                pickedImage!,
                              );
                            }

                            final newQuestion = QuizQuestion(
                              id: existingQuestion?.id ?? const Uuid().v4(),
                              questionText: questionText,
                              options: optionControllers
                                  .map((c) => c.text)
                                  .toList(),
                              correctAnswerIndex: correctAnswerIndex!,
                              imageUrl: finalImageUrl,
                            );

                            await _quizzesCollection
                                .doc('level1')
                                .collection('questions')
                                .doc(newQuestion.id)
                                .set(newQuestion.toMap());

                            // FIX: Guarded the context usage with a 'mounted' check.
                            if (mounted) {
                              // ignore: use_build_context_synchronously
                              Navigator.pop(context);
                            }
                          }
                        },
                  child: isUploading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Save'),
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
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.leaderboard_outlined),
                    label: const Text('View Level 1 Leaderboard'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Level1LeaderboardView(),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
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
                            'No questions found. Add one!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              shadows: [
                                Shadow(blurRadius: 4, color: Colors.black54),
                              ],
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
                      padding: const EdgeInsets.only(bottom: 90),
                      itemCount: questions.length,
                      itemBuilder: (context, index) {
                        final question = questions[index];
                        return Card(
                          // FIX: Replaced deprecated withOpacity.
                          color: Colors.white.withAlpha((0.9 * 255).round()),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          child: ListTile(
                            leading: question.imageUrl != null
                                ? const Icon(Icons.image, color: Colors.blue)
                                : null,
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
                                  onPressed: () => _showQuestionDialog(
                                    existingQuestion: question,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _quizzesCollection
                                      .doc('level1')
                                      .collection('questions')
                                      .doc(question.id)
                                      .delete(),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 90,
            right: 20,
            child: FloatingActionButton(
              onPressed: () => _showQuestionDialog(),
              elevation: 2,
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
