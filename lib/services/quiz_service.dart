import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz.dart';

class QuizService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveQuiz({
    required String uid,
    required String projectId,
    required Quiz quiz,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('projects')
          .doc(projectId)
          .collection('quizzes')
          .doc(quiz.id)
          .set(quiz.toMap());
    } catch (e) {
      throw Exception('Failed to save quiz: $e');
    }
  }

  Stream<List<Quiz>> getQuizzesStream({
    required String uid,
    required String projectId,
  }) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('projects')
        .doc(projectId)
        .collection('quizzes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Quiz.fromMap(doc.data())).toList());
  }
}