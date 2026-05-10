import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppColors {
  static const Color darkJungle = Color(0xFF1A2421);
  static const Color softGlowingOlive = Color(0xFF8A9A5B);
  static const Color mutedGold = Color(0xFFC5A059);
  static const Color backgroundLight = Color(0xFFF5F6F2);
  static const Color messageBubbleOther = Color(0xFFE8EAE3);
}

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String receiverId;
  final String receiverName;
  final String receiverAvatarUrl;

  const ChatScreen({
    super.key,
    required this.currentUserId,
    required this.receiverId,
    required this.receiverName,
    required this.receiverAvatarUrl,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late String chatRoomId;

  @override
  void initState() {
    super.initState();
    chatRoomId = _getChatRoomId(widget.currentUserId, widget.receiverId);
    _markMessagesAsSeen();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _getChatRoomId(String user1, String user2) {
    if (user1.compareTo(user2) > 0) {
      return '${user1}_$user2';
    } else {
      return '${user2}_$user1';
    }
  }

  void _markMessagesAsSeen() {
    FirebaseFirestore.instance
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .where('receiverId', isEqualTo: widget.currentUserId)
        .where('status', isNotEqualTo: 'seen')
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.update({'status': 'seen'});
      }
    });
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    try {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .add({
        'senderId': widget.currentUserId,
        'receiverId': widget.receiverId,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'sent',
      });

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      debugPrint("Error sending message: $e");
    }
  }

  void _startVoiceCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling ${widget.receiverName}...'),
        backgroundColor: AppColors.softGlowingOlive,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _toggleBlockStatus(bool isCurrentlyBlocked) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(widget.currentUserId);
    
    if (isCurrentlyBlocked) {
      await userRef.update({
        'blockedUsers': FieldValue.arrayRemove([widget.receiverId])
      });
    } else {
      await userRef.set({
        'blockedUsers': FieldValue.arrayUnion([widget.receiverId])
      }, SetOptions(merge: true));
    }
  }

  Future<void> _clearChat() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundLight,
        title: const Text('Clear Chat', style: TextStyle(color: AppColors.darkJungle)),
        content: const Text('Are you sure you want to clear all messages? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final messages = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (var doc in messages.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  Future<void> _deleteChat() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundLight,
        title: const Text('Delete Chat', style: TextStyle(color: AppColors.darkJungle)),
        content: const Text('Are you sure you want to delete this chat completely?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final messages = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (var doc in messages.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(FirebaseFirestore.instance.collection('chats').doc(chatRoomId));
      await batch.commit();

      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _reportUser() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundLight,
        title: const Text('Report User', style: TextStyle(color: AppColors.darkJungle)),
        content: Text('Are you sure you want to report ${widget.receiverName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Report', style: TextStyle(color: AppColors.mutedGold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('reports').add({
        'reporterId': widget.currentUserId,
        'reportedUserId': widget.receiverId,
        'timestamp': FieldValue.serverTimestamp(),
        'reason': 'User reported via chat menu',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report submitted successfully.'),
            backgroundColor: AppColors.darkJungle,
          ),
        );
      }
    }
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(userId: widget.receiverId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(widget.currentUserId).snapshots(),
      builder: (context, userSnapshot) {
        bool isBlocked = false;
        if (userSnapshot.hasData && userSnapshot.data!.exists) {
          final data = userSnapshot.data!.data() as Map<String, dynamic>?;
          if (data != null && data.containsKey('blockedUsers')) {
            List<dynamic> blockedUsers = data['blockedUsers'];
            isBlocked = blockedUsers.contains(widget.receiverId);
          }
        }

        return Scaffold(
          backgroundColor: isDark ? AppColors.darkJungle : AppColors.backgroundLight,
          appBar: AppBar(
            backgroundColor: isDark ? Colors.black87 : Colors.white,
            elevation: 0.5,
            leadingWidth: 40,
            title: GestureDetector(
              onTap: _navigateToProfile,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(widget.receiverAvatarUrl),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.receiverName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.darkJungle,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.softGlowingOlive,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Online',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.phone, color: AppColors.softGlowingOlive),
                onPressed: _startVoiceCall,
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: isDark ? Colors.white : AppColors.darkJungle),
                onSelected: (value) {
                  switch (value) {
                    case 'block':
                      _toggleBlockStatus(isBlocked);
                      break;
                    case 'clear':
                      _clearChat();
                      break;
                    case 'delete':
                      _deleteChat();
                      break;
                    case 'report':
                      _reportUser();
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    value: 'block',
                    child: Text(isBlocked ? 'Unblock User' : 'Block User'),
                  ),
                  const PopupMenuItem(
                    value: 'clear',
                    child: Text('Clear Chat'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete Chat'),
                  ),
                  const PopupMenuItem(
                    value: 'report',
                    child: Text('Report User'),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('chats')
                      .doc(chatRoomId)
                      .collection('messages')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.softGlowingOlive),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          "Say hi to ${widget.receiverName}!",
                          style: TextStyle(
                            color: isDark ? Colors.grey[500] : Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    final messages = snapshot.data!.docs;

                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final data = messages[index].data() as Map<String, dynamic>;
                        final bool isMe = data['senderId'] == widget.currentUserId;
                        
                        final Timestamp? timestamp = data['timestamp'] as Timestamp?;
                        final timeString = timestamp != null 
                            ? "${timestamp.toDate().hour.toString().padLeft(2, '0')}:${timestamp.toDate().minute.toString().padLeft(2, '0')}"
                            : "Sending...";
                            
                        final String status = data['status'] ?? 'sent';

                        return MessageBubble(
                          text: data['text'] ?? '',
                          time: timeString,
                          isMe: isMe,
                          status: status,
                          isDark: isDark,
                        );
                      },
                    );
                  },
                ),
              ),
              if (isBlocked)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: isDark ? Colors.black54 : Colors.grey[200],
                  child: const Text(
                    'You blocked this user. Unblock to send messages.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
                  ),
                )
              else
                ChatInputArea(
                  controller: _messageController,
                  onSend: _sendMessage,
                  isDark: isDark,
                ),
            ],
          ),
        );
      }
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isMe;
  final String status;
  final bool isDark;

  const MessageBubble({
    super.key,
    required this.text,
    required this.time,
    required this.isMe,
    required this.status,
    required this.isDark,
  });

  Widget _buildStatusIcon() {
    if (!isMe) return const SizedBox.shrink();

    IconData iconData;
    Color iconColor = Colors.white.withOpacity(0.7);

    if (status == 'seen') {
      iconData = Icons.done_all;
      iconColor = AppColors.mutedGold; 
    } else if (status == 'delivered') {
      iconData = Icons.done_all;
    } else {
      iconData = Icons.check;
    }

    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Icon(iconData, size: 14, color: iconColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe 
              ? AppColors.softGlowingOlive 
              : (isDark ? Colors.grey[800] : AppColors.messageBubbleOther),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(4),
            bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: isMe 
                    ? Colors.white 
                    : (isDark ? Colors.white : AppColors.darkJungle),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe 
                        ? Colors.white.withOpacity(0.7) 
                        : (isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ),
                _buildStatusIcon(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ChatInputArea extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isDark;

  const ChatInputArea({
    super.key,
    required this.controller,
    required this.onSend,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: isDark ? Colors.black87 : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.add_circle_outline, 
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: controller,
                maxLines: 4,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(color: isDark ? Colors.white : AppColors.darkJungle),
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: const BoxDecoration(
              color: AppColors.softGlowingOlive,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              onPressed: onSend,
            ),
          ),
        ],
      ),
    );
  }
}

// Dummy Profile Screen for Navigation
class UserProfileScreen extends StatelessWidget {
  final String userId;
  const UserProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Profile")),
      body: Center(child: Text("Profile of User ID: $userId")),
    );
  }
}