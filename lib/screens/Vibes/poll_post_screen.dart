import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PollPostScreen extends StatefulWidget {
  const PollPostScreen({super.key});

  @override
  State<PollPostScreen> createState() => _PollPostScreenState();
}

class _PollPostScreenState extends State<PollPostScreen> {
  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [TextEditingController(), TextEditingController()];
  bool _isLoading = false;

  void _addOption() {
    if (_optionControllers.length < 4) {
      setState(() => _optionControllers.add(TextEditingController()));
    }
  }

  Future<void> _postVibe() async {
    if (_questionController.text.trim().isEmpty || _optionControllers.any((c) => c.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      User? user = FirebaseAuth.instance.currentUser;
      
      // Store poll options properly
      List<Map<String, dynamic>> options = _optionControllers.map((c) => {
        'text': c.text.trim(),
        'votes': 0,
      }).toList();

      await FirebaseFirestore.instance.collection('vibes').add({
        'userId': user?.uid ?? '',
        'username': user?.displayName ?? 'Anonymous',
        'userProfilePic': user?.photoURL ?? '',
        'type': 'poll',
        'content': _questionController.text.trim(), // The question
        'pollOptions': options, // The array of options
        'imageUrl': '',
        'timestamp': FieldValue.serverTimestamp(),
        'likesCount': 0,
        'commentsCount': 0,
      });
      
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F0),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1B3022)),
        title: const Text("Create Poll", style: TextStyle(color: Color(0xFF1B3022), fontWeight: FontWeight.bold)),
        actions: [
          _isLoading
              ? const Padding(padding: EdgeInsets.all(15.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6B8E23))))
              : TextButton(onPressed: _postVibe, child: const Text("POST", style: TextStyle(color: Color(0xFF6B8E23), fontWeight: FontWeight.bold, fontSize: 16))),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _questionController,
              maxLines: 2,
              style: const TextStyle(fontSize: 18, color: Color(0xFF1B3022), fontWeight: FontWeight.w600),
              decoration: const InputDecoration(hintText: "Ask a question...", border: InputBorder.none),
            ),
            const SizedBox(height: 20),
            ...List.generate(_optionControllers.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  controller: _optionControllers[index],
                  decoration: InputDecoration(
                    hintText: "Option ${index + 1}",
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
              );
            }),
            if (_optionControllers.length < 4)
              TextButton.icon(
                onPressed: _addOption,
                icon: const Icon(Icons.add, color: Color(0xFF6B8E23)),
                label: const Text("Add Option", style: TextStyle(color: Color(0xFF6B8E23))),
              ),
          ],
        ),
      ),
    );
  }
}