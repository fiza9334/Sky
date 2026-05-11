import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echoo/models/room_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:sky_app/lib/models/room_model.dart'; // Change path as per project

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // Query for 'ON STAGE NOW' (Live, sorted by count) - Requires Index
  // Stream<List<RoomModel>> getLiveOnStageRooms() {
  //   return _firestore
  //       .collection('rooms')
  //       .where('liveNow', isEqualTo: true)
  //       .orderBy('onlineCount', descending: true)
  //       .snapshots()
  //       .map((snapshot) => snapshot.docs
  //           .map((doc) => RoomModel.fromFirestore(doc))
  //           .toList());
  // }
  // Query for 'ON STAGE NOW' (Live, sorted by count) - Uses your existing index!
  Stream<List<RoomModel>> getLiveOnStageRooms() {
    return _firestore
        .collection('rooms')
        .where('isLive', isEqualTo: true) // 'liveNow' ko wapas 'isLive' kar diya
        .orderBy('listeners', descending: true) // 'onlineCount' ko wapas 'listeners' kar diya
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RoomModel.fromFirestore(doc))
            .toList());
  }

  // Query for 'Popular' Clubs (Live or not, ordered by member count)
  Stream<List<RoomModel>> getPopularClubs() {
    return _firestore
        .collection('rooms')
        .orderBy('memberCount', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RoomModel.fromFirestore(doc))
            .toList());
  }

  // Handle room creation - This ensures a room shows only when created
  Future<void> createClub({
    required String roomName,
    required String topic,
    required String backgroundImageUrl,
  }) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(currentUser.uid).get();
    UserModel host =UserModel.fromMap(userDoc.data() as Map<String, dynamic>);

    await _firestore.collection('rooms').add({
      'roomName': roomName,
      'topic': topic,
      'backgroundImageUrl': backgroundImageUrl, // Profile image picked during creation
      'host': {
        'uid': host.uid,
        'name': host.name,
        'profilePicUrl': host.profilePicUrl,
      },
      'onlineCount': 1,
      'memberCount': 1, // Start with 1
      'liveNow': true, // Auto-set live on creation for Wakie feel
      'moderators': [{
        'uid': host.uid,
        'name': host.name,
        'profilePicUrl': host.profilePicUrl,
      }],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}