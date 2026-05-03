import 'package:flutter/material.dart';
import 'chat_screen.dart'; 
import 'inbox.dart';
class MessageTab extends StatelessWidget {
  const MessageTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Messages',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: isDark ? Colors.white : Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_horiz, color: isDark ? Colors.white : Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- MINIMAL STATUS SECTION ---
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const MyStatusWidget(),
                FriendStatusWidget(
                  name: 'Rahul', 
                  imageUrl: 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?auto=format&fit=crop&w=150&q=80',
                  isActive: true,
                ),
                FriendStatusWidget(
                  name: 'Aisha', 
                  imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150&q=80',
                  isActive: false,
                ),
              ],
            ),
          ),
          
          Divider(
            thickness: 0.3, 
            color: isDark ? Colors.grey[800] : Colors.grey[300],
            height: 1,
          ),

          // --- MINIMAL CHAT LIST ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              physics: const BouncingScrollPhysics(),
              children: [
                // 1. Echoo AI (Pinned)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: primaryColor.withOpacity(0.5), width: 1.5),
                        ),
                        child: CircleAvatar(
                          radius: 26,
                          backgroundColor: primaryColor.withOpacity(0.1),
                          child: Icon(Icons.smart_toy_rounded, color: primaryColor, size: 28),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).scaffoldBackgroundColor, 
                              width: 2,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  title: Text(
                    'Echoo AI',
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    'Ready to chat!',
                    style: TextStyle(color: primaryColor, fontWeight: FontWeight.w500),
                  ),
                  trailing: Text(
                    'Bot', 
                    style: TextStyle(color: primaryColor.withOpacity(0.6), fontSize: 12),
                  ),
                  onTap: () {},
                ),

                // 2. Real User Example
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  leading: const CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&q=80'),
                  ),
                  title: Text(
                    'Fizam',
                    
                    style: TextStyle(
                      fontWeight: FontWeight.w600, 
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    'Bhai room kab create kar rahe ho?',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w500, // Slightly bold for unread
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '10:45 AM', 
                        style: TextStyle(
                          color: primaryColor, 
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          '1',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const ChatScreen(
        currentUserId: 'my_user_id_123', // Aapki ID
        receiverId: 'fizam_id_456', // Samne wale ki ID
        receiverName: 'Fizam', // Samne wale ka naam
        receiverAvatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&q=80', 
      ),
    ),
  );
},
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: primaryColor,
        child: const Icon(Icons.message_rounded, color: Colors.white),
      ),
    );
  }
}

// --- My Status Widget ---
class MyStatusWidget extends StatelessWidget {
  const MyStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(right: 16.0, top: 12.0),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[300]!, width: 2),
                ),
                child: const CircleAvatar(
                  radius: 26,
                  backgroundImage: NetworkImage('https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?auto=format&fit=crop&w=150&q=80'), 
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  height: 22,
                  width: 22,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'My Status',
            style: TextStyle(
              fontSize: 12, 
              color: isDark ? Colors.grey[400] : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Friend Status Widget ---
class FriendStatusWidget extends StatelessWidget {
  final String name;
  final String imageUrl;
  final bool isActive;

  const FriendStatusWidget({
    super.key, 
    required this.name, 
    required this.imageUrl,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(right: 16.0, top: 12.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? primaryColor : (isDark ? Colors.grey[800]! : Colors.grey[300]!), 
                width: 2.5,
              ), 
            ),
            child: CircleAvatar(
              radius: 26,
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
              backgroundImage: NetworkImage(imageUrl),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: TextStyle(
              fontSize: 12, 
              color: isDark ? Colors.grey[300] : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}