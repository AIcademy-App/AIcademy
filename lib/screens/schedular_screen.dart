import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/shedular_model.dart';

class SchedulerPage extends StatefulWidget {
  const SchedulerPage({super.key});

  @override
  State<SchedulerPage> createState() => _SchedulerPageState();
}

class _SchedulerPageState extends State<SchedulerPage> {
  int _selectedDayIndex = 0;
  final ScrollController _taskScrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get current user ID or fallback for testing
  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? "test_user_123";

  // Firestore Collection Reference path: users/{uid}/tasks
  CollectionReference get _taskRef => _firestore
      .collection('users')
      .doc(_uid)
      .collection('tasks');

  @override
  void dispose() {
    _taskScrollController.dispose();
    super.dispose();
  }

  // --- CRUD OPERATIONS ---

  Future<void> _addNewTask() async {
    await showDialog(
      context: context,
      builder: (context) => _buildTaskDialog(
        title: "Add New Task",
        onSave: (val) async {
          if (val.isNotEmpty) {
            final newSchedule = Scheduler(
              task: val,
              time: DateTime.now(),
              dayIndex: _selectedDayIndex,
            );
            await _taskRef.add(newSchedule.toMap());
          }
        },
      ),
    );
  }

  Future<void> _editTask(Scheduler schedule) async {
    await showDialog(
      context: context,
      builder: (context) => _buildTaskDialog(
        title: "Edit Task",
        initialValue: schedule.task,
        onSave: (val) async {
          if (val.isNotEmpty) {
            await _taskRef.doc(schedule.scheduleId).update({'task': val});
          }
        },
      ),
    );
  }

  Future<void> _deleteTask(String docId) async {
    await _taskRef.doc(docId).delete();
  }

  // --- UI BUILDERS ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: _buildBottomNav(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                "Scheduler",
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Urbanist'),
              ),
              Text(
                _getSelectedDateString(),
                style: const TextStyle(color: Color(0xFF00E5BC), fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Urbanist'),
              ),
              const SizedBox(height: 25),

              // Task List Container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("To Do", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Urbanist')),
                        IconButton(
                          onPressed: _addNewTask,
                          icon: const Icon(Icons.add_circle, color: Color(0xFF00E5BC), size: 32),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 320,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _taskRef.where('dayIndex', isEqualTo: _selectedDayIndex).snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) return const Center(child: Text("Error loading tasks", style: TextStyle(color: Colors.red)));
                          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF00E5BC)));

                          var docs = snapshot.data!.docs;
                          if (docs.isEmpty) return const Center(child: Text("No tasks found", style: TextStyle(color: Colors.grey)));

                          return ListView.builder(
                            controller: _taskScrollController,
                            physics: const BouncingScrollPhysics(),
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final schedule = Scheduler.fromMap(
                                docs[index].data() as Map<String, dynamic>, 
                                docs[index].id
                              );
                              return _buildTaskItem(schedule);
                            },
                          );
                        },
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down, color: Color(0xFFC4C4C4), size: 30),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _buildHorizontalDatePicker(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
// Individual Task Item Widget
  Widget _buildTaskItem(Scheduler schedule) {
    return Dismissible(
      key: Key(schedule.scheduleId!),
      onDismissed: (_) => _deleteTask(schedule.scheduleId!),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10), 
        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: () => _editTask(schedule),
        child: Container(
          height: 65, 
          width: double.infinity,
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(color: const Color(0xFF2C2C2C), borderRadius: BorderRadius.circular(12)),
          child: Text(
            schedule.task,
            maxLines: 1, // Prevents overflow and maintains size uniformity
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Urbanist'),
          ),
        ),
      ),
    );
  }

// Horizontal Date Picker Widget
  Widget _buildHorizontalDatePicker() {
    return SizedBox(
      height: 110, 
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14,
        itemBuilder: (context, index) {
          DateTime date = DateTime.now().add(Duration(days: index));
          bool isSelected = _selectedDayIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedDayIndex = index),
            child: Container(
              margin: const EdgeInsets.only(right: 15),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(15),
                border: isSelected ? Border.all(color: const Color(0xFF00E5BC), width: 1) : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat('E').format(date).toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12)),
                  const SizedBox(height: 5),
                  Text(DateFormat('d').format(date), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                  if (isSelected) ...[
                    const SizedBox(height: 5),
                    Container(height: 3, width: 20, color: const Color(0xFF00E5BC)),
                  ]
                ],
              ),
            ),
          );
        },
      ),
    );
  }

// Task Dialog for Adding/Editing
  Widget _buildTaskDialog({required String title, String initialValue = "", required Function(String) onSave}) {
    String value = initialValue;
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      content: TextField(
        controller: TextEditingController(text: initialValue),
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00E5BC))),
        ),
        onChanged: (val) => value = val,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.white))),
        TextButton(
          onPressed: () {
            onSave(value);
            Navigator.pop(context);
          },
          child: const Text("Save", style: TextStyle(color: Color(0xFF00E5BC))),
        ),
      ],
    );
  }

// Get Selected Date String with Ordinal Suffix
  String _getSelectedDateString() {
    DateTime selectedDate = DateTime.now().add(Duration(days: _selectedDayIndex));
    int day = selectedDate.day;
    
    // Ordinal Suffix Logic (st, nd, rd, th)
    String suffix = 'th';
    if (day >= 11 && day <= 13) {
      suffix = 'th';
    } else {
      switch (day % 10) {
        case 1: suffix = 'st'; break;
        case 2: suffix = 'nd'; break;
        case 3: suffix = 'rd'; break;
        default: suffix = 'th';
      }
    }

    String dayName = DateFormat('EEEE').format(selectedDate);
    return "$dayName $day$suffix";
  }

// Bottom Navigation Bar Widget
  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(25, 0, 25, 30),
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(35)),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.folder_outlined, color: Colors.white, size: 28),
          Icon(Icons.timer_outlined, color: Colors.white, size: 28),
          Icon(Icons.calendar_today, color: Color(0xFF00E5BC), size: 28),
          Icon(Icons.person_outline, color: Colors.white, size: 28),
        ],
      ),
    );
  }
}