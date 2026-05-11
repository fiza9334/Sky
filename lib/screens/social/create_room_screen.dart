// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class CreateRoomScreen extends StatefulWidget {
//   const CreateRoomScreen({super.key});

//   @override
//   State<CreateRoomScreen> createState() => _CreateRoomScreenState();
// }

// class _CreateRoomScreenState extends State<CreateRoomScreen> {
//   final _nameController = TextEditingController();
//   final _descController = TextEditingController();
//   String _selectedLang = "Hindi";
//   bool _isPrivate = false;

//   // IMPORTANT: Dispose controllers to save memory
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _descController.dispose();
//     super.dispose();
//   }

//   Future<void> _handleCreateRoom() async {
//     if (_nameController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please enter a Room Name")),
//       );
//       return;
//     }

//     final String? userId = FirebaseAuth.instance.currentUser?.uid;
//     if (userId == null) {
//       print("Error: No authenticated user found.");
//       return;
//     }

//     try {
//       await FirebaseFirestore.instance.collection('rooms').add({
//         'roomName': _nameController.text.trim(),
//         'description': _descController.text.trim(),
//         'language': _selectedLang,
//         'isPrivate': _isPrivate,
//         'leaderId': userId,
//         'createdAt': FieldValue.serverTimestamp(),
//         'isActive': true,
//         'onStageCount': 1,
//         'participants': [userId],
//       });

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Room Created Successfully! 🔥"),
//             backgroundColor: Colors.green,
//           ),
//         );
//         Navigator.pop(context);
//       }
//     } catch (e) {
//       print("Firestore Create Room Error: $e");
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Failed to create room: $e"),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Create Room")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _nameController,
//               decoration: const InputDecoration(labelText: "Room Name *"),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: _descController,
//               decoration: const InputDecoration(labelText: "Description"),
//             ),
//             const SizedBox(height: 12),
//             DropdownButtonFormField<String>(
//               value: _selectedLang,
//               items: ["Hindi", "English", "Urdu"].map((lang) {
//                 return DropdownMenuItem(value: lang, child: Text(lang));
//               }).toList(),
//               onChanged: (val) => setState(() => _selectedLang = val!),
//               decoration: const InputDecoration(labelText: "Language"),
//             ),
//             SwitchListTile(
//               title: const Text("Private Room"),
//               value: _isPrivate,
//               onChanged: (val) => setState(() => _isPrivate = val),
//             ),
//             const Spacer(),
//             SizedBox(
//               width: double.infinity,
//               height: 50,
//               child: ElevatedButton(
//                 onPressed: _handleCreateRoom,
//                 child: const Text("Create Room Now"),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import '../../services/room_service.dart';
// import 'room_detail_screen.dart';

// class CreateRoomScreen extends StatefulWidget {
//   const CreateRoomScreen({super.key});

//   @override
//   State<CreateRoomScreen> createState() => _CreateRoomScreenState();
// }

// class _CreateRoomScreenState extends State<CreateRoomScreen> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _topicController = TextEditingController();
//   bool _isLoading = false;

//   Future<void> _handleCreateRoom() async {
//     if (_nameController.text.trim().isEmpty) return;

//     setState(() => _isLoading = true);
//     try {
//       String? roomId = await RoomService().createRoom(
//         _nameController.text.trim(),
//         _topicController.text.trim(),
//         'public',
//       );

//       // FIX: Check if widget is still mounted before navigating
//       if (!mounted || roomId == null) return;
      
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => RoomDetailScreen(roomId: roomId)),
//       );
//     } catch (e) {
//       if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Create Room")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Room Name")),
//             TextField(controller: _topicController, decoration: const InputDecoration(labelText: "Topic")),
//             const SizedBox(height: 20),
//             _isLoading 
//                 ? const CircularProgressIndicator()
//                 : ElevatedButton(onPressed: _handleCreateRoom, child: const Text("Start Room")),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import '../../services/room_service.dart';
import 'room_detail_screen.dart';
import '../social/widgets/custom_input_field.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  bool _isPublic = true;
  bool _isLoading = false;

  Future<void> _handleCreateRoom() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Room Name is compulsory")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      String? roomId = await RoomService().createRoom(
        _nameController.text.trim(),
        _descController.text.trim(),
        _isPublic ? 'public' : 'private',
      );

      if (!mounted || roomId == null) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => RoomDetailScreen(roomId: roomId)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Create Room", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Pic Section
            GestureDetector(
              onTap: () { /* Handle Image Picker */ },
              child: Column(
                children: [
                  Container(
                    height: 100, width: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: Colors.white54, size: 32),
                  ),
                  const SizedBox(height: 12),
                  const Text("Set Room Profile Pic", style: TextStyle(color: Color(0xFF6B8E23), fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Inputs
            CustomInputField(controller: _nameController, label: "Room Name (Compulsory)"),
            const SizedBox(height: 24),
            CustomInputField(controller: _descController, label: "Description (Optional)", maxLines: 3),
            const SizedBox(height: 32),

            // Public/Private Toggle
            Container(
              height: 50,
              decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(25)),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isPublic = true),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _isPublic ? const Color(0xFF6B8E23) : Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        alignment: Alignment.center,
                        child: Text("Public", style: TextStyle(color: _isPublic ? Colors.white : Colors.white54, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isPublic = false),
                      child: Container(
                        decoration: BoxDecoration(
                          color: !_isPublic ? const Color(0xFF1B3022) : Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        alignment: Alignment.center,
                        child: Text("Private", style: TextStyle(color: !_isPublic ? Colors.white : Colors.white54, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _isPublic 
                  ? "Public rooms are visible to everyone in the ON STAGE NOW feed."
                  : "Private rooms are hidden from public feed and only visible to system admin.",
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleCreateRoom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B8E23),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 5,
                ),
                child: _isLoading 
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Start Room", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}