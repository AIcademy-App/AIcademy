import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project_file.dart';

class FileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Creates a record in Firestore with extracted text content
  Future<void> createFile({
    required String uid,
    required String projectId,
    required String fileName,
    required int fileSize,
    required String content,
  }) async {
    try {
      final fileRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('projects')
          .doc(projectId)
          .collection('files')
          .doc(); 

      await fileRef.set({
        'id': fileRef.id,
        'name': fileName,
        'size': fileSize,
        'content': content,
        'uploadedAt': FieldValue.serverTimestamp(),
        'projectId': projectId,
      });
    } catch (e) {
      throw Exception('Failed to save file: $e');
    }
  }

  /// Returns a real-time stream of ProjectFile objects
  Stream<List<ProjectFile>> getProjectFilesStream({
    required String uid,
    required String projectId,
  }) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('projects')
        .doc(projectId)
        .collection('files')
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProjectFile.fromFirestore(doc))
            .toList());
  }

  /// Deletes the Firestore document
  Future<void> deleteFile({
    required String uid,
    required String projectId,
    required String fileId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('projects')
          .doc(projectId)
          .collection('files')
          .doc(fileId)
          .delete();
    } catch (e) {
      throw Exception('Error deleting file: $e');
    }
  }
}