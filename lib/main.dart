import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Load Environment variables (for AI later)
  try {
    await dotenv.load(fileName: ".env");
    print("✅ Env loaded");
  } catch (e) {
    print("⚠️ Env file not found (Create it later)");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Phase 0 Check")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Firebase Status: Connected"),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  // TEST: Write to Firestore
                  try {
                    await FirebaseFirestore.instance
                        .collection('test_setup')
                        .add({'timestamp': DateTime.now().toString(), 'status': 'working'});
                    print("✅ Firestore Write Success!");
                  } catch (e) {
                    print("❌ Error: $e");
                  }
                },
                child: const Text("Test Database Write"),
              )
            ],
          ),
        ),
      ),
    );
  }
}