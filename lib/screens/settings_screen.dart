import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final authProvider = AuthProvider();
  bool isDarkMode = true;

  void _logout() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e1e),
        title: const Text('Log Out', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await authProvider.logout();
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: const Color(0xFF18a394),
              ),
              child: const Icon(Icons.school, size: 16, color: Colors.black),
            ),
            const SizedBox(width: 8),
            const Text(
              'AIcademy',
              style: TextStyle(
                color: Color(0xFF18a394),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Settings Title
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Settings',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF18a394),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Settings List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Account
                  _buildSettingsItem(
                    icon: Icons.person,
                    label: 'Account',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Account settings')),
                      );
                    },
                  ),
                  // Notifications
                  _buildSettingsItem(
                    icon: Icons.notifications,
                    label: 'Notifications',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notification settings')),
                      );
                    },
                  ),
                  // Dark Mode
                  _buildDarkModeItem(),
                  // Privacy & Security
                  _buildSettingsItem(
                    icon: Icons.security,
                    label: 'Privacy & Security',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Privacy settings')),
                      );
                    },
                  ),
                  // Language
                  _buildSettingsItem(
                    icon: Icons.language,
                    label: 'Language',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Language settings')),
                      );
                    },
                  ),
                  // Subscription
                  _buildSettingsItem(
                    icon: Icons.star,
                    label: 'Subscription',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Subscription settings')),
                      );
                    },
                  ),
                  // Help & Support
                  _buildSettingsItem(
                    icon: Icons.help,
                    label: 'Help & Support',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Help & support')),
                      );
                    },
                  ),
                  // About
                  _buildSettingsItem(
                    icon: Icons.info,
                    label: 'About',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('About AIcademy')),
                      );
                    },
                  ),
                  // Log Out
                  _buildSettingsItem(
                    icon: Icons.logout,
                    label: 'Log Out',
                    isLogout: true,
                    onTap: _logout,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            // Footer Icon
            Opacity(
              opacity: 0.3,
              child: Icon(
                Icons.verified_user,
                size: 48,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: isLogout ? Colors.red : const Color(0xFF18a394),
                  size: 24,
                ),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: TextStyle(
                    color: isLogout ? Colors.red : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isLogout ? Colors.red : Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDarkModeItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.dark_mode, color: Color(0xFF18a394), size: 24),
              const SizedBox(width: 16),
              const Text(
                'Dark Mode',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Switch(
            value: isDarkMode,
            onChanged: (value) {
              setState(() => isDarkMode = value);
            },
            activeThumbColor: const Color(0xFF18a394),
            activeTrackColor: const Color(0xFF18a394).withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}
