import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/project.dart';
import '../models/quiz.dart';
import '../services/quiz_service.dart';
import '../services/file_service.dart';
import '../services/ai_service.dart';
import 'quiz_screen.dart';

class QuizListScreen extends StatefulWidget {
  final Project project;
  const QuizListScreen({super.key, required this.project});

  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  final QuizService _quizService = QuizService();
  final FileService _fileService = FileService();
  final AIService _aiService = AIService();
  bool _isGenerating = false;

  Future<void> _generateQuiz(String uid) async {
    setState(() => _isGenerating = true);

    try {
      // 1. Fetch all files for context
      final files = await _fileService
          .getProjectFilesStream(uid: uid, projectId: widget.project.id)
          .first;

      if (files.isEmpty) {
        throw Exception('No files found. Upload a PDF first.');
      }

      // 2. Combine content (Limit to ~20k chars to be safe, though Flash handles more)
      String combinedContent = files.map((f) => f.content).join('\n\n');
      if (combinedContent.length > 50000) {
        combinedContent = combinedContent.substring(0, 50000);
      }

      // 3. Call AI
      final quizJson = await _aiService.generateQuiz(content: combinedContent);

      // 4. Parse and Save
      final questions = quizJson.map((q) => Question.fromMap(q)).toList();
      final newQuizId = DateTime.now().millisecondsSinceEpoch.toString();
      
      final newQuiz = Quiz(
        id: newQuizId,
        title: 'Generated Quiz ${DateTime.now().day}/${DateTime.now().month}',
        questions: questions,
        createdAt: DateTime.now(),
      );

      await _quizService.saveQuiz(
        uid: uid,
        projectId: widget.project.id,
        quiz: newQuiz,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz generated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Scaffold(body: Center(child: Text('Auth Error')));

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 60, 25, 20),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                const Text(
                  "Quizzes",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Urbanist',
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: StreamBuilder<List<Quiz>>(
              stream: _quizService.getQuizzesStream(
                uid: user.uid,
                projectId: widget.project.id,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF00E5BC)));
                }
                
                final quizzes = snapshot.data ?? [];

                if (quizzes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.quiz_outlined, size: 80, color: Colors.grey.shade800),
                        const SizedBox(height: 16),
                        const Text(
                          "No quizzes yet",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  itemCount: quizzes.length,
                  itemBuilder: (context, index) {
                    final quiz = quizzes[index];
                    return _buildQuizCard(quiz);
                  },
                );
              },
            ),
          ),

          // Generate Button
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: GestureDetector(
              onTap: _isGenerating ? null : () => _generateQuiz(user.uid),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF23C174), Color(0xFF00C9E0)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: _isGenerating
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                        )
                      : const Text(
                          "Generate New Quiz",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'Urbanist',
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCard(Quiz quiz) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QuizScreen(quiz: quiz)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF23C174).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lightbulb_outline, color: Color(0xFF23C174)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quiz.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${quiz.questions.length} Questions",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}