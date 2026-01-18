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
      // 1. Validate inputs to prevent malformed paths
      if (uid.isEmpty || projectId.isEmpty) {
        throw Exception('User ID or Project ID is empty');
      }

      final fileName = file.path.split('/').last;
      final storagePath = 'users/$uid/projects/$projectId/files/$fileName';
      
      final ref = _storage.ref().child(storagePath);
      final uploadTask = ref.putFile(file);

      // 2. Listen to upload progress with error handling inside the stream
      uploadTask.snapshotEvents.listen(
        (TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        },
        onError: (e) => print('Upload stream error: $e'),
      );

      // 3. CRITICAL FIX: Explicitly wait for completion before asking for the URL
      // This ensures the object exists before 'getDownloadURL' is called
      await uploadTask.whenComplete(() => {});

      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      // Catch specific Firebase Storage errors
      if (e.code == 'object-not-found') {
        throw Exception('Storage Error: The file was not found after upload. Check storage rules.');
      }
      throw Exception('Firebase Storage Error: ${e.message}');
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