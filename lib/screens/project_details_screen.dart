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
  const ProjectDetailsScreen({super.key, required this.project});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  final fileService = FileService();
  final noteService = NoteService();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Scaffold(body: Center(child: Text('Not authenticated')));

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildSectionTitle('Files'),
            _buildFilesList(user.uid),
            const SizedBox(height: 20),
            _buildAddFilesButton(context),
            const SizedBox(height: 30),
            _buildActionGrid(context),
            const SizedBox(height: 40),
            _buildSectionTitle('Notes'),
            _buildNotesList(user.uid),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 60, 25, 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              widget.project.name,
              style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildFilesList(String uid) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: StreamBuilder<List<ProjectFile>>(
        stream: fileService.getProjectFilesStream(uid: uid, projectId: widget.project.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red));
          
          final files = snapshot.data ?? [];
          if (files.isEmpty) return _buildEmptyState(Icons.folder_open, 'No files yet');

          return Column(children: files.map((file) => _buildFileCard(file, uid)).toList());
        },
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
          Icon(Icons.picture_as_pdf, color: Colors.red.shade400, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(file.fileName, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                Text('${(file.fileSize / 1024 / 1024).toStringAsFixed(2)} MB', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
            onPressed: () => _confirmDeletion(() => fileService.deleteFile(uid: uid, projectId: widget.project.id, fileId: file.id)),
          ),
        ],
      ),
    );
  }

  Widget _buildAddFilesButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddFilesScreen(project: widget.project))),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF23C174), Color(0xFF00C9E0)]),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Center(child: Text('Add Files', style: TextStyle(fontWeight: FontWeight.bold))),
        ),
      ),
    );
  }

  Widget _buildNotesList(String uid) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: StreamBuilder<List<Note>>(
        stream: noteService.getProjectNotesStream(uid: uid, projectId: widget.project.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox();
          final notes = snapshot.data ?? [];
          if (notes.isEmpty) return _buildEmptyState(Icons.note_alt_outlined, 'No notes added');

          return Column(
            children: notes.map((note) => GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => NoteEditorScreen(project: widget.project, note: note))),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(note.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(note.content, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
            )).toList(),
          );
        },
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.5,
        children: [
          _buildActionItem('Summarize', Icons.auto_awesome),
          _buildActionItem('Add Notes', Icons.edit_note, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => NoteEditorScreen(project: widget.project)));
          }),
          _buildActionItem('Quiz', Icons.quiz),
          _buildActionItem('Chat', Icons.chat_bubble_outline),
        ],
      ),
    );
  }

  Widget _buildActionItem(String label, IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF00E5BC), size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String message) {
    return Center(
      child: Column(
        children: [
          Icon(icon, color: Colors.white24, size: 40),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: Colors.white24)),
        ],
      ),
    );
  }

  void _confirmDeletion(Future<void> Function() deleteFn) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Confirm Deletion', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to remove this?', style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () async {
            await deleteFn();
            if (mounted) Navigator.pop(context);
          }, child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}