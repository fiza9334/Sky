import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/vibe_model.dart';
import 'report_sheet.dart';

import '../../services/share_service.dart';
import '../../services/mute_service.dart';
import 'report_sheet.dart';

class VibeOptionsSheet {
  static void show(BuildContext context, VibeModel vibe) {
    final bool isOwner = FirebaseAuth.instance.currentUser?.uid == vibe.userId;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF5F5F0), // Earthy background
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10))),
                
                // Common Options
                _buildOption(context, icon: Icons.copy_rounded, title: "Copy Link", onTap: () {
                  Clipboard.setData(ClipboardData(text: "https://yourapp.com/vibe/${vibe.id}"));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Link copied to clipboard")));
                }),
                
                _buildOption(context, icon: Icons.share_rounded, title: "Share via...", onTap: () {
                  Navigator.pop(context);
                  ShareService.shareVibe(vibe);
                }),

                if (!isOwner) ...[
                  const Divider(),
                  _buildOption(context, icon: Icons.volume_off_rounded, title: "Mute User", color: Colors.orange, onTap: () async {
                    Navigator.pop(context);
                    await MuteService.muteUser(vibe.userId);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Muted ${vibe.username}")));
                  }),
                  _buildOption(context, icon: Icons.flag_rounded, title: "Report Vibe", color: Colors.red, onTap: () {
                    Navigator.pop(context);
                    ReportSheet.show(context, vibe.id);
                  }),
                ],

                if (isOwner) ...[
                  const Divider(),
                  _buildOption(context, icon: Icons.delete_outline_rounded, title: "Delete Vibe", color: Colors.red, onTap: () async {
                    Navigator.pop(context);
                    await FirebaseFirestore.instance.collection('vibes').doc(vibe.id).delete();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vibe deleted")));
                  }),
                ]
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildOption(BuildContext context, {required IconData icon, required String title, Color color = Colors.black87, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 16)),
      onTap: onTap,
    );
  }
}