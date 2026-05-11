import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/room_model.dart';
import '../room_detail_screen.dart';

class RoomListCard extends StatelessWidget {
  final RoomModel room;
  const RoomListCard({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    String imageUrl = room.host.profilePicUrl.isNotEmpty 
        ? room.host.profilePicUrl
        :'https://ui-avatars.com/api/?name=${(room.host.name.isEmpty ? "User" : room.host.name).replaceAll(" ", "+")}&background=1B3022&color=fff';

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RoomDetailScreen(roomId: room.id))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: CachedNetworkImageProvider(imageUrl),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.roomName,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                 Text(
                    // FIX 1: listeners + speakers ko hata kar sirf memberCount kar diya
                    "${room.memberCount} Members Joined",
                    style: const TextStyle(color: Color(0xFF6B8E23), fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    // FIX 2 & 3: hostName ko host.name kiya, aur listeners ko onlineCount kiya
                    "Host: ${room.host.name} • Online: ${room.onlineCount}",
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }
}