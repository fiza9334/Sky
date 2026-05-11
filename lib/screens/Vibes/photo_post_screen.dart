import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PhotoPostScreen extends StatefulWidget {
  const PhotoPostScreen({super.key});

  @override
  State<PhotoPostScreen> createState() => _PhotoPostScreenState();
}

class _PhotoPostScreenState extends State<PhotoPostScreen> {
  final TextEditingController _captionController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source, imageQuality: 70);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _postVibe() async {
    if (_imageFile == null) return;

    setState(() => _isLoading = true);
    try {
      User? user = FirebaseAuth.instance.currentUser;
      String fileName = 'vibes/${user?.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // 1. Upload Image to Firebase Storage
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = storageRef.putFile(_imageFile!);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // 2. Save data to Firestore
      await FirebaseFirestore.instance.collection('vibes').add({
        'userId': user?.uid ?? '',
        'username': user?.displayName ?? 'Anonymous',
        'userProfilePic': user?.photoURL ?? '',
        'type': 'photo',
        'content': _captionController.text.trim(),
        'imageUrl': downloadUrl,
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
        title: const Text("Photo Vibe", style: TextStyle(color: Color(0xFF1B3022), fontWeight: FontWeight.bold)),
        actions: [
          _isLoading
              ? const Padding(padding: EdgeInsets.all(15.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6B8E23))))
              : TextButton(
                  onPressed: _imageFile == null ? null : _postVibe,
                  child: Text("POST", style: TextStyle(color: _imageFile == null ? Colors.grey : const Color(0xFF6B8E23), fontWeight: FontWeight.bold, fontSize: 16)),
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => _pickImage(ImageSource.gallery),
              child: Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF8F9779).withOpacity(0.2), // Pistachio light
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFF8F9779)),
                ),
                child: _imageFile != null
                    ? ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(_imageFile!, fit: BoxFit.cover))
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined, size: 50, color: Color(0xFF6B8E23)),
                          SizedBox(height: 10),
                          Text("Tap to select a photo", style: TextStyle(color: Color(0xFF1B3022))),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _captionController,
              maxLines: 3,
              style: const TextStyle(color: Color(0xFF1B3022)),
              decoration: const InputDecoration(
                hintText: "Write a caption...",
                border: InputBorder.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}