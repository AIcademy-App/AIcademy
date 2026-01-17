import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'screens/settings_screen.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const HomeNavigation(),
    );
  }
}

class HomeNavigation extends StatefulWidget {
  const HomeNavigation({super.key});

  @override
  State<HomeNavigation> createState() => _HomeNavigationState();
}

class _HomeNavigationState extends State<HomeNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const CheckScreen(),
    const ProfileScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

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
