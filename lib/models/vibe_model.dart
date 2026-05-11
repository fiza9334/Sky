/*import 'package:cloud_firestore/cloud_firestore.dart';

class VibeModel {
  final String id;
  final String userId;
  final String username;
  final String userProfilePic;
  final String type;
  final String content;
  final String imageUrl;
  final DateTime timestamp;
  final int likesCount;
  final int commentsCount;

  VibeModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.userProfilePic,
    required this.type,
    required this.content,
    required this.imageUrl,
    required this.timestamp,
    required this.likesCount,
    required this.commentsCount,
  });

  factory VibeModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
    
    // Fix: Handle Firestore serverTimestamp nullability during local sync
    DateTime parsedTime = DateTime.now();
    if (data['timestamp'] != null && data['timestamp'] is Timestamp) {
      parsedTime = (data['timestamp'] as Timestamp).toDate();
    }

    return VibeModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? 'Anonymous',
      userProfilePic: data['userProfilePic'] ?? '',
      type: data['type'] ?? 'text',
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      timestamp: parsedTime,
      likesCount: data['likesCount'] ?? 0,
      commentsCount: data['commentsCount'] ?? 0,
    );
  }
}
*/


import 'package:cloud_firestore/cloud_firestore.dart';

class VibeModel {
  final String id;
  final String userId;
  final String username;
  final String userProfilePic;
  final String type;
  final String content;
  final String imageUrl;
  final DateTime timestamp;
  final int likesCount;
  final int commentsCount;
  final List<String> likedBy; // Added for real like system

  VibeModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.userProfilePic,
    required this.type,
    required this.content,
    required this.imageUrl,
    required this.timestamp,
    required this.likesCount,
    required this.commentsCount,
    required this.likedBy,
  });

  factory VibeModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
    
    return VibeModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? 'Anonymous',
      userProfilePic: data['userProfilePic'] ?? '',
      type: data['type'] ?? 'text',
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(), // Fixes timestamp null crash
      likesCount: data['likesCount'] ?? 0,
      commentsCount: data['commentsCount'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
    );
  }
}