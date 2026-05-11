
// import 'package:cloud_firestore/cloud_firestore.dart';

// class RoomModel {
//   final String roomId;
//   final String roomName;
//   final String topic;
//   final String hostId;
//   final String hostName;
//   final String hostProfilePic;
//   final DateTime createdAt;
//   final int listeners;
//   final int speakers;
//   final bool isLive;
//   final String roomType;
//   final List<String> usersInside;

//   RoomModel({
//     required this.roomId,
//     required this.roomName,
//     required this.topic,
//     required this.hostId,
//     required this.hostName,
//     required this.hostProfilePic,
//     required this.createdAt,
//     required this.listeners,
//     required this.speakers,
//     required this.isLive,
//     required this.roomType,
//     required this.usersInside,
//   });

//   factory RoomModel.fromFirestore(DocumentSnapshot doc) {
//     Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
//     return RoomModel(
//       roomId: doc.id,
//       roomName: data['roomName'] ?? 'Untitled Room',
//       topic: data['topic'] ?? 'General',
//       hostId: data['hostId'] ?? '',
//       hostName: data['hostName'] ?? 'Anonymous',
//       hostProfilePic: data['hostProfilePic'] ?? '',
//       // Safe timestamp parsing
//       createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
//       listeners: data['listeners'] ?? 0,
//       speakers: data['speakers'] ?? 1,
//       isLive: data['isLive'] ?? false,
//       roomType: data['roomType'] ?? 'public',
//       usersInside: List<String>.from(data['usersInside'] ?? []),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String profilePicUrl;

  UserModel({required this.uid, required this.name, required this.profilePicUrl});

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? 'User',
      profilePicUrl: map['profilePicUrl'] ?? '',
    );
  }
}

class RoomModel {
  final String id;
  final String roomName;
  final String topic; // E.g., Discussing, Tuning In
  final String backgroundImageUrl; // Created room pic as background
  final UserModel host;
  final int onlineCount;
  final int memberCount; // For vertical cards
  final bool liveNow;
  final List<UserModel> moderators; // For vertical cards
  final DateTime createdAt;

  RoomModel({
    required this.id,
    required this.roomName,
    required this.topic,
    required this.backgroundImageUrl,
    required this.host,
    required this.onlineCount,
    required this.memberCount,
    required this.liveNow,
    required this.moderators,
    required this.createdAt,
  });

  factory RoomModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return RoomModel(
      id: doc.id,
      roomName: data['roomName'] ?? 'No Name Club',
      topic: data['topic'] ?? '',
      backgroundImageUrl: data['backgroundImageUrl'] ?? '',
      host: UserModel.fromMap(data['host'] ?? {}),
      onlineCount: data['listeners'] ?? 1,
      // onlineCount: data['onlineCount'] ?? 1,
      memberCount: data['memberCount'] ?? 1,
      // liveNow: data['liveNow'] ?? false,
      liveNow: data['isLive'] ?? false,
      moderators: (data['moderators'] as List? ?? [])
          .map((m) => UserModel.fromMap(m))
          .toList(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}