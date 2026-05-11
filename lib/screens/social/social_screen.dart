// import 'package:flutter/material.dart';
// import 'tabs/rooms_tab.dart';
// import 'tabs/call_tab.dart';
// import 'tabs/message_tab.dart';
// import '../notification/notification_screen.dart';
// import 'tabs/inbox.dart';

// class SocialScreen extends StatelessWidget {
//   const SocialScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 3,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text(
//             'Social',
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
//           ),
//           centerTitle: false,
//           elevation: 0,
//           backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//           foregroundColor: Colors.black,
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.notifications_none_outlined, size: 28),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const NotificationScreen()),
//                 );
//               },
//             ),
//             const SizedBox(width: 8),
//           ],
//           bottom: const TabBar(
//             labelColor: Colors.blueAccent,
//             unselectedLabelColor: Colors.grey,
//             indicatorColor: Colors.blueAccent,
//             indicatorWeight: 3,
//             labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//             tabs: [
//               Tab(text: 'Rooms'),
//               Tab(text: 'Call'),
//               Tab(text: 'Message'),
//             ],
//           ),
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

import 'package:echoo/screens/rooms_screen.dart';
import 'package:flutter/material.dart';
import 'tabs/rooms_tab.dart';
import 'tabs/call_tab.dart';
import 'tabs/message_tab.dart';
import '../notification/notification_screen.dart';
import 'tabs/inbox.dart';

class SocialScreen extends StatelessWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          // 1. Back arrow hatane ke liye
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          // Note: Aapke dark theme ke hisaab se yahan Colors.white jyada accha lagega
          foregroundColor: Colors.white, 
          
          // 2. Tabs ko left me align karne ke liye AppBar ke title me rakha hai
          title: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            dividerColor: Colors.transparent, // Default bottom line ko hatane ke liye
            labelPadding: EdgeInsets.only(right: 24.0), // Tabs ke beech ki spacing ke liye
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blueAccent,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            tabs: [
              Tab(text: 'Rooms'),
              Tab(text: 'Call'),
              Tab(text: 'Message'),
            ],
          ),
          
          // 3. Right side me sirf notification icon
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_none_outlined, size: 28),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationScreen()),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: const TabBarView(
          children: [
            RoomsScreen(),
            CallTab(),
            InboxScreen(), // Make sure this matches your imports
          ],
        ),
      ),
    );
  }
}