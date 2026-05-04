import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import '..auth_screen.dart'; // Aapke auth_screen.dart ka sahi path check kar lena
import '../screens/auth_screen.dart';
import '../screens/profile_screen.dart';
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // Earthy Minimalist Palette
  static const Color jungleGreen = Color(0xFF141A14);
  static const Color oliveAccent = Color(0xFFA5B880);
  static const Color cardColor = Color(0xFF1E261E);

  // Logout Logic
  Future<void> _logout(BuildContext context) async {
    // Confirmation Dialog dikhana achha rehta hai
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: cardColor,
          title: const Text('Logout', style: TextStyle(color: Colors.white)),
          content: const Text('Are you sure you want to logout?', style: TextStyle(color: Colors.grey)),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
              onPressed: () async {
                Navigator.of(context).pop(); // Dialog band karein
                await FirebaseAuth.instance.signOut(); // Firebase se logout
                if (context.mounted) {
                  // Wapas Login screen par bhejein aur navigation stack clear karein
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const AuthScreen()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: jungleGreen,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white), // Back button color
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // Yahan aap future mein aur bhi settings add kar sakte hain
          _buildSettingsTile(
            icon: Icons.notifications_none,
            title: 'Notifications',
            onTap: () {
              // TODO: Navigate to Notifications Settings
            },
          ),
          _buildSettingsTile(
            icon: Icons.lock_outline,
            title: 'Privacy & Security',
            onTap: () {
              // TODO: Navigate to Privacy Settings
            },
          ),
          _buildSettingsTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {
              // TODO: Navigate to Help section
            },
          ),
          
          const Divider(color: Colors.white12, height: 40, thickness: 1), // Divider
          
          // Logout Button
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }

  // Helper widget taaki settings list clean lage
  Widget _buildSettingsTile({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: oliveAccent),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
      onTap: onTap,
    );
  }
}