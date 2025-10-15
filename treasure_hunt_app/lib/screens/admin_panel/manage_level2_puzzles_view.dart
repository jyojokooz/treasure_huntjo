// ===============================
// FILE NAME: manage_level2_puzzles_view.dart
// FILE PATH: C:\treasurehunt\treasure_huntjo\treasure_hunt_app\lib\screens\admin_panel\manage_level2_puzzles_view.dart
// ===============================

// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:treasure_hunt_app/models/puzzle_model.dart';
import 'package:treasure_hunt_app/screens/game_panel/level2_leaderboard_view.dart';
import 'package:treasure_hunt_app/services/image_upload_service.dart';
import 'package:uuid/uuid.dart';

class ManageLevel2PuzzlesView extends StatefulWidget {
  const ManageLevel2PuzzlesView({super.key});

  @override
  State<ManageLevel2PuzzlesView> createState() =>
      _ManageLevel2PuzzlesViewState();
}

class _ManageLevel2PuzzlesViewState extends State<ManageLevel2PuzzlesView> {
  final CollectionReference _puzzlesCollection = FirebaseFirestore.instance
      .collection('game_content')
      .doc('level2')
      .collection('puzzles');
  // NEW: Instantiate the upload service.
  final ImageUploadService _uploadService = ImageUploadService();

