import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectFile {
  final String id;
  final String fileName;
  final int fileSize;
  final String content;
  final String projectId;
  final DateTime? uploadedAt;

  ProjectFile({
    required this.id,
    required this.fileName,
    required this.fileSize,
    required this.content,
    required this.projectId,
    this.uploadedAt,
  });

  /// Converts Firestore Document into ProjectFile object
  factory ProjectFile.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return ProjectFile(
      id: data['id'] ?? doc.id,
      fileName: data['name'] ?? 'Untitled',
      fileSize: data['size'] ?? 0,
      content: data['content'] ?? '',
      projectId: data['projectId'] ?? '',
      uploadedAt: (data['uploadedAt'] as Timestamp?)?.toDate(),
    );
  }
}