import 'package:flutter/material.dart';

class RoomDetailScreen extends StatelessWidget {
  final String roomId;
  const RoomDetailScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Column(
        children: [
          const Text("On Stage", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          // Horizontal Avatars Placeholder
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 4,
              itemBuilder: (context, index) => const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircleAvatar(radius: 35, child: Icon(Icons.person)),
              ),
            ),
          ),
          const Divider(color: Colors.white10),
          const ListTile(
            title: Text("Listeners", style: TextStyle(color: Colors.white70)),
            trailing: Icon(Icons.mic_off, color: Colors.white),
          ),
          const Spacer(),
          // Basic Chat Input Placeholder
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white.withOpacity(0.05),
            child: Row(
              children: [
                const Expanded(child: TextField(decoration: InputDecoration(hintText: "Say something..."))),
                IconButton(icon: const Icon(Icons.send), onPressed: () {}),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'tabs/rooms_tab.dart';
// import 'tabs/call_tab.dart';
// import 'tabs/inbox.dart';
// import '../notification/notification_screen.dart';
// // Path apne hisaab se adjust kar lijiye
// // import '../room_detail_screen.dart';

// class SocialScreen extends StatelessWidget {
//   const SocialScreen({super.key});

//   // Apka Premium Dark Theme Colors
//   static const Color backgroundGreen = Color(0xFF0C100C);
//   static const Color oliveAccent = Color(0xFFA5B880);

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 3,
//       child: Scaffold(
//         backgroundColor: backgroundGreen,
//         appBar: AppBar(
//           backgroundColor: backgroundGreen,
//           elevation: 0,
//           automaticallyImplyLeading: false, // Back arrow hata diya
//           titleSpacing: 20, // Left side se thodi spacing
          
//           // Tabs ko title ki jagah daal diya aur left align kar diya
//           title: const TabBar(
//             isScrollable: true, // Tabs ko left me compress karne ke liye zaroori
//             tabAlignment: TabAlignment.start, // Left alignment ke liye
//             dividerColor: Colors.transparent, // Niche ki grey line hatane ke liye
//             labelColor: oliveAccent, // Selected tab color
//             unselectedLabelColor: Colors.grey, // Unselected tab color
//             indicatorColor: oliveAccent, // Underline color
//             indicatorWeight: 3,
//             indicatorSize: TabBarIndicatorSize.label, // Indicator sirf text ke barabar lamba hoga
//             labelPadding: EdgeInsets.only(right: 24), // Tabs ke beech me gap
//             padding: EdgeInsets.zero,
//             labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//             tabs: [
//               Tab(text: 'Rooms'),
//               Tab(text: 'Call'),
//               Tab(text: 'Message'),
//             ],
//           ),
          
//           // Right side me sirf notification
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.notifications_none_outlined, color: Colors.white, size: 28),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const NotificationScreen()),
//                 );
//               },
//             ),
//             const SizedBox(width: 8),
//           ],
//         ),
        
//         body: const TabBarView(
//           children: [
//             RoomsTab(),
//             CallTab(),
//             InboxScreen()
//           ],
//         ),
//       ),
//     );
//   }
// }