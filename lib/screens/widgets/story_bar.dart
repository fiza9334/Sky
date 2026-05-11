// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'create_vibe_sheet.dart';

// class StoryBar extends StatelessWidget {
//   const StoryBar({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final User? currentUser = FirebaseAuth.instance.currentUser;

//     return Container(
//       height: 100,
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       color: Colors.white,
//       child: ListView(
//         scrollDirection: Axis.horizontal,
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         children: [
//           // Current User + Add Button
//           GestureDetector(
//             onTap: () => CreateVibeSheet.show(context),
//             child: Padding(
//               padding: const EdgeInsets.only(right: 15),
//               child: Column(
//                 children: [
//                   Stack(
//                     alignment: Alignment.bottomRight,
//                     children: [
//                       CircleAvatar(
//                         radius: 30,
//                         backgroundColor: Colors.grey[200],
//                         backgroundImage: (currentUser?.photoURL != null && currentUser!.photoURL!.isNotEmpty)
//                             ? CachedNetworkImageProvider(currentUser.photoURL!)
//                             : null,
//                         child: (currentUser?.photoURL == null) ? const Icon(Icons.person, color: Colors.grey) : null,
//                       ),
//                       Container(
//                         decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
//                         padding: const EdgeInsets.all(4),
//                         child: const Icon(Icons.add, color: Colors.white, size: 14),
//                       )
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   const Text("Add Vibe", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
//                 ],
//               ),
//             ),
//           ),
          
//           // Stream of other users from Firestore
//           StreamBuilder<QuerySnapshot>(
//             stream: FirebaseFirestore.instance.collection('users').limit(10).snapshots(),
//             builder: (context, snapshot) {
//               if (!snapshot.hasData) return const SizedBox.shrink();
              
//               var users = snapshot.data!.docs.where((doc) => doc.id != currentUser?.uid).toList();
              
//               return Row(
//                 children: users.map((doc) {
//                   var data = doc.data() as Map<String, dynamic>;
//                   return Padding(
//                     padding: const EdgeInsets.only(right: 15),
//                     child: Column(
//                       children: [
//                         Container(
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             border: Border.all(color: Colors.purpleAccent, width: 2),
//                           ),
//                           padding: const EdgeInsets.all(2),
//                           child: CircleAvatar(
//                             radius: 26,
//                             backgroundColor: Colors.grey[200],
//                             backgroundImage: (data['profilePic'] != null && data['profilePic'].isNotEmpty)
//                                 ? CachedNetworkImageProvider(data['profilePic'])
//                                 : null,
//                             child: (data['profilePic'] == null || data['profilePic'].isEmpty) 
//                                 ? const Icon(Icons.person, color: Colors.grey) 
//                                 : null,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           (data['username'] ?? 'User').toString().split(' ').first,
//                           style: const TextStyle(fontSize: 12),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ],
//                     ),
//                   );
//                 }).toList(),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'create_vibe_sheet.dart';

class StoryBar extends StatelessWidget {
  const StoryBar({super.key});

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Container(
      height: 115, // FIX: Strict height prevents bottom overflow
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F0),
        border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 0.5)),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // Current User Add Button
          GestureDetector(
            onTap: () => CreateVibeSheet.show(context),
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: const Color(0xFF8F9779).withOpacity(0.3),
                        backgroundImage: (currentUser?.photoURL != null) ? CachedNetworkImageProvider(currentUser!.photoURL!) : null,
                        child: (currentUser?.photoURL == null) ? const Icon(Icons.person, color: Color(0xFF1B3022)) : null,
                      ),
                      Container(
                        decoration: BoxDecoration(color: const Color(0xFF6B8E23), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.add, color: Colors.white, size: 14),
                      )
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text("Add Vibe", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1B3022))),
                ],
              ),
            ),
          ),
          
          // Firestore Users Stream
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').limit(10).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              var users = snapshot.data!.docs.where((doc) => doc.id != currentUser?.uid).toList();
              
              return Row(
                children: users.map((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF6B8E23), width: 2.5), // Olive gradient ring
                          ),
                          child: CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: (data['profilePic'] != null && data['profilePic'].isNotEmpty) ? CachedNetworkImageProvider(data['profilePic']) : null,
                            child: (data['profilePic'] == null || data['profilePic'].isEmpty) ? const Icon(Icons.person, color: Colors.grey) : null,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: 65,
                          child: Text(
                            (data['username'] ?? 'User').toString().split(' ').first,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF1B3022)),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}