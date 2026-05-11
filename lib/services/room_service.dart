import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/room_model.dart';

class RoomService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // 1. Create Room & Auto-Join
  Future<String?> createRoom(String roomName, String topic, String roomType) async {
    if (currentUserId == null) return null;
    final user = _auth.currentUser!;

    DocumentReference roomRef = _db.collection('rooms').doc();
    
    await roomRef.set({
      'roomId': roomRef.id,
      'roomName': roomName.trim(),
      'topic': topic.trim(),
      'hostId': currentUserId,
      'hostName': user.displayName ?? 'Host',
      'hostProfilePic': user.photoURL ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'listeners': 0,
      'speakers': 1, // Host is a speaker
      'isLive': true,
      'roomType': roomType,
      'usersInside': [currentUserId], // Host auto-joins
    });

    return roomRef.id;
  }

  // 2. Join Room (Atomic increment & array union)
  Future<void> joinRoom(String roomId) async {
    if (currentUserId == null) return;
    await _db.collection('rooms').doc(roomId).update({
      'usersInside': FieldValue.arrayUnion([currentUserId]),
      'listeners': FieldValue.increment(1),
    });
  }

  // 3. Leave Room (Atomic decrement & array remove)
  Future<void> leaveRoom(String roomId) async {
    if (currentUserId == null) return;
    await _db.collection('rooms').doc(roomId).update({
      'usersInside': FieldValue.arrayRemove([currentUserId]),
      'listeners': FieldValue.increment(-1),
    });
  }

  // 4. End Room (Host Only)
  Future<void> endRoom(String roomId) async {
    await _db.collection('rooms').doc(roomId).update({
      'isLive': false,
      'usersInside': [],
    });
  }

  // 5. Get Popular Live Rooms Stream
  Stream<List<RoomModel>> getLiveRoomsStream() {
    return _db.collection('rooms')
        .where('isLive', isEqualTo: true)
        .orderBy('listeners', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => RoomModel.fromFirestore(doc)).toList());
  }

  // 6. Get Specific Room Stream
  Stream<RoomModel> getRoomStream(String roomId) {
    return _db.collection('rooms').doc(roomId).snapshots().map((doc) => RoomModel.fromFirestore(doc));
  }
}