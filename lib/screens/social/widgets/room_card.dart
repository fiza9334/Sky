import 'package:flutter/material.dart';
import '../../../models/room_model.dart';
// Apna correct path use karein
import '../room_detail_screen.dart';

class RoomCard extends StatelessWidget {
  final RoomModel room;
  const RoomCard({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    // FIX: App crash na ho isliye agar host ki photo nahi hai, toh ek default image dikhayenge
    String imageUrl = room.host.profilePicUrl.isNotEmpty 
        ? room.host.profilePicUrl 
        : 'https://ui-avatars.com/api/?name=${(room.host.name.isEmpty ? "User" : room.host.name).replaceAll(" ", "+")}&background=1B3022&color=fff';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        // FIX 1: room.id ko room.roomId kiya
        MaterialPageRoute(builder: (context) => RoomDetailScreen(roomId: room.id)),
      ),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            // FIX 2: Safe Image URL use kiya (room.roomImage ki jagah)
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(room.roomName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.mic, color: Colors.redAccent, size: 14),
                  const SizedBox(width: 4),
                  // FIX 3: room.onStageCount ko room.speakers kiya
                  Text('${room.onlineCount} Live', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';

// class RoomDetailScreen extends StatelessWidget {
//   final String roomId;

//   const RoomDetailScreen({super.key, required this.roomId});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0C100C), // Aapka dark theme
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF141A14),
//         title: const Text("Room Details", style: TextStyle(color: Colors.white)),
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: Center(
//         child: Text(
//           "Aapka Room ID $roomId yahan khulega!", 
//           style: const TextStyle(color: Color(0xFFA5B880), fontSize: 18)
//         ),
//       ),
//     );
//   }
// }