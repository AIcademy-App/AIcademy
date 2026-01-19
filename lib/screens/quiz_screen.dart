import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/quiz.dart';

class QuizScreen extends StatefulWidget {
  final Quiz quiz;
  const QuizScreen({super.key, required this.quiz});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedOptionIndex;
  bool _isAnswered = false;

  void _handleOptionTap(int index) {
    if (_isAnswered) return;

    setState(() {
      _selectedOptionIndex = index;
      _isAnswered = true;
      if (index == widget.quiz.questions[_currentIndex].correctAnswerIndex) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < widget.quiz.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOptionIndex = null;
        _isAnswered = false;
      });
    } else {
      _showResults();
    }
  }

  Future<void> _updatePoints() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _score == 0) return;

    try {
      // Award 10 points per correct answer
      final pointsEarned = _score * 10;
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'points': FieldValue.increment(pointsEarned),
      });
    } catch (e) {
      debugPrint('Error updating points: $e');
    }
  }

  void _showResults() async {
    // Update points in the background
    await _updatePoints();

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Quiz Completed!",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: Color(0xFF00E5BC), size: 60),
            const SizedBox(height: 20),
            Text(
              "You scored $_score / ${widget.quiz.questions.length}",
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              "+${_score * 10} Points Earned!",
              style: const TextStyle(color: Color(0xFF23C174), fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to list
            },
            child: const Text(
              "Done",
              style: TextStyle(color: Color(0xFF00E5BC), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.quiz.questions[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Question ${_currentIndex + 1}/${widget.quiz.questions.length}",
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: (_currentIndex + 1) / widget.quiz.questions.length,
              backgroundColor: Colors.grey.shade800,
              color: const Color(0xFF00E5BC),
              minHeight: 6,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 40),

            // Question Text
            Text(
              question.questionText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Urbanist',
                height: 1.3,
              ),
            ),
            const SizedBox(height: 40),

            // Options
            Expanded(
              child: ListView.separated(
                itemCount: question.options.length,
                separatorBuilder: (context, index) => const SizedBox(height: 15),
                itemBuilder: (context, index) {
                  return _buildOption(index, question.options[index], question.correctAnswerIndex);
                },
              ),
            ),

            // Next Button
            if (_isAnswered)
              GestureDetector(
                onTap: _nextQuestion,
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
                    child: Text(
                      _currentIndex == widget.quiz.questions.length - 1 ? "Finish" : "Next Question",
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(int index, String text, int correctIndex) {
    Color borderColor = Colors.white10;
    Color backgroundColor = const Color(0xFF1E1E1E);
    IconData? icon;
    Color iconColor = Colors.transparent;

    if (_isAnswered) {
      if (index == correctIndex) {
        borderColor = const Color(0xFF23C174);
        backgroundColor = const Color(0xFF23C174).withOpacity(0.1);
        icon = Icons.check_circle;
        iconColor = const Color(0xFF23C174);
      } else if (index == _selectedOptionIndex) {
        borderColor = Colors.redAccent;
        backgroundColor = Colors.redAccent.withOpacity(0.1);
        icon = Icons.cancel;
        iconColor = Colors.redAccent;
      }
    } else if (_selectedOptionIndex == index) {
      borderColor = const Color(0xFF00E5BC);
    }

    return GestureDetector(
      onTap: () => _handleOptionTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (icon != null)
              Icon(icon, color: iconColor),
          ],
        ),
      ),
    );
  }
}