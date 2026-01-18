import 'package:cloud_firestore/cloud_firestore.dart';

class Scheduler {
  final String? scheduleId;
  String task;
  DateTime time;
  int dayIndex;

  Scheduler({
    this.scheduleId,
    required this.task,
    required this.time,
    required this.dayIndex,
  });

  factory Scheduler.fromMap(Map<String, dynamic> map, String id) {
    return Scheduler(
      scheduleId: id,
      task: map['task'] ?? '',
      time: map['time'] != null ? (map['time'] as Timestamp).toDate() : DateTime.now(),
      dayIndex: map['dayIndex'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'task': task,
      'time': Timestamp.fromDate(time),
      'dayIndex': dayIndex,
    };
  }
}