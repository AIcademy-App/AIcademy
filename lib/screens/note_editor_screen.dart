import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/note.dart';
import '../models/project.dart';
import '../services/note_service.dart';

class NoteEditorScreen extends StatefulWidget {
  final Project project;
  final Note? note; // null for creating new note, existing note for editing

  const NoteEditorScreen({
    super.key,
    required this.project,
    this.note,
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final noteService = NoteService();
  late TextEditingController titleController;
  late TextEditingController contentController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note?.title ?? '');
    contentController = TextEditingController(text: widget.note?.content ?? '');
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Not authenticated')),
      );
    }

    final isEditMode = widget.note != null;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      isEditMode ? 'Edit Note' : 'New Note',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Urbanist',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Project Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Text(
                widget.project.name,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontFamily: 'Urbanist',
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Title Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: TextField(
                controller: titleController,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'Urbanist',
                ),
                decoration: InputDecoration(
                  hintText: 'Note Title',
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                    fontFamily: 'Urbanist',
                  ),
                  fillColor: const Color(0xFF1E1E1E),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Content Field (Text Editor)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: TextField(
                  controller: contentController,
                  maxLines: 12,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Urbanist',
                  ),
                  decoration: InputDecoration(
                    hintText: 'Write your note here...',
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontFamily: 'Urbanist',
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Save Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: GestureDetector(
                onTap: isLoading ? null : () => _saveNote(user.uid),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xFF23C174), Color(0xFF00C9E0)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.black,
                              ),
                            ),
                          )
                        : Text(
                            isEditMode ? 'Update Note' : 'Save Note',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Urbanist',
                            ),
                          ),
                  ),
                ),
              ),
            ),

            // Delete Button (only in edit mode)
            if (isEditMode)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25.0,
                  vertical: 12,
                ),
                child: GestureDetector(
                  onTap: isLoading ? null : () => _deleteNote(user.uid),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.red.shade600),
                    ),
                    child: Center(
                      child: Text(
                        'Delete Note',
                        style: TextStyle(
                          color: Colors.red.shade600,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> _saveNote(String uid) async {
    if (titleController.text.isEmpty || contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      if (widget.note != null) {
        // Update existing note
        await noteService.updateNote(
          uid: uid,
          projectId: widget.project.id,
          noteId: widget.note!.id,
          title: titleController.text,
          content: contentController.text,
        );
      } else {
        // Create new note
        await noteService.createNote(
          uid: uid,
          projectId: widget.project.id,
          title: titleController.text,
          content: contentController.text,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.note != null ? 'Note updated' : 'Note created',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _deleteNote(String uid) async {
    if (widget.note == null) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Delete Note',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete this note?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await noteService.deleteNote(
                  uid: uid,
                  projectId: widget.project.id,
                  noteId: widget.note!.id,
                );

                if (mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Note deleted')),
                  );
                  Navigator.pop(context);
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
