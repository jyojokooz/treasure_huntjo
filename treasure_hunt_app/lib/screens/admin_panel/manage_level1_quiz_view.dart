// ===============================
// FILE NAME: manage_level1_quiz_view.dart
// FILE PATH: C:\treasurehunt\treasure_huntjo\treasure_hunt_app\lib\screens\admin_panel\manage_level1_quiz_view.dart
// ===============================

// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:treasure_hunt_app/models/quiz_model.dart';
import 'package:treasure_hunt_app/services/image_upload_service.dart';
import 'package:treasure_hunt_app/screens/game_panel/level1_leaderboard_view.dart';
import 'package:uuid/uuid.dart';

class ManageLevel1QuizView extends StatefulWidget {
  const ManageLevel1QuizView({super.key});
  @override
  State<ManageLevel1QuizView> createState() => _ManageLevel1QuizViewState();
}

class _ManageLevel1QuizViewState extends State<ManageLevel1QuizView> {
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

    // UPDATED: State variables for media handling
    XFile? pickedMedia;
    String? mediaUrl = existingQuestion?.mediaUrl;
    MediaType? mediaType = existingQuestion?.mediaType;
    bool isUploading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // UPDATED: Generic function to pick image or video
            Future<void> pickMedia(bool isVideo) async {
              final ImagePicker picker = ImagePicker();
              final XFile? file = isVideo
                  ? await picker.pickVideo(source: ImageSource.gallery)
                  : await picker.pickImage(source: ImageSource.gallery);

              if (file != null) {
                setDialogState(() {
                  pickedMedia = file;
                  mediaUrl = null; // Clear existing URL if a new file is picked
                  mediaType = isVideo ? MediaType.video : MediaType.image;
                });
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
                      // UPDATED: Media preview logic
                      if (pickedMedia != null)
                        mediaType == MediaType.image
                            ? Image.file(File(pickedMedia!.path), height: 100)
                            : const Icon(
                                Icons.videocam,
                                size: 60,
                                color: Colors.grey,
                              )
                      else if (mediaUrl != null)
                        mediaType == MediaType.image
                            ? Image.network(mediaUrl!, height: 100)
                            : const Icon(
                                Icons.videocam,
                                size: 60,
                                color: Colors.grey,
                              ),

                      // UPDATED: Buttons for image, video, and delete
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.image),
                            label: const Text('Image'),
                            onPressed: () => pickMedia(false),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.videocam),
                            label: const Text('Video'),
                            onPressed: () => pickMedia(true),
                          ),
                          if (mediaUrl != null || pickedMedia != null)
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setDialogState(() {
                                  pickedMedia = null;
                                  mediaUrl = null;
                                  mediaType = null;
                                });
                              },
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
                              groupValue: correctAnswerIndex,
                              onChanged: (value) {
                                setDialogState(() {
                                  correctAnswerIndex = value;
                                });
                              },
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
                            // UPDATED: Upload logic
                            String? finalMediaUrl = mediaUrl;
                            if (pickedMedia != null) {
                              finalMediaUrl = await _uploadService.uploadImage(
                                pickedMedia!,
                              );
                            }

                            // UPDATED: Create question with new media fields
                            final newQuestion = QuizQuestion(
                              id: existingQuestion?.id ?? const Uuid().v4(),
                              questionText: questionText,
                              options: optionControllers
                                  .map((c) => c.text)
                                  .toList(),
                              correctAnswerIndex: correctAnswerIndex!,
                              mediaUrl: finalMediaUrl,
                              mediaType: finalMediaUrl != null
                                  ? mediaType
                                  : null,
                            );

                            await _quizzesCollection
                                .doc('level1')
                                .collection('questions')
                                .doc(newQuestion.id)
                                .set(newQuestion.toMap());

                            if (mounted) {
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
    return Stack(
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
                        builder: (context) =>
                            const Level1LeaderboardView(isAdminView: true),
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
                    return Center(
                      child: Text(
                        'No questions found. Add one!',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
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
                      // UPDATED: Show correct icon for image or video
                      IconData leadingIcon = Icons.help_outline;
                      if (question.mediaType == MediaType.image) {
                        leadingIcon = Icons.image;
                      } else if (question.mediaType == MediaType.video) {
                        leadingIcon = Icons.videocam;
                      }

                      return Card(
                        color: Colors.white.withAlpha((0.9 * 255).round()),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: ListTile(
                          leading: question.mediaUrl != null
                              ? Icon(leadingIcon, color: Colors.blueAccent)
                              : null,
                          title: Text(
                            question.questionText,
                            style: const TextStyle(color: Colors.black),
                          ),
                          subtitle: Text(
                            'Correct: ${question.options[question.correctAnswerIndex]}',
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.7),
                            ),
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
                                  color: Colors.redAccent,
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
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
