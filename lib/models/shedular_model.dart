class Scheduler {
  String id; 
  String task;
  DateTime time;
  bool isCompleted;

  Scheduler({
    required this.id,
    required this.task,
    required this.time,
    this.isCompleted = false,
  });

  // Convert for Firestore
  Map<String, dynamic> toMap() {
    return {
      'task': task,
      'time': time.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  // Create object from Firestore data
  factory Scheduler.fromMap(String id, Map<String, dynamic> map) {
    return Scheduler(
      id: id,
      task: map['task'] ?? '',
      time: DateTime.parse(map['time']),
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}