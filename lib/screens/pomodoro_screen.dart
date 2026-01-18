import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PomodoroPage extends StatefulWidget {
  const PomodoroPage({super.key});

  @override
  State<PomodoroPage> createState() => _PomodoroPageState();
}

class _PomodoroPageState extends State<PomodoroPage> {
  Timer? _timer;
  

  int _totalSeconds = 25 * 60;
  int _secondsRemaining = 25 * 60;
  bool _isRunning = false;

  String get userId => FirebaseAuth.instance.currentUser?.uid ?? "";

  final Color gradientStart = const Color(0xFF23C174);  
  final Color gradientEnd = const Color(0xFF00C9E0);

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else {
            _timer?.cancel();
            _isRunning = false;
            _handleSessionComplete();
          }
        });
      });
    }
    setState(() => _isRunning = !_isRunning);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = _totalSeconds;
      _isRunning = false;
    });
  }

  // Opens a bottom sheet to adjust focus time
  void _showTimePicker(BuildContext context) {
    if (_isRunning) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pause the timer to adjust time")),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          height: 300,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                "Adjust Focus Time",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 50,
                  perspective: 0.005,
                  onSelectedItemChanged: (index) {
                    setState(() {
                      // Increments of 5 minutes
                      _totalSeconds = (index + 1) * 5 * 60;
                      _secondsRemaining = _totalSeconds;
                    });
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: 12, 
                    builder: (context, index) => Center(
                      child: Text(
                        "${(index + 1) * 5} Minutes",
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [gradientStart, gradientEnd]),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Center(
                    child: Text("DONE", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleSessionComplete() async {
    if (userId.isEmpty) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'points': FieldValue.increment(10)});
    } catch (e) {
      debugPrint("Error updating points: $e");
    }
  }

  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return "${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), 
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Pomodoro Timer",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Urbanist',
                  ),
                ),
                _buildTopActionIcon(Icons.tune),
              ],
            ),
            const Spacer(),
            
            // --- GRADIENT PROGRESS RING ---
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Gray Background Ring
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 15,
                      color: const Color(0xFF2C2C2C),
                    ),
                  ),
                  // Gradient Progress Layer
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: Transform.rotate(
                      angle: -math.pi / 2, 
                      child: CustomPaint(
                        painter: GradientProgressPainter(
                          progress: _secondsRemaining / _totalSeconds,
                          startColor: gradientStart,
                          endColor: gradientEnd,
                        ),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(_secondsRemaining),
                        style: const TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        "Focus Session",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const Spacer(),

            // --- GRADIENT BUTTONS ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_secondsRemaining < _totalSeconds)
                  _buildCircleButton(
                    _isRunning ? Icons.play_arrow : Icons.pause, 
                    _toggleTimer
                  ),
                if (_secondsRemaining < _totalSeconds) const SizedBox(width: 15),

                GestureDetector(
                  onTap: _toggleTimer,
                  child: Container(
                    width: 180,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [gradientStart, gradientEnd],
                      ),
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: gradientStart.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        )
                      ]
                    ),
                    child: Center(
                      child: Text(
                        _isRunning ? "PAUSE" : "START",
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 15),
                _buildCircleButton(Icons.stop, _resetTimer),
              ],
            ),
            const SizedBox(height: 220),
          ],
        ),
      ),
    );
  }

  // Clickable Settings Icon
  Widget _buildTopActionIcon(IconData icon) {
    return GestureDetector(
      onTap: () => _showTimePicker(context),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white70),
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white70, size: 28),
      ),
    );
  }
}

class GradientProgressPainter extends CustomPainter {
  final double progress;
  final Color startColor;
  final Color endColor;

  GradientProgressPainter({
    required this.progress,
    required this.startColor,
    required this.endColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..shader = SweepGradient(
        colors: [startColor, endColor],
        stops: const [0.0, 1.0],
        transform: const GradientRotation(0),
      ).createShader(rect);

    canvas.drawArc(
      rect.deflate(paint.strokeWidth / 2),
      0,
      math.pi * 2 * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}