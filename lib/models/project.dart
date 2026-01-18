import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  final String id;
  final String uid;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Project({
    required this.id,
    required this.uid,
    required this.name,
    this.description,
    required this.createdAt,
    this.updatedAt,
  });

  /// Convert Project object to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'name': name,
      'description': description ?? '',
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : Timestamp.fromDate(DateTime.now()),
    };
  }

  /// Create Project object from Firestore map
  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] ?? '',
      uid: map['uid'] ?? '',
      name: map['name'] ?? 'Untitled Project',
      description: map['description'],
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Create a copy of Project with updated fields
  Project copyWith({
    String? id,
    String? uid,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
