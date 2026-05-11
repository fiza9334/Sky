import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportSheet {
  static final List<String> _reasons = [
    "Spam", "Harassment", "Fake Information", "Nudity", "Violence", "Hate Speech", "Other"
  ];

  static void show(BuildContext context, String postId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Report Vibe", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _reasons.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_reasons[index], style: const TextStyle(color: Colors.black87)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                      onTap: () => _submitReport(sheetContext, postId, _reasons[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> _submitReport(BuildContext context, String postId, String reason) async {
    Navigator.pop(context); // Close sheet immediately for UX
    
    try {
      await FirebaseFirestore.instance.collection('reports').add({
        'postId': postId,
        'reportedBy': FirebaseAuth.instance.currentUser?.uid ?? 'Anonymous',
        'reason': reason,
        'timestamp': FieldValue.serverTimestamp(),
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Report submitted successfully. We will review it.")));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to submit report.")));
      }
    }
  }
}