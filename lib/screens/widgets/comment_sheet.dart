// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:timeago/timeago.dart' as timeago;

// import '../../services/vibe_service.dart';

// class CommentSheet extends StatefulWidget {
//   final String vibeId;
//   const CommentSheet({super.key, required this.vibeId});

//   // Helper method to open the sheet easily from anywhere
//   static void show(BuildContext context, String vibeId) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true, // IMPORTANT: Allows sheet to move up with keyboard
//       backgroundColor: Colors.transparent,
//       builder: (context) => CommentSheet(vibeId: vibeId),
//     );
//   }

//   @override
//   State<CommentSheet> createState() => _CommentSheetState();
// }

// class _CommentSheetState extends State<CommentSheet> {
//   final TextEditingController _commentController = TextEditingController();
//   final User? currentUser = FirebaseAuth.instance.currentUser;
//   bool _isPosting = false;

//   Future<void> _postComment() async {
//     if (_commentController.text.trim().isEmpty || currentUser == null) return;

//     setState(() => _isPosting = true);
    
//     try {
//       await VibeService().addComment(
//         widget.vibeId,
//         _commentController.text.trim(),
//         currentUser!.displayName ?? 'Anonymous',
//         currentUser!.photoURL ?? '',
//       );
//       _commentController.clear();
//       FocusScope.of(context).unfocus(); // Close keyboard after posting
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
//       }
//     } finally {
//       if (mounted) setState(() => _isPosting = false);
//     }
//   }

//   @override
//   void dispose() {
//     _commentController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: MediaQuery.of(context).size.height * 0.75, // Sheet covers 75% of screen
//       decoration: const BoxDecoration(
//         color: Color(0xFFF5F5F0), // Earthy Background
//         borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
//       ),
//       child: Column(
//         children: [
//           // Drag Handle & Title
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 12),
//             child: Column(
//               children: [
//                 Container(
//                   width: 40, height: 5,
//                   decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10)),
//                 ),
//                 const SizedBox(height: 12),
//                 const Text("Comments", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B3022))),
//                 const Divider(height: 20),
//               ],
//             ),
//           ),

//           // Comments List
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('vibes')
//                   .doc(widget.vibeId)
//                   .collection('comments')
//                   .orderBy('timestamp', descending: true)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator(color: Color(0xFF6B8E23)));
//                 }
                
//                 var docs = snapshot.data?.docs ?? [];
                
//                 if (docs.isEmpty) {
//                   return const Center(
//                     child: Text("No comments yet. Be the first to vibe!", style: TextStyle(color: Colors.grey)),
//                   );
//                 }

//                 return ListView.builder(
//                   reverse: true, // Newest comments at the bottom
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   itemCount: docs.length,
//                   itemBuilder: (context, index) {
//                     var data = docs[index].data() as Map<String, dynamic>;
//                     DateTime time = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();

//                     return Padding(
//                       padding: const EdgeInsets.only(bottom: 16),
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           CircleAvatar(
//                             radius: 18,
//                             backgroundColor: const Color(0xFF8F9779).withOpacity(0.3),
//                             backgroundImage: data['userProfilePic'] != null && data['userProfilePic'].toString().isNotEmpty 
//                                 ? CachedNetworkImageProvider(data['userProfilePic']) : null,
//                             child: data['userProfilePic'] == null || data['userProfilePic'].toString().isEmpty 
//                                 ? const Icon(Icons.person, size: 20, color: Color(0xFF1B3022)) : null,
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   children: [
//                                     Text(data['username'] ?? 'User', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B3022), fontSize: 13)),
//                                     const SizedBox(width: 8),
//                                     Text(timeago.format(time), style: const TextStyle(color: Colors.grey, fontSize: 11)),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(data['text'] ?? '', style: const TextStyle(color: Colors.black87, fontSize: 14)),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),

//           // Input Box (Handles Keyboard automatically)
//           Padding(
//             padding: EdgeInsets.only(
//               bottom: MediaQuery.of(context).viewInsets.bottom, // Pushes text field up when keyboard opens
//               left: 16, right: 16, top: 12,
//             ),
//             child: SafeArea(
//               child: Row(
//                 children: [
//                   CircleAvatar(
//                     radius: 20,
//                     backgroundColor: Colors.grey[200],
//                     backgroundImage: currentUser?.photoURL != null ? CachedNetworkImageProvider(currentUser!.photoURL!) : null,
//                     child: currentUser?.photoURL == null ? const Icon(Icons.person, color: Colors.grey) : null,
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: TextField(
//                       controller: _commentController,
//                       decoration: InputDecoration(
//                         hintText: "Add a comment...",
//                         hintStyle: const TextStyle(color: Colors.grey),
//                         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                         filled: true,
//                         fillColor: Colors.white,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(25),
//                           borderSide: BorderSide(color: Colors.grey.shade300),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(25),
//                           borderSide: BorderSide(color: Colors.grey.shade300),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(25),
//                           borderSide: const BorderSide(color: Color(0xFF6B8E23)),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   _isPosting 
//                     ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6B8E23))))
//                     : IconButton(
//                         icon: const Icon(Icons.send_rounded, color: Color(0xFF6B8E23), size: 28),
//                         onPressed: _postComment,
//                       ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 10),
//         ],
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../services/vibe_service.dart';

class CommentSheet extends StatefulWidget {
  final String vibeId;
  const CommentSheet({super.key, required this.vibeId});

  static void show(BuildContext context, String vibeId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Crucial for keyboard handling
      backgroundColor: Colors.transparent,
      builder: (context) => CommentSheet(vibeId: vibeId),
    );
  }

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode(); // Added for auto-focus
  final User? currentUser = FirebaseAuth.instance.currentUser;
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    // Auto focus keyboard when sheet opens
    Future.delayed(const Duration(milliseconds: 300), () => _focusNode.requestFocus());
  }

  Future<void> _postComment() async {
    if (_commentController.text.trim().isEmpty || currentUser == null) return;
    setState(() => _isPosting = true);
    
    try {
      await VibeService().addComment(widget.vibeId, _commentController.text.trim(), currentUser!.displayName ?? 'User', currentUser!.photoURL ?? '');
      _commentController.clear();
      _focusNode.unfocus();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate keyboard height
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 12),
                const Text("Comments", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                const Divider(),
              ],
            ),
          ),

          // Comments List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('vibes').doc(widget.vibeId).collection('comments').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF6B8E23)));
                var docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) return const Center(child: Text("No comments yet. Start the conversation!", style: TextStyle(color: Colors.grey)));

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: data['userProfilePic'] != null && data['userProfilePic'].toString().isNotEmpty ? CachedNetworkImageProvider(data['userProfilePic']) : null,
                            child: data['userProfilePic'] == null ? const Icon(Icons.person, size: 18, color: Colors.grey) : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(data['username'] ?? 'User', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 13)),
                                    const SizedBox(width: 8),
                                    Text(timeago.format((data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now()), style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(data['text'] ?? '', style: const TextStyle(color: Colors.black, fontSize: 14)), // FIX: Text is pure black now
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Input Field
          Container(
            padding: EdgeInsets.only(bottom: bottomInset > 0 ? bottomInset : MediaQuery.of(context).padding.bottom, left: 16, right: 16, top: 12),
            decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade200))),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    focusNode: _focusNode,
                    style: const TextStyle(color: Colors.black), // FIX: Input text is visible
                    decoration: InputDecoration(
                      hintText: "Add a comment...",
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _isPosting 
                  ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6B8E23))))
                  : IconButton(
                      icon: const Icon(Icons.send_rounded, color: Color(0xFF6B8E23)), // Olive Green Send Button
                      onPressed: _postComment,
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}