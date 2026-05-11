import 'package:flutter/material.dart';
import '../Vibes/photo_post_screen.dart';
import '../Vibes/text_post_screen.dart';
import '../Vibes/poll_post_screen.dart';

class CreateVibeSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF5F5F0), // Earthy Background
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                _buildOption(
                  sheetContext,
                  icon: Icons.image_rounded,
                  title: "Add Picture with Comment",
                  color: const Color(0xFF6B8E23), // Soft Glowing Olive
                  targetScreen: const PhotoPostScreen(),
                ),
                _buildOption(
                  sheetContext,
                  icon: Icons.text_fields_rounded,
                  title: "Text Vibe",
                  color: const Color(0xFF1B3022), // Deepest Jungle Green
                  targetScreen: const TextPostScreen(),
                ),
                _buildOption(
                  sheetContext,
                  icon: Icons.poll_rounded,
                  title: "Create Poll",
                  color: const Color(0xFF8F9779), // Pistachio
                  targetScreen: const PollPostScreen(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildOption(BuildContext context, {required IconData icon, required String title, required Color color, required Widget targetScreen}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF1B3022))),
      onTap: () {
        Navigator.pop(context); // Close sheet safely
        Navigator.push(context, MaterialPageRoute(builder: (_) => targetScreen));
      },
    );
  }
}