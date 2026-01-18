import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shedular_model.dart';
import '../services/reminder_service.dart';

class SchedulerPage extends StatefulWidget {
  const SchedulerPage({super.key});

  @override
  State<SchedulerPage> createState() => _SchedulerPageState();
}

class _SchedulerPageState extends State<SchedulerPage> {
  int _selectedDayIndex = 0;
  final ScrollController _taskScrollController = ScrollController();

  @override
  void dispose() {
    _taskScrollController.dispose();
    super.dispose();
  }

  // --- CRUD OPERATIONS ---

  Future<void> _addNewTask() async {
    await _showTaskDialog(title: "Add New Task");
  }

  Future<void> _editTask(Scheduler schedule) async {
    await _showTaskDialog(title: "Edit Task", existingTask: schedule);
  }

  Future<void> _deleteTask(String docId) async {
    await ReminderService.taskRef.doc(docId).delete();
  }

// --- DIALOG FOR ADDING/EDITING TASK ---

  Future<void> _showTaskDialog({required String title, Scheduler? existingTask}) async {
    final TextEditingController titleController = TextEditingController(text: existingTask?.task ?? "");
    DateTime pickedDateTime = existingTask?.time ?? DateTime.now();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text(title, style: const TextStyle(color: Colors.white, fontFamily: 'Urbanist')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00E5BC))),
                  hintText: "What needs to be done?",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 15),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.access_time, color: Color(0xFF00E5BC)),
                title: Text(DateFormat('hh:mm a').format(pickedDateTime), style: const TextStyle(color: Colors.white)),
                onTap: () async {
                  TimeOfDay? time = await ReminderService.pickTime(context, pickedDateTime);
                  if (time != null) {
                    setDialogState(() {
                      pickedDateTime = ReminderService.combine(pickedDateTime, time);
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.white))),
            TextButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty) {
                  if (existingTask == null) {
                    final newTask = Scheduler(
                      task: titleController.text,
                      time: pickedDateTime,
                      dayIndex: _selectedDayIndex,
                    );
                    await ReminderService.taskRef.add(newTask.toMap());
                  } else {
                    await ReminderService.taskRef.doc(existingTask.scheduleId).update({
                      'task': titleController.text,
                      'time': Timestamp.fromDate(pickedDateTime),
                    });
                  }
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text("Save", style: TextStyle(color: Color(0xFF00E5BC))),
            ),
          ],
        ),
      ),
    );
  }

  // --- MAIN BUILDER ---

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
              const Text("Scheduler", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Urbanist')),
              Text(_getSelectedDateString(), style: const TextStyle(color: Color(0xFF00E5BC), fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 25),
              
              // Task Container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(25)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("To Do", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                        IconButton(onPressed: _addNewTask, icon: const Icon(Icons.add_circle, color: Color(0xFF00E5BC), size: 32)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 360,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: ReminderService.taskRef
                            .where('dayIndex', isEqualTo: _selectedDayIndex)
                            .orderBy('time', descending: false)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) return const Center(child: Text("Query error. Check index.", style: TextStyle(color: Colors.red)));
                          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                          var docs = snapshot.data!.docs;
                          if (docs.isEmpty) return const Center(child: Text("Relax! No tasks for today.", style: TextStyle(color: Colors.grey)));

                          return ListView.builder(
                            controller: _taskScrollController,
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final schedule = Scheduler.fromMap(docs[index].data() as Map<String, dynamic>, docs[index].id);
                              return _buildTaskItem(schedule);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _buildHorizontalDatePicker(),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---
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
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(color: const Color(0xFF2C2C2C), borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(schedule.task, style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
              Text(DateFormat('hh:mm a').format(schedule.time), style: const TextStyle(color: Color(0xFF00E5BC), fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

// --- HORIZONTAL DATE PICKER ---
  Widget _buildHorizontalDatePicker() {
    return SizedBox(
      height: 100,
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(15),
                border: isSelected ? Border.all(color: const Color(0xFF00E5BC)) : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat('E').format(date).toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12,fontWeight: FontWeight.bold)),
                  Text(DateFormat('d').format(date), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

// --- HELPER METHODS ---
  String _getSelectedDateString() {
    DateTime date = DateTime.now().add(Duration(days: _selectedDayIndex));
    return DateFormat('EEEE, MMMM d').format(date);
  }

// --- BOTTOM NAVIGATION BAR ---
  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(25, 0, 25, 30),
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(35)),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.folder_outlined, color: Colors.white),
          Icon(Icons.timer_outlined, color: Colors.white),
          Icon(Icons.calendar_today, color: Color(0xFF00E5BC)),
          Icon(Icons.person_outline, color: Colors.white),
        ],
      ),
    );
  }
}