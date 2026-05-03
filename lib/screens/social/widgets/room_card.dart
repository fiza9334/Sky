import 'package:flutter/material.dart';
import '../../../models/room_model.dart';
import '../room_detail_screen.dart';
// Path apne hisaab se adjust kar lijiye
import '../room_detail_screen.dart';

class RoomCard extends StatelessWidget {
  final RoomModel room;
  const RoomCard({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RoomDetailScreen(roomId: room.id)),
      ),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: NetworkImage(room.roomImage),
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
                  Text('${room.onStageCount} Live', style: const TextStyle(color: Colors.white70, fontSize: 12)),
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