// import 'package:cloud_firestore/cloud_firestore.dart';

// class Room {
//   final String id;
//   final String roomName;
//   final String roomImage;
//   final String description;
//   final String language;
//   final bool isPrivate;
//   final String leaderId;
//   final List<String> participants;
//   final int onStageCount;

//   Room({
//     required this.id,
//     required this.roomName,
//     required this.roomImage,
//     required this.description,
//     required this.language,
//     required this.isPrivate,
//     required this.leaderId,
//     required this.participants,
//     required this.onStageCount,
//   });

//   factory Room.fromFirestore(DocumentSnapshot doc) {
//     Map data = doc.data() as Map;
//     return Room(
//       id: doc.id,
//       roomName: data['roomName'] ?? '',
//       roomImage: data['roomImage'] ?? '',
//       description: data['description'] ?? '',
//       language: data['language'] ?? 'English',
//       isPrivate: data['isPrivate'] ?? false,
//       leaderId: data['leaderId'] ?? '',
//       participants: List<String>.from(data['participants'] ?? []),
//       onStageCount: data['onStageCount'] ?? 0,
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';

class RoomModel {
  final String id;
  final String roomName;
  final String roomImage;
  final int onStageCount;

  RoomModel({
    required this.id,
    required this.roomName,
    required this.roomImage,
    required this.onStageCount,
  });

  // YEH WALA PART ZAROORI HAI: factory constructor
  factory RoomModel.fromFirestore(DocumentSnapshot doc) {
    // Check karein ki data null toh nahi hai
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return RoomModel(
      id: doc.id,
      roomName: data['roomName'] ?? 'No Name',
      roomImage: data['roomImage'] ?? 'https://via.placeholder.com/150',
      onStageCount: data['onStageCount'] ?? 0,
    );
  }
}