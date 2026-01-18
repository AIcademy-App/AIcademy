import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String id;
  final String projectId;
  final String title;
  final String content;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  Note({
    required this.id,
    required this.projectId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'title': title,
      'content': content,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Create from Firestore document
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as String,
      projectId: map['projectId'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      createdAt: map['createdAt'] as Timestamp,
      updatedAt: map['updatedAt'] as Timestamp,
    );
  }

  // Copy with method for updates
  Note copyWith({
    String? id,
    String? projectId,
    String? title,
    String? content,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
