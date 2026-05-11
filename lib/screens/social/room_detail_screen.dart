// import 'package:flutter/material.dart';

// class RoomDetailScreen extends StatelessWidget {
//   final String roomId;
//   const RoomDetailScreen({super.key, required this.roomId});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
//       body: Column(
//         children: [
//           const Text("On Stage", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 10),
//           // Horizontal Avatars Placeholder
//           SizedBox(
//             height: 100,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               itemCount: 4,
//               itemBuilder: (context, index) => const Padding(
//                 padding: EdgeInsets.all(8.0),
//                 child: CircleAvatar(radius: 35, child: Icon(Icons.person)),
//               ),
//             ),
//           ),
//           const Divider(color: Colors.white10),
//           const ListTile(
//             title: Text("Listeners", style: TextStyle(color: Colors.white70)),
//             trailing: Icon(Icons.mic_off, color: Colors.white),
//           ),
//           const Spacer(),
//           // Basic Chat Input Placeholder
//           Container(
//             padding: const EdgeInsets.all(16),
//             color: Colors.white.withOpacity(0.05),
//             child: Row(
//               children: [
//                 const Expanded(child: TextField(decoration: InputDecoration(hintText: "Say something..."))),
//                 IconButton(icon: const Icon(Icons.send), onPressed: () {}),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }




import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/room_service.dart';
import '../../models/room_model.dart';

class RoomDetailScreen extends StatefulWidget {
  final String roomId;
  const RoomDetailScreen({super.key, required this.roomId});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  final RoomService _roomService = RoomService();

  @override
  void initState() {
    super.initState();
    _joinRoomLogic();
  }

  Future<void> _joinRoomLogic() async {
    // Prevent host from incrementing listener count if they just created it
    final snapshot = await FirebaseFirestore.instance.collection('rooms').doc(widget.roomId).get();
    if (snapshot.data()?['hostId'] != _roomService.currentUserId) {
      await _roomService.joinRoom(widget.roomId);
    }
  }

  Future<void> _handleLeaveOrEnd(RoomModel room) async {
    if (room.id == _roomService.currentUserId) {
      await _roomService.endRoom(widget.roomId);
    } else {
      await _roomService.leaveRoom(widget.roomId);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<RoomModel>(
      stream: _roomService.getRoomStream(widget.roomId),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Scaffold(body: Center(child: Text("Error: ${snapshot.error}")));
        if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));

        final room = snapshot.data!;

        // FIX: Auto-kick listeners if the host ends the room
       if (!room.liveNow) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.popUntil(context, (route) => route.isFirst);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Room has ended.")));
            }
          });
          return const Scaffold(body: Center(child: Text("Room Ended")));
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(room.roomName),
            actions: [
              TextButton(
                onPressed: () => _handleLeaveOrEnd(room),
                // FIX 2: hostId ko host.uid kiya
                child: Text(room.host.uid == _roomService.currentUserId ? "End Room" : "Leave Quietly", style: const TextStyle(color: Colors.red)),
              )
            ],
          ),
          body: Column(
            children: [
              Text("Topic: ${room.topic}"),
              // FIX 3: listeners ko onlineCount kiya
              Text("Online: ${room.onlineCount}"),
              // INSERT YOUR EXISTING ROOM UI GRID/AVATARS HERE.
            ],
          ),
        );
      },
    );
  }
}