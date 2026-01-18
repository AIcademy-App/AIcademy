import 'package:flutter/material.dart';
import 'schedular_screen.dart';
import 'project_screen.dart';
import 'profile_screen.dart';

// --- THEME CONSTANTS ---
class AppColors {
  static const Color backgroundColor = Color(0xFF121212);
  static const Color accentCyan = Color(0xFF00E5BC);
  static const Color navBarGrey = Color(0xFF1E1E1E);
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

//we needa add a settings icon and then link it to settings screen
//profile screen only works when user is logged in
  final List<Widget> _pages = [
    const ProjectPage(),
    const Center(child: Text("Pomodoro Timer (Empty)")),
    const SchedulerPage(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _pages),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(30, 0, 30, 40),
        child: Container(
          height: 65,
          decoration: BoxDecoration(
            color: AppColors.navBarGrey,
            borderRadius: BorderRadius.circular(35),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(Icons.folder_open_outlined, 0),
              _buildNavItem(Icons.timer_outlined, 1),
              _buildNavItem(Icons.calendar_today_outlined, 2),
              _buildNavItem(Icons.person_outline, 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Icon(
        icon,
        size: 40,
        color: isSelected ? AppColors.accentCyan : Colors.white,
      ),
    );
  }
}
