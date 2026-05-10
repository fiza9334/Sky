import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedLang = "Hindi";
  bool _isPrivate = false;

  // IMPORTANT: Dispose controllers to save memory
  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateRoom() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a Room Name")),
      );
      return;
    }

    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print("Error: No authenticated user found.");
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('rooms').add({
        'roomName': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'language': _selectedLang,
        'isPrivate': _isPrivate,
        'leaderId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'onStageCount': 1,
        'participants': [userId],
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Room Created Successfully! 🔥"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print("Firestore Create Room Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to create room: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Room")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Room Name *"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedLang,
              items: ["Hindi", "English", "Urdu"].map((lang) {
                return DropdownMenuItem(value: lang, child: Text(lang));
              }).toList(),
              onChanged: (val) => setState(() => _selectedLang = val!),
              decoration: const InputDecoration(labelText: "Language"),
            ),
            SwitchListTile(
              title: const Text("Private Room"),
              value: _isPrivate,
              onChanged: (val) => setState(() => _isPrivate = val),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _handleCreateRoom,
                child: const Text("Create Room Now"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}