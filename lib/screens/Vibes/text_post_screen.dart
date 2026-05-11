import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TextPostScreen extends StatefulWidget {
  const TextPostScreen({super.key});

  @override
  State<TextPostScreen> createState() => _TextPostScreenState();
}

class _TextPostScreenState extends State<TextPostScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;

  Future<void> _postVibe() async {
    if (_textController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);
    try {
      User? user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('vibes').add({
        'userId': user?.uid ?? '',
        'username': user?.displayName ?? 'Anonymous',
        'userProfilePic': user?.photoURL ?? '',
        'type': 'text',
        'content': _textController.text.trim(),
        'imageUrl': '',
        'timestamp': FieldValue.serverTimestamp(),
        'likesCount': 0,
        'commentsCount': 0,
      });
      if (mounted) {
        Navigator.pop(context); // Post hone ke baad wapas feed pe
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0), // Earthy background
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F0),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1B3022)), // Deepest Jungle Green
        title: const Text("Create Text Vibe", style: TextStyle(color: Color(0xFF1B3022), fontWeight: FontWeight.bold)),
        actions: [
          _isLoading
              ? const Padding(padding: EdgeInsets.all(15.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6B8E23))))
              : TextButton(
                  onPressed: _postVibe,
                  child: const Text("POST", style: TextStyle(color: Color(0xFF6B8E23), fontWeight: FontWeight.bold, fontSize: 16)), // Soft Glowing Olive
                ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: TextField(
          controller: _textController,
          maxLines: null,
          autofocus: true,
          style: const TextStyle(fontSize: 18, color: Color(0xFF1B3022)),
          decoration: const InputDecoration(
            hintText: "What's your vibe today?",
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}