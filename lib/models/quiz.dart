import 'package:cloud_firestore/cloud_firestore.dart';

class Quiz {
  final String id;
  final String title;
  final List<Question> questions;
  final DateTime createdAt;

  Quiz({
    required this.id,
    required this.title,
    required this.questions,
    required this.createdAt,
  });

  /// Converts the Quiz object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'questions': questions.map((q) => q.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Creates a Quiz object from a Firestore Map
  factory Quiz.fromMap(Map<String, dynamic> map) {
    return Quiz(
      id: map['id'] ?? '',
      title: map['title'] ?? 'Untitled Quiz',
      questions: (map['questions'] as List<dynamic>?)
              ?.map((q) => Question.fromMap(q as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}

class Question {
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;

  Question({
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
  });

  Map<String, dynamic> toMap() {
    return {
      'questionText': questionText,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      questionText: map['questionText'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctAnswerIndex: map['correctAnswerIndex'] ?? 0,
    );
  }
}