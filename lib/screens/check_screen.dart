import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'welcome_screen.dart';
import '../services/auth_service.dart';

class CheckScreen extends StatelessWidget {
  const CheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. Loading State
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Authenticated State -> Show Home
        if (snapshot.hasData) {
          // TODO: Replace this Scaffold with your actual HomeScreen widget
          return Scaffold(
            appBar: AppBar(
              title: const Text("AIcademy Home"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => AuthService().logoutUser(), // Assuming logout method exists
                ),
              ],
            ),
            body: const Center(child: Text("Welcome! You are logged in.")),
          );
        }

        // 3. Unauthenticated State -> Show Login
        return const WelcomeScreen();
      },
    );
  }
}