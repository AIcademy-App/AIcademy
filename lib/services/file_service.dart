import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project_file.dart';

class FileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all files for a project as a stream
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
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProjectFile.fromMap(doc.data()))
          .toList();
    });
  }

  /// Get a single file by ID
  Future<ProjectFile?> getFile({
    required String uid,
    required String projectId,
    required String fileId,
  }) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('projects')
          .doc(projectId)
          .collection('files')
          .doc(fileId)
          .get();

      if (doc.exists) {
        return ProjectFile.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching file: $e');
    }
  }

  /// Create a new file record (after upload to storage)
  Future<ProjectFile> createFile({
    required String uid,
    required String projectId,
    required String fileName,
    required String fileUrl,
    required int fileSize,
  }) async {
    try {
      final fileId = DateTime.now().millisecondsSinceEpoch.toString();
      final newFile = ProjectFile(
        id: fileId,
        projectId: projectId,
        fileName: fileName,
        fileUrl: fileUrl,
        fileSize: fileSize,
        uploadedAt: Timestamp.now(),
      );

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('projects')
          .doc(projectId)
          .collection('files')
          .doc(fileId)
          .set(newFile.toMap());

      return newFile;
    } catch (e) {
      throw Exception('Error creating file record: $e');
    }
  }

  /// Delete a file
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

  /// Update file metadata
  Future<void> updateFile({
    required String uid,
    required String projectId,
    required String fileId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('projects')
          .doc(projectId)
          .collection('files')
          .doc(fileId)
          .update(updates);
    } catch (e) {
      throw Exception('Error updating file: $e');
    }
  }

  /// Get total file size for a project
  Future<int> getProjectTotalFileSize({
    required String uid,
    required String projectId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('projects')
          .doc(projectId)
          .collection('files')
          .get();

      return snapshot.docs.fold<int>(0, (total, doc) {
        return total + (doc['fileSize'] as int);
      });
    } catch (e) {
      throw Exception('Error calculating file size: $e');
    }
  }
}