  // REWRITE: The dialog is now fully stateful and includes media handling.
  void _showPuzzleDialog({Puzzle? existingPuzzle}) {
    final formKey = GlobalKey<FormState>();

    // State for the dialog
    PuzzleType selectedType = existingPuzzle?.type ?? PuzzleType.riddle;
    final promptController = TextEditingController(
      text: existingPuzzle?.prompt ?? '',
    );
    final answerController = TextEditingController(
      text: existingPuzzle?.correctAnswer ?? '',
    );
    final optionControllers = List.generate(
      4,
      (i) => TextEditingController(
        text:
            existingPuzzle?.options != null &&
                i < existingPuzzle!.options!.length
            ? existingPuzzle.options![i]
            : '',
      ),
    );
    int? correctOptionIndex;
    if (existingPuzzle?.type == PuzzleType.quiz &&
        existingPuzzle?.options != null) {
      correctOptionIndex = existingPuzzle!.options!.indexOf(
        existingPuzzle.correctAnswer,
      );
      if (correctOptionIndex == -1) correctOptionIndex = null;
    }

    // NEW: State for image handling
    XFile? pickedImage;
    String? mediaUrl = existingPuzzle?.mediaUrl;
    bool isUploading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // NEW: Function to pick an image from the gallery.
            Future<void> pickImage() async {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(
                source: ImageSource.gallery,
              );
              if (image != null) {
                setDialogState(() {
                  pickedImage = image;
                  mediaUrl = null; // Clear existing URL if new image is picked
                });
              }
            }

            return AlertDialog(
              title: Text(
                existingPuzzle == null ? 'Add Puzzle' : 'Edit Puzzle',
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // NEW: Image preview and controls
                      if (pickedImage != null)
                        Image.file(File(pickedImage!.path), height: 100)
                      else if (mediaUrl != null)
                        Image.network(mediaUrl!, height: 100),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.image),
                            label: Text(
                              mediaUrl == null && pickedImage == null
                                  ? 'Add Image'
                                  : 'Change Image',
                            ),
                            onPressed: pickImage,
                          ),
                          if (mediaUrl != null || pickedImage != null)
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => setDialogState(() {
                                pickedImage = null;
                                mediaUrl = null;
                              }),
                            ),
                        ],
                      ),
                      const Divider(),

                      DropdownButtonFormField<PuzzleType>(
                        value: selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Puzzle Type',
                        ),
                        items: PuzzleType.values
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(
                                  type.name[0].toUpperCase() +
                                      type.name.substring(1),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() => selectedType = value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      if (selectedType == PuzzleType.quiz)
                        _buildQuizFields(
                          promptController,
                          optionControllers,
                          correctOptionIndex,
                          (newIndex) => setDialogState(
                            () => correctOptionIndex = newIndex,
                          ),
                        )
                      else
                        _buildTextInputFields(
                          selectedType,
                          promptController,
                          answerController,
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
                          if (formKey.currentState!.validate()) {
                            if (selectedType == PuzzleType.quiz &&
                                correctOptionIndex == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please select a correct answer for the quiz.',
                                  ),
                                ),
                              );
                              return;
                            }

                            setDialogState(() => isUploading = true);

                            String? finalMediaUrl = mediaUrl;
                            // NEW: Upload the image if a new one was picked.
                            if (pickedImage != null) {
                              finalMediaUrl = await _uploadService.uploadImage(
                                pickedImage!,
                              );
                            }

                            final newPuzzle = Puzzle(
                              id: existingPuzzle?.id ?? const Uuid().v4(),
                              type: selectedType,
                              prompt: promptController.text.trim(),
                              correctAnswer: selectedType == PuzzleType.quiz
                                  ? optionControllers[correctOptionIndex!].text
                                        .trim()
                                  : answerController.text.trim().toUpperCase(),
                              options: selectedType == PuzzleType.quiz
                                  ? optionControllers
                                        .map((c) => c.text.trim())
                                        .toList()
                                  : null,
                              mediaUrl: finalMediaUrl, // Pass the final URL
                            );

                            await _puzzlesCollection
                                .doc(newPuzzle.id)
                                .set(newPuzzle.toMap());
                            Navigator.pop(context);
                          }
                        },
                  child: isUploading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
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

  // Helper widgets remain the same
  Widget _buildTextInputFields(
    PuzzleType type,
    TextEditingController promptController,
    TextEditingController answerController,
  ) {
    String promptLabel;
    switch (type) {
      case PuzzleType.scramble:
        promptLabel = 'Scrambled Word (in CAPS)';
        break;
      case PuzzleType.math:
        promptLabel = 'Math Problem';
        break;
      case PuzzleType.riddle:
      default:
        promptLabel = 'Riddle / Question';
        break;
    }
    return Column(
      children: [
        TextFormField(
          controller: promptController,
          decoration: InputDecoration(labelText: promptLabel),
          validator: (val) => val!.isEmpty ? 'Please enter the prompt' : null,
          textCapitalization: type == PuzzleType.scramble
              ? TextCapitalization.characters
              : TextCapitalization.sentences,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: answerController,
          decoration: const InputDecoration(labelText: 'Correct Answer'),
          validator: (val) => val!.isEmpty ? 'Please enter the answer' : null,
          textCapitalization: type == PuzzleType.scramble
              ? TextCapitalization.characters
              : TextCapitalization.sentences,
        ),
      ],
    );
  }

  Widget _buildQuizFields(
    TextEditingController questionController,
    List<TextEditingController> optionControllers,
    int? groupValue,
    ValueChanged<int?> onRadioChanged,
  ) {
    return Column(
      children: [
        TextFormField(
          controller: questionController,
          decoration: const InputDecoration(labelText: 'Quiz Question'),
          validator: (val) => val!.isEmpty ? 'Enter question text' : null,
        ),
        const SizedBox(height: 16),
        ...List.generate(
          4,
          (index) => Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: optionControllers[index],
                  decoration: InputDecoration(labelText: 'Option ${index + 1}'),
                  validator: (val) => val!.isEmpty ? 'Enter option text' : null,
                ),
              ),
              Radio<int>(
                value: index,
                groupValue: groupValue,
                onChanged: onRadioChanged,
              ),
            ],
          ),
        ),
      ],
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
                  label: const Text('View Level 2 Leaderboard'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const Level2LeaderboardView(isAdminView: true),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _puzzlesCollection.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No Level 2 puzzles found. Add one!',
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                      ),
                    );
                  }
                  final puzzles = snapshot.data!.docs
                      .map(
                        (doc) =>
                            Puzzle.fromMap(doc.data() as Map<String, dynamic>),
                      )
                      .toList();
                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 90, top: 8),
                    itemCount: puzzles.length,
                    itemBuilder: (context, index) {
                      final puzzle = puzzles[index];
                      return Card(
                        color: Colors.white.withOpacity(0.9),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: ListTile(
                          // UPDATED: Show an icon if an image is attached.
                          leading: puzzle.mediaUrl != null
                              ? const Icon(
                                  Icons.image_outlined,
                                  color: Colors.blueAccent,
                                )
                              : Icon(
                                  puzzle.type == PuzzleType.quiz
                                      ? Icons.quiz_outlined
                                      : puzzle.type == PuzzleType.scramble
                                      ? Icons.shuffle
                                      : puzzle.type == PuzzleType.math
                                      ? Icons.calculate_outlined
                                      : Icons.lightbulb_outline,
                                  color: Colors.black87,
                                ),
                          title: Text(
                            puzzle.prompt,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            'Answer: ${puzzle.correctAnswer}',
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
                                onPressed: () =>
                                    _showPuzzleDialog(existingPuzzle: puzzle),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () =>
                                    _puzzlesCollection.doc(puzzle.id).delete(),
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
            onPressed: () => _showPuzzleDialog(),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
