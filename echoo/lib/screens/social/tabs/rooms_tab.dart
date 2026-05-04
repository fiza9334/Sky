import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/room_card.dart';
import '../create_room_screen.dart';
import '../../../models/room_model.dart';

class RoomsTab extends StatelessWidget {
  const RoomsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Keeps Dashboard background
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("On Stage Now 🔥", 
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            
            // 1A. Horizontal List of Active Rooms (onStageCount >= 5)
            SizedBox(
              height: 180,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('rooms')
                    .where('onStageCount', isGreaterThanOrEqualTo: 5)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox();
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No live stages", style: TextStyle(color: Colors.white38)));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) => RoomCard(
                      room: RoomModel.fromFirestore(snapshot.data!.docs[index]),
                    ),
                  );
                },
              ),
            ),

            // 1B. Popular/My Rooms Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                children: [
                  const Text("Popular Rooms", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 20),
                  const Text("My Rooms", style: TextStyle(color: Colors.white38)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white70),
                    onPressed: () => _showCreateOption(context),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateOption(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => ListTile(
        leading: const Icon(Icons.add_circle_outline, color: Colors.blueAccent),
        title: const Text("Create New Room", style: TextStyle(color: Colors.white)),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateRoomScreen()));
        },
      ),
    );
  }
}