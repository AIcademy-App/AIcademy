import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project.dart';

class ProjectService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a new project
  /// Stores in: /users/{uid}/projects/{projectId}
  Future<String> createProject({
    required String uid,
    required String name,
    String? description,
  }) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('projects')
          .doc();

      final projectId = docRef.id;
      final now = DateTime.now();

      final project = Project(
        id: projectId,
        uid: uid,
        name: name,
        description: description,
        createdAt: now,
        updatedAt: now,
      );

      await docRef.set(project.toMap());
      return projectId;
    } catch (e) {
      throw Exception('Failed to create project: $e');
    }
  }

  /// Get all projects for a user as a stream (real-time)
  Stream<List<Project>> getProjectsStream(String uid) {
    try {
      return _firestore
          .collection('users')
          .doc(uid)
          .collection('projects')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Project.fromMap(doc.data()))
            .toList();
      });
    } catch (e) {
      throw Exception('Failed to fetch projects: $e');
    }
  }

  /// Get a single project by ID
  Future<Project?> getProjectById({
    required String uid,
    required String projectId,
  }) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('projects')
          .doc(projectId)
          .get();

      if (doc.exists) {
        return Project.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch project: $e');
    }
  }

  /// Update a project
  Future<void> updateProject({
    required String uid,
    required String projectId,
    required String name,
    String? description,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('projects')
          .doc(projectId)
          .update({
        'name': name,
        'description': description ?? '',
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to update project: $e');
    }
  }

  /// Delete a project
  Future<void> deleteProject({
    required String uid,
    required String projectId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('projects')
          .doc(projectId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete project: $e');
    }
  }

  /// Search projects by name (client-side filtering)
  Stream<List<Project>> searchProjects({
    required String uid,
    required String query,
  }) {
    try {
      return getProjectsStream(uid).map((projects) {
        if (query.isEmpty) return projects;
        return projects
            .where((p) =>
                p.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    } catch (e) {
      throw Exception('Failed to search projects: $e');
    }
  }
}
