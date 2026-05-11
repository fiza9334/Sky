import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MuteService {
  static Future<void> muteUser(String targetUserId) async {
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null || targetUserId.isEmpty) return;

    await FirebaseFirestore.instance.collection('users').doc(currentUserId).set({
      'mutedUsers': FieldValue.arrayUnion([targetUserId])
    }, SetOptions(merge: true)); // Merge ensures we don't overwrite other data
  }
}