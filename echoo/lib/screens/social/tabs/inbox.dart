import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'chat_screen.dart';

// --- DATA MODELS ---

class StatusModel {
  final String id;
  final String userId;
  final String username;
  final String avatarUrl;
  final String mediaUrl;
  final String type; 
  final DateTime timestamp;
  final List<String> viewedBy;

  StatusModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.avatarUrl,
    required this.mediaUrl,
    required this.type,
    required this.timestamp,
    required this.viewedBy,
  });
}

class ChatModel {
  final String chatId;
  final List<String> participants;
  final String otherUserName;
  final String otherUserAvatar;
  final String lastMessage;
  final DateTime lastUpdated;
  int unreadCount; // Changed from final to allow marking as read

  ChatModel({
    required this.chatId,
    required this.participants,
    required this.otherUserName,
    required this.otherUserAvatar,
    required this.lastMessage,
    required this.lastUpdated,
    required this.unreadCount,
  });
}

// --- DUMMY DATA ---

const String currentUserId = 'user_1';

final List<StatusModel> dummyStatuses = [
  StatusModel(
    id: 's1',
    userId: 'user_2',
    username: 'Aisha',
    avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150&q=80',
    mediaUrl: 'https://images.unsplash.com/photo-1516483638261-f40af5eba324?auto=format&fit=crop&w=600&q=80',
    type: 'image',
    timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    viewedBy: [],
  ),
  StatusModel(
    id: 's2',
    userId: 'user_3',
    username: 'Rahul',
    avatarUrl: 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?auto=format&fit=crop&w=150&q=80',
    mediaUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4', 
    type: 'video',
    timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
    viewedBy: [currentUserId],
  ),
];

final List<ChatModel> dummyChats = [
  ChatModel(
    chatId: 'c1',
    participants: ['user_1', 'user_2'],
    otherUserName: 'Aisha',
    otherUserAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150&q=80',
    lastMessage: 'Are we still on for the meeting?',
    lastUpdated: DateTime.now().subtract(const Duration(minutes: 2)),
    unreadCount: 2,
  ),
  ChatModel(
    chatId: 'c2',
    participants: ['user_1', 'user_3'],
    otherUserName: 'Rahul',
    otherUserAvatar: 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?auto=format&fit=crop&w=150&q=80',
    lastMessage: 'Check out this video',
    lastUpdated: DateTime.now().subtract(const Duration(hours: 1)),
    unreadCount: 0,
  ),
];

// --- MAIN INBOX SCREEN ---

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final ImagePicker _picker = ImagePicker();
  
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<ChatModel> _filteredChats = [];

  @override
  void initState() {
    super.initState();
    _filteredChats = dummyChats;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterChats(String query) {
    setState(() {
      _filteredChats = dummyChats
          .where((chat) => chat.otherUserName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var chat in dummyChats) {
        chat.unreadCount = 0;
      }
      // Re-apply filter to update UI smoothly
      _filterChats(_searchController.text);
    });
  }

  Future<void> _pickStatusMedia() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      _uploadStatus(image.path, 'image');
                    }
                  } catch (e) {
                    debugPrint("Image Picker Error: $e");
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Video (Max 15s)'),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    final XFile? video = await _picker.pickVideo(
                      source: ImageSource.gallery,
                      maxDuration: const Duration(seconds: 15),
                    );
                    if (video != null) {
                      _uploadStatus(video.path, 'video');
                    }
                  } catch (e) {
                    debugPrint("Video Picker Error: $e");
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _uploadStatus(String path, String type) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Selected $type: $path')),
    );
  }

  void _openStatusViewer(StatusModel status) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatusViewerScreen(status: status),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Search for username...',
                  hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  border: InputBorder.none,
                ),
                onChanged: _filterChats,
              )
            : Text(
                'Messages',
                style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
              ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!_isSearching) 
            IconButton(
              icon: Icon(Icons.camera_alt_outlined, color: isDark ? Colors.white : Colors.black87), 
              onPressed: _pickStatusMedia,
            ),
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: isDark ? Colors.white : Colors.black87),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  _filterChats('');
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: isDark ? Colors.white : Colors.black87),
            onSelected: (value) {
              if (value == 'mark_read') {
                _markAllAsRead();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'mark_read',
                child: Text('Mark all as read'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // --- STATUS SECTION ---
          if (!_isSearching) ...[
            SizedBox(
              height: 105,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: dummyStatuses.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return GestureDetector(
                      onTap: _pickStatusMedia,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                const CircleAvatar(
                                  radius: 28,
                                  backgroundImage: NetworkImage('https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?auto=format&fit=crop&w=150&q=80'),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                                    ),
                                    child: const Icon(Icons.add, size: 18, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text('My Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black87)),
                          ],
                        ),
                      ),
                    );
                  }

                  final status = dummyStatuses[index - 1];
                  final isViewed = status.viewedBy.contains(currentUserId);

                  return GestureDetector(
                    onTap: () => _openStatusViewer(status),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isViewed ? Colors.grey : primaryColor,
                                width: 2.5,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 26,
                              backgroundImage: NetworkImage(status.avatarUrl),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            status.username,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isViewed ? FontWeight.normal : FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Divider(height: 1, thickness: 0.5, color: isDark ? Colors.grey[800] : Colors.grey[300]),
          ],

          // --- CHAT LIST ---
          Expanded(
            child: _filteredChats.isEmpty
                ? Center(
                    child: Text(
                      'No chats found',
                      style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredChats.length,
                    itemBuilder: (context, index) {
                      final chat = _filteredChats[index];
                      final hasUnread = chat.unreadCount > 0;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          radius: 28,
                          backgroundImage: NetworkImage(chat.otherUserAvatar),
                        ),
                        title: Text(
                          chat.otherUserName,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black87),
                        ),
                        subtitle: Text(
                          chat.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: hasUnread ? (isDark ? Colors.white : Colors.black87) : Colors.grey,
                            fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatTime(chat.lastUpdated),
                              style: TextStyle(
                                color: hasUnread ? primaryColor : Colors.grey,
                                fontSize: 12,
                                fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (hasUnread)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  chat.unreadCount.toString(),
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                currentUserId: currentUserId,
                                receiverId: chat.participants.firstWhere((id) => id != currentUserId, orElse: () => 'unknown'),
                                receiverName: chat.otherUserName,
                                receiverAvatarUrl: chat.otherUserAvatar,
                              ),
                            ),
                          ).then((_) {
                            // Clear unread count when returning from chat
                            setState(() {
                              chat.unreadCount = 0;
                            });
                          });
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: primaryColor,
        child: const Icon(Icons.chat_bubble, color: Colors.white),
      ),
    );
  }
}

// --- STATUS VIEWER SCREEN ---

class StatusViewerScreen extends StatefulWidget {
  final StatusModel status;

  const StatusViewerScreen({super.key, required this.status});

  @override
  State<StatusViewerScreen> createState() => _StatusViewerScreenState();
}

class _StatusViewerScreenState extends State<StatusViewerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  VideoPlayerController? _videoController;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), 
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _closeViewer();
        }
      });

    _initializeMedia();
  }

  void _initializeMedia() {
    if (widget.status.type == 'video') {
      try {
        _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.status.mediaUrl))
          ..initialize().then((_) {
            if (mounted) {
              setState(() {
                _progressController.duration = _videoController!.value.duration;
                _videoController!.play();
                _progressController.forward();
              });
            }
          }).catchError((_) {
            // ignore: deprecated_member_use
            _videoController = VideoPlayerController.network(widget.status.mediaUrl)
              ..initialize().then((_) {
                if (mounted) {
                  setState(() {
                    _progressController.duration = _videoController!.value.duration;
                    _videoController!.play();
                    _progressController.forward();
                  });
                }
              });
          });
      } catch (e) {
        debugPrint('Video Player Init Error: $e');
      }
    } else {
      _progressController.forward();
    }
  }

  void _closeViewer() {
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _pausePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _progressController.forward();
        _videoController?.play();
      } else {
        _progressController.stop();
        _videoController?.pause();
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (_) => _pausePlay(),
        onTapUp: (_) => _pausePlay(),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: widget.status.type == 'video'
                    ? (_videoController != null && _videoController!.value.isInitialized
                        ? AspectRatio(
                            aspectRatio: _videoController!.value.aspectRatio,
                            child: VideoPlayer(_videoController!),
                          )
                        : const CircularProgressIndicator(color: Colors.white))
                    : Image.network(widget.status.mediaUrl, fit: BoxFit.contain),
              ),
              
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black54, Colors.transparent],
                    ),
                  ),
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          return LinearProgressIndicator(
                            value: _progressController.value,
                            backgroundColor: Colors.grey.withOpacity(0.5),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            minHeight: 2,
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: _closeViewer,
                          ),
                          CircleAvatar(
                            radius: 18,
                            backgroundImage: NetworkImage(widget.status.avatarUrl),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.status.username,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}