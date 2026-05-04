import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListDetailScreen extends StatelessWidget {
  final String title;
  final String collectionPath; // Firestore collection ka naam ya path

  const ListDetailScreen({
    super.key,
    required this.title,
    required this.collectionPath,
  });

  // Theme Colors (Profile Screen se match karte hue)
  static const Color backgroundGreen = Color(0xFF0C100C);
  static const Color cardGreen = Color(0xFF141A14);
  static const Color oliveAccent = Color(0xFFA5B880);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGreen,
      appBar: AppBar(
        backgroundColor: backgroundGreen,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // User-specific data fetch karne ke liye query
        stream: FirebaseFirestore.instance
            .collection(collectionPath)
            .orderBy('timestamp', descending: true) // Naya data upar dikhane ke liye
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: oliveAccent));
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong", style: TextStyle(color: Colors.red)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 60, color: Colors.grey.withOpacity(0.3)),
                  const SizedBox(height: 10),
                  Text("No $title found", style: const TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              
              // Alag-alag lists ke liye UI customization
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardGreen,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10, width: 0.5),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: oliveAccent.withOpacity(0.1),
                    child: Icon(_getLeadingIcon(title), color: oliveAccent),
                  ),
                  title: Text(
                    data['name'] ?? data['title'] ?? "Unknown",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    data['description'] ?? "No details available",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
                  onTap: () {
                    // Item click logic (Details page etc.)
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Title ke hisaab se icon badalne ka helper
  IconData _getLeadingIcon(String title) {
    switch (title.toLowerCase()) {
      case 'rooms':
        return Icons.meeting_room_outlined;
      case 'vibes':
        return Icons.waves;
      case 'fave':
      case 'faves':
        return Icons.favorite_border;
      default:
        return Icons.list;
    }
  }
}