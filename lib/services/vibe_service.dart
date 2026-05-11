import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VibeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  // Toggle Like
  Future<void> toggleLike(String vibeId, bool isCurrentlyLiked) async {
    if (currentUserId == null) return;
    
    DocumentReference vibeRef = _db.collection('vibes').doc(vibeId);

    if (isCurrentlyLiked) {
      await vibeRef.update({
        'likedBy': FieldValue.arrayRemove([currentUserId]),
        'likesCount': FieldValue.increment(-1),
      });
    } else {
      await vibeRef.update({
        'likedBy': FieldValue.arrayUnion([currentUserId]),
        'likesCount': FieldValue.increment(1),
      });
    }
  }

  // Add Comment
  Future<void> addComment(String vibeId, String text, String username, String profilePic) async {
    if (currentUserId == null || text.trim().isEmpty) return;

    await _db.collection('vibes').doc(vibeId).collection('comments').add({
      'userId': currentUserId,
      'username': username,
      'userProfilePic': profilePic,
      'text': text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    await _db.collection('vibes').doc(vibeId).update({
      'commentsCount': FieldValue.increment(1),
    });
  }
}