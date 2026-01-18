import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReminderService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static String get uid => FirebaseAuth.instance.currentUser?.uid ?? "test_user_123";

  static CollectionReference get taskRef => _firestore
      .collection('users')
      .doc(uid)
      .collection('tasks');

  // Logic to pick a Date
  static Future<DateTime?> pickDate(BuildContext context, DateTime initialDate) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00E5BC),
            onPrimary: Colors.black,
            surface: Color(0xFF1E1E1E),
          ),
        ),
        child: child!,
      ),
    );
  }

  // Logic to pick a Time
  static Future<TimeOfDay?> pickTime(BuildContext context, DateTime initialTime) async {
    return await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialTime),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00E5BC),
            onPrimary: Colors.black,
            surface: Color(0xFF1E1E1E),
          ),
        ),
        child: child!,
      ),
    );
  }

  static DateTime combine(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
}