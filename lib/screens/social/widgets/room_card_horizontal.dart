import 'package:flutter/material.dart';
import '../../../models/room_model.dart';

import 'package:cached_network_image/cached_network_image.dart';

class RoomCardHorizontal extends StatelessWidget {
  final RoomModel room;
  const RoomCardHorizontal({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    const Color haloColorBitcoin = Color(0xFFEDAC4D);
    const Color haloColorMic = Color(0xFFD3A365); // More subtle gold

    // Logic to select halo and specific icon based on dummy titles in prompt image
    final bool isCrypto = room.roomName.toLowerCase().contains("crypto");
    final Color haloColor = isCrypto ? haloColorBitcoin : haloColorMic;
    final String centralIconPath = isCrypto ? 'assets/icons/bitcoin_flat.png' : 'assets/icons/microphone_gold.png'; // Replace with real flat icons

    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Fallback color
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 5),
          )
        ],
        // Solution: Picked profile pic used as a darkened background image
        image: room.backgroundImageUrl.isNotEmpty
            ? DecorationImage(
                image: CachedNetworkImageProvider(room.backgroundImageUrl),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.dstATop), // Darkened image
              )
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Floating halo effect around icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: haloColor.withOpacity(0.5), width: 2),
                boxShadow: [
                  BoxShadow(color: haloColor.withOpacity(0.3), blurRadius: 30, spreadRadius: 3)
                ]
              ),
              child: (isCrypto) 
                  ? Icon(Icons.currency_bitcoin, color: Colors.orange, size: 50) // Fallback icon
                  : Icon(Icons.mic, color: Colors.white70, size: 50), // Use your flat asset image instead
            ),
            const SizedBox(height: 20),
            
            // LIVE NOW 🔥 Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: const Color(0xFF1E8D1E), borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "LIVE NOW",
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(width: 4),
                  Text("🔥", style: TextStyle(fontSize: 10)),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            Text(room.roomName, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 4),
            // Replaced generic dummy text with stylized count
            Text(
              "${room.onlineCount} Online Discussing",
              style: TextStyle(color: Color(0xFFA5D6A7), fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}