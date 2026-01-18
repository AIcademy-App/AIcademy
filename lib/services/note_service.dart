import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note.dart';

class NoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all notes for a project as a stream
  Stream<List<Note>> getProjectNotesStream({
    required String uid,
    required String projectId,
  }) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('projects')
        .doc(projectId)
        .collection('notes')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Note.fromMap(doc.data()))
          .toList();
    });
  }

  /// Get a single note by ID
  Future<Note?> getNote({
    required String uid,
    required String projectId,
    required String noteId,
  }) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('projects')
          .doc(projectId)
          .collection('notes')
          .doc(noteId)
          .get();

      if (doc.exists) {
        return Note.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching note: $e');
    }
  }

  /// Create a new note
  Future<Note> createNote({
    required String uid,
    required String projectId,
    required String title,
    required String content,
  }) async {
    try {
      final noteId = DateTime.now().millisecondsSinceEpoch.toString();
      final now = Timestamp.now();
      
      final newNote = Note(
        id: noteId,
        projectId: projectId,
        title: title,
        content: content,
        createdAt: now,
        updatedAt: now,
      );

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('projects')
          .doc(projectId)
          .collection('notes')
          .doc(noteId)
          .set(newNote.toMap());

      return newNote;
    } catch (e) {
      throw Exception('Error creating note: $e');
    }
  }

  /// Update an existing note
  Future<void> updateNote({
    required String uid,
    required String projectId,
    required String noteId,
    required String title,
    required String content,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('projects')
          .doc(projectId)
          .collection('notes')
          .doc(noteId)
          .update({
        'title': title,
        'content': content,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Error updating note: $e');
    }
  }

  /// Delete a note
  Future<void> deleteNote({
    required String uid,
    required String projectId,
    required String noteId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('projects')
          .doc(projectId)
          .collection('notes')
          .doc(noteId)
          .delete();
    } catch (e) {
      throw Exception('Error deleting note: $e');
    }
  }
}
