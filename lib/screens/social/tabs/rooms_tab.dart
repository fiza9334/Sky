// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../widgets/room_card.dart';
// import '../create_room_screen.dart';
// import '../../../models/room_model.dart';

// class RoomsTab extends StatelessWidget {
//   const RoomsTab({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent, // Keeps Dashboard background
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Padding(
//               padding: EdgeInsets.all(16.0),
//               child: Text("On Stage Now 🔥", 
//                 style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
//             ),
            
//             // 1A. Horizontal List of Active Rooms (onStageCount >= 5)
//             SizedBox(
//               height: 180,
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: FirebaseFirestore.instance
//                     .collection('rooms')
//                     .where('onStageCount', isGreaterThanOrEqualTo: 5)
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox();
//                   if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                     return const Center(child: Text("No live stages", style: TextStyle(color: Colors.white38)));
//                   }
//                   return ListView.builder(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     scrollDirection: Axis.horizontal,
//                     itemCount: snapshot.data!.docs.length,
//                     itemBuilder: (context, index) => RoomCard(
//                       room: RoomModel.fromFirestore(snapshot.data!.docs[index]),
//                     ),
//                   );
//                 },
//               ),
//             ),

//             // 1B. Popular/My Rooms Section
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//               child: Row(
//                 children: [
//                   const Text("Popular Rooms", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//                   const SizedBox(width: 20),
//                   const Text("My Rooms", style: TextStyle(color: Colors.white38)),
//                   const Spacer(),
//                   IconButton(
//                     icon: const Icon(Icons.more_vert, color: Colors.white70),
//                     onPressed: () => _showCreateOption(context),
//                   )
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showCreateOption(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: const Color(0xFF1A1A1A),
//       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
//       builder: (context) => ListTile(
//         leading: const Icon(Icons.add_circle_outline, color: Colors.blueAccent),
//         title: const Text("Create New Room", style: TextStyle(color: Colors.white)),
//         onTap: () {
//           Navigator.pop(context);
//           Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateRoomScreen()));
//         },
//       ),
//     );
//   }
// }





// import 'package:flutter/material.dart';
// import '../../../services/room_service.dart';
// import '../../../models/room_model.dart';
// import '../create_room_screen.dart'; // Ensure correct path
// import '../room_detail_screen.dart'; // Ensure correct path

// class RoomsTab extends StatelessWidget {
//   const RoomsTab({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent, // Maintains your current theme
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateRoomScreen())),
//         child: const Icon(Icons.add),
//       ),
//       body: StreamBuilder<List<RoomModel>>(
//         stream: RoomService().getLiveRoomsStream(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text("Error: ${snapshot.error}"));
//           }
          
//           final rooms = snapshot.data ?? [];
          
//           if (rooms.isEmpty) {
//             return const Center(child: Text("No active rooms. Start one!"));
//           }

//           return ListView.builder(
//             itemCount: rooms.length,
//             itemBuilder: (context, index) {
//               final room = rooms[index];
//               // KEEP YOUR EXISTING UI CARD HERE. Just pass the 'room' data to it.
//               return ListTile(
//                 title: Text(room.roomName),
//                 subtitle: Text("Host: ${room.hostName} • Listeners: ${room.listeners}"),
//                 onTap: () {
//                   Navigator.push(context, MaterialPageRoute(
//                     builder: (_) => RoomDetailScreen(roomId: room.roomId),
//                   ));
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }





import 'package:flutter/material.dart';
import '../../../services/room_service.dart';
import '../../../models/room_model.dart';
import '../create_room_screen.dart';
import '../widgets/live_room_card.dart';
import '../widgets/room_list_card.dart';

class RoomsTab extends StatefulWidget {
  const RoomsTab({super.key});

  @override
  State<RoomsTab> createState() => _RoomsTabState();
}

class _RoomsTabState extends State<RoomsTab> {
  int _selectedTabIndex = 1; // 0 = My Room, 1 = Popular

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Deep Dark Background
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF6B8E23), // Olive Accent
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateRoomScreen())),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text("Create Room", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<List<RoomModel>>(
        stream: RoomService().getLiveRoomsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF6B8E23)));
          
          final rooms = snapshot.data ?? [];
          
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ON STAGE NOW Section
              if (rooms.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                    child: Row(
                      children: [
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        const Text("ON STAGE NOW", style: TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 190,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: rooms.length,
                      itemBuilder: (context, index) => LiveRoomCard(room: rooms[index]),
                    ),
                  ),
                ),
              ],

              // FILTER TABS
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
                  child: Row(
                    children: [
                      _buildFilterTab("My Room", 0),
                      const SizedBox(width: 16),
                      _buildFilterTab("Popular", 1),
                    ],
                  ),
                ),
              ),

              // ROOM LIST
              rooms.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Text("No rooms available right now.\nBe the first to start one!", textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.5))),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => RoomListCard(room: rooms[index]),
                          childCount: rooms.length,
                        ),
                      ),
                    ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)), // FAB padding
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterTab(String title, int index) {
    bool isActive = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
              fontSize: 18,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 3,
            width: isActive ? 30 : 0,
            decoration: BoxDecoration(
              color: const Color(0xFF6B8E23), // Olive underline
              borderRadius: BorderRadius.circular(2),
            ),
          )
        ],
      ),
    );
  }
}