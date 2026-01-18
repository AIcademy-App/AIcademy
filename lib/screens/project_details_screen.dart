import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/project.dart';
import '../models/project_file.dart';
import '../models/note.dart';
import '../services/file_service.dart';
import '../services/note_service.dart';
import 'add_files_screen.dart';
import 'note_editor_screen.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailsScreen({
    super.key,
    required this.project,
  });

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  final fileService = FileService();
  final noteService = NoteService();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Not authenticated')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with back button
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
                      widget.project.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Urbanist',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Files Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Files',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Urbanist',
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Files List with StreamBuilder
                  StreamBuilder<List<ProjectFile>>(
                    stream: fileService.getProjectFilesStream(
                      uid: user.uid,
                      projectId: widget.project.id,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error loading files',
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }

                      final files = snapshot.data ?? [];

                      if (files.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            children: [
                              Icon(
                                Icons.folder_open,
                                size: 60,
                                color: Colors.grey.shade700,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No files added yet',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                  fontFamily: 'Urbanist',
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return Column(
                        children: files
                            .map((file) => _buildFileCard(file, user.uid))
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Add Files Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddFilesScreen(
                        project: widget.project,
                      ),
                    ),
                  );
                },
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
                  child: const Center(
                    child: Text(
                      'Add Files',
                      style: TextStyle(
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

            const SizedBox(height: 30),

            // Summarized Section
            if (widget.project.description != null &&
                widget.project.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Summarized',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Urbanist',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.project.description!,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontFamily: 'Urbanist',
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          'Summarize',
                          Icons.summarize,
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Summarize feature coming soon'),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          'Add Notes',
                          Icons.note_add,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NoteEditorScreen(
                                  project: widget.project,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          'Take a Quiz',
                          Icons.quiz,
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Quiz feature coming soon'),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          'Chat with PDFs',
                          Icons.chat,
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Chat feature coming soon'),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Notes Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Notes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NoteEditorScreen(
                                project: widget.project,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E5BC),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  // Notes List with StreamBuilder
                  StreamBuilder<List<Note>>(
                    stream: noteService.getProjectNotesStream(
                      uid: user.uid,
                      projectId: widget.project.id,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error loading notes',
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }

                      final notes = snapshot.data ?? [];

                      if (notes.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 30),
                          child: Column(
                            children: [
                              Icon(
                                Icons.note_outlined,
                                size: 50,
                                color: Colors.grey.shade700,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'No notes yet',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontFamily: 'Urbanist',
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return Column(
                        children: notes
                            .map((note) => _buildNoteCard(note, user.uid))
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildFileCard(ProjectFile file, String uid) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(
            Icons.picture_as_pdf,
            color: Colors.red.shade400,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.fileName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Urbanist',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${(file.fileSize / 1024 / 1024).toStringAsFixed(2)} MB',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontFamily: 'Urbanist',
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton(
            onSelected: (value) {
              if (value == 'delete') {
                _deleteFile(file, uid);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.more_vert, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF00E5BC), size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'Urbanist',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteFile(ProjectFile file, String uid) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Delete File',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Delete "${file.fileName}"?',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await fileService.deleteFile(
                  uid: uid,
                  projectId: widget.project.id,
                  fileId: file.id,
                );
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('File deleted')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
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

  Widget _buildNoteCard(Note note, String uid) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NoteEditorScreen(
              project: widget.project,
              note: note,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    note.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Urbanist',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => _deleteNote(note, uid),
                  child: Icon(
                    Icons.close,
                    color: Colors.grey.shade600,
                    size: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              note.content,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontFamily: 'Urbanist',
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteNote(Note note, String uid) async {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Delete Note',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Delete "${note.title}"?',
          style: const TextStyle(color: Colors.grey),
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
                  noteId: note.id,
                );
                if (mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Note deleted')),
                  );
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
