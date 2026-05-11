import 'package:flutter/material.dart';
import '../../../models/room_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RoomCardVertical extends StatelessWidget {
  final RoomModel room;
  const RoomCardVertical({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Fallback
        borderRadius: BorderRadius.circular(20),
        // Solution: Picked profile pic used as a darkened background image
        image: room.backgroundImageUrl.isNotEmpty
            ? DecorationImage(
                image: CachedNetworkImageProvider(room.backgroundImageUrl),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.8), BlendMode.dstATop), // Darker overlay
              )
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: CachedNetworkImageProvider(room.host.profilePicUrl),
          backgroundColor: Colors.grey[800],
        ),
        title: Text(room.roomName, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              "${room.memberCount} Members Joined", // Green count
              style: TextStyle(color: Color(0xFF6B8D1B), fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 4),
            // Wakie detail style
            Text(
              "Moderators • ${room.moderators.take(2).map((m) => m.name).join(', ')}...",
              style: TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 16),
        onTap: () {
          // Navigate into the voice room
        },
      ),
    );
  }
}