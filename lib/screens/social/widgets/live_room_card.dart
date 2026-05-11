import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/room_model.dart';
import '../room_detail_screen.dart';

class LiveRoomCard extends StatelessWidget {
  final RoomModel room;
  const LiveRoomCard({super.key, required this.room});

  @override
  Widget build(BuildContext context) {

    String imageUrl = (room.host.profilePicUrl.isNotEmpty)
        ? room.host.profilePicUrl
        : 'https://ui-avatars.com/api/?name=${(room.host.name.isEmpty ? "User" : room.host.name).replaceAll(" ", "+")}&background=1B3022&color=fff';
    // String imageUrl = room.hostProfilePic.isNotEmpty 
    //     ? room.hostProfilePic 
    //     : 'https://ui-avatars.com/api/?name=${room.hostName.replaceAll(" ", "+")}&background=1B3022&color=fff';

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RoomDetailScreen(roomId: room.id))),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.redAccent, width: 2), // Red LIVE accent
                  ),
                  child: CircleAvatar(
                    radius: 35,
                    backgroundImage: CachedNetworkImageProvider(imageUrl),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(10)),
                  child: const Text("LIVE", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                room.roomName,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "${room.memberCount} Joined",
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}