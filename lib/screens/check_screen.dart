import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';

class CheckScreen extends StatefulWidget {
  const CheckScreen({super.key});

  @override
  State<CheckScreen> createState() => _CheckScreenState();
}

class _CheckScreenState extends State<CheckScreen> {
  final authProvider = AuthProvider();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  bool isLoading = false;
  String? message;

  void _showMessage(String msg, {bool isError = false}) {
    setState(() => message = msg);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _testRegister() async {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        nameController.text.isEmpty) {
      _showMessage('All fields required', isError: true);
      return;
    }

    setState(() => isLoading = true);
    try {
      final user = await authProvider.register(
        email: emailController.text,
        password: passwordController.text,
        fullName: nameController.text,
      );

      if (user != null) {
        _showMessage('Registration successful! User: ${user.email}');
        emailController.clear();
        passwordController.clear();
        nameController.clear();
      }
    } catch (e) {
      _showMessage('Error: $e', isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _testLogin() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showMessage('Email and password required', isError: true);
      return;
    }

    setState(() => isLoading = true);
    try {
      final user = await authProvider.login(
        email: emailController.text,
        password: passwordController.text,
      );

      if (user != null) {
        _showMessage('Login successful! User: ${user.email}');
      }
    } catch (e) {
      _showMessage('Error: $e', isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Phase 1 - Auth Service Test")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, color: Colors.blue, size: 50),
              const SizedBox(height: 20),
              const Text(
                "Auth Service Testing",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: isLoading ? null : _testRegister,
                icon: const Icon(Icons.app_registration),
                label: const Text("Register"),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: isLoading ? null : _testLogin,
                icon: const Icon(Icons.login),
                label: const Text("Login"),
              ),
              const SizedBox(height: 20),
              if (message != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(message!),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
