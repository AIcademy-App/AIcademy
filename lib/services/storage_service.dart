import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload a file to Firebase Storage
  /// Returns the download URL of the uploaded file
  Future<String> uploadFile({
    required String uid,
    required String projectId,
    required File file,
    required Function(double) onProgress,
  }) async {
    try {
      final fileName = file.path.split('/').last;
      final storagePath = 'users/$uid/projects/$projectId/files/$fileName';
      
      final uploadTask = _storage.ref(storagePath).putFile(file);

      // Listen to upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress =
            snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress(progress);
      });

      final taskSnapshot = await uploadTask;
      final downloadUrl = await taskSnapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Error uploading file: $e');
    }
  }

  /// Delete a file from Firebase Storage
  Future<void> deleteFile({
    required String uid,
    required String projectId,
    required String fileName,
  }) async {
    try {
      final storagePath = 'users/$uid/projects/$projectId/files/$fileName';
      await _storage.ref(storagePath).delete();
    } catch (e) {
      throw Exception('Error deleting file: $e');
    }
  }

  /// Get download URL for a file
  Future<String> getDownloadUrl({
    required String uid,
    required String projectId,
    required String fileName,
  }) async {
    try {
      final storagePath = 'users/$uid/projects/$projectId/files/$fileName';
      return await _storage.ref(storagePath).getDownloadURL();
    } catch (e) {
      throw Exception('Error getting download URL: $e');
    }
  }

  /// Get file size (metadata)
  Future<FullMetadata?> getFileMetadata({
    required String uid,
    required String projectId,
    required String fileName,
  }) async {
    try {
      final storagePath = 'users/$uid/projects/$projectId/files/$fileName';
      return await _storage.ref(storagePath).getMetadata();
    } catch (e) {
      throw Exception('Error getting file metadata: $e');
    }
  }
}
