import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectFile {
  final String id;
  final String projectId;
  final String fileName;
  final String fileUrl;
  final int fileSize; // in bytes
  final Timestamp uploadedAt;

  ProjectFile({
    required this.id,
    required this.projectId,
    required this.fileName,
    required this.fileUrl,
    required this.fileSize,
    required this.uploadedAt,
  });

  // Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileSize': fileSize,
      'uploadedAt': uploadedAt,
    };
  }

  // Create from Firestore document
  factory ProjectFile.fromMap(Map<String, dynamic> map) {
    return ProjectFile(
      id: map['id'] as String,
      projectId: map['projectId'] as String,
      fileName: map['fileName'] as String,
      fileUrl: map['fileUrl'] as String,
      fileSize: map['fileSize'] as int,
      uploadedAt: map['uploadedAt'] as Timestamp,
    );
  }

  // Copy with method for updates
  ProjectFile copyWith({
    String? id,
    String? projectId,
    String? fileName,
    String? fileUrl,
    int? fileSize,
    Timestamp? uploadedAt,
  }) {
    return ProjectFile(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      fileSize: fileSize ?? this.fileSize,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }
}
