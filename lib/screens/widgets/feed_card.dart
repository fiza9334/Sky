// // 

// import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:timeago/timeago.dart' as timeago;
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/services.dart';

// import '../../models/vibe_model.dart';
// import '../../services/vibe_service.dart';
// import 'comment_sheet.dart';

// import '../../services/share_service.dart';
// import 'vibe_options_sheet.dart';

// class FeedCard extends StatefulWidget {
//   final VibeModel vibe;
//   const FeedCard({super.key, required this.vibe});

//   @override
//   State<FeedCard> createState() => _FeedCardState();
// }

// class _FeedCardState extends State<FeedCard> {
//   final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
//   bool _showHeartAnimation = false;

//   // void _handleDoubleTapLike() {
//   //   if (currentUserId == null) return;
//   //   bool isLiked = widget.vibe.likedBy.contains(currentUserId);
    
//   //   if (!isLiked) {
//   //     VibeService().toggleLike(widget.vibe.id, false);
//   //     setState(() => _showHeartAnimation = true);
//   //     Future.delayed(const Duration(milliseconds: 800), () {
//   //       if (mounted) setState(() => _showHeartAnimation = false);
//   //     });
//   //   }
//   // }

//   void _handleDoubleTapLike() {
//     if (currentUserId == null) return;
//     bool isLiked = widget.vibe.likedBy.contains(currentUserId);
    
//     if (!isLiked) {
//       HapticFeedback.mediumImpact(); // ADDED: Physical vibration
//       VibeService().toggleLike(widget.vibe.id, false);
//       setState(() => _showHeartAnimation = true);
//       Future.delayed(const Duration(milliseconds: 800), () {
//         if (mounted) setState(() => _showHeartAnimation = false);
//       });
//     }
//   }



//   @override
//   Widget build(BuildContext context) {
//     bool isLiked = widget.vibe.likedBy.contains(currentUserId);

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         border: Border.all(color: Colors.grey.shade200),
//         borderRadius: BorderRadius.circular(16), // Rounded corners
//         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header
//           ListTile(
//             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             leading: CircleAvatar(
//               backgroundColor: const Color(0xFF8F9779).withOpacity(0.3),
//               backgroundImage: widget.vibe.userProfilePic.isNotEmpty ? CachedNetworkImageProvider(widget.vibe.userProfilePic) : null,
//               child: widget.vibe.userProfilePic.isEmpty ? const Icon(Icons.person, color: Color(0xFF1B3022)) : null,
//             ),
//             title: Text(widget.vibe.username, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B3022), fontSize: 15)),
//             subtitle: Text(timeago.format(widget.vibe.timestamp), style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),

//             trailing: IconButton(
//               icon: const Icon(Icons.more_horiz, color: Colors.black87), 
//               onPressed: () => VibeOptionsSheet.show(context, widget.vibe), // Hooked up!
//             ),

// // In your build method Bottom Action Row:
//             IconButton(
//               icon: const Icon(Icons.send_outlined, color: Color(0xFF1B3022)), 
//               onPressed: () => ShareService.shareVibe(widget.vibe), // Hooked up!
//             ),
//           //   trailing: IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
//           // ),

//           // Content
//           // if (widget.vibe.content.isNotEmpty)
//           //   Padding(
//           //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//           //     child: Text(widget.vibe.content, style: const TextStyle(fontSize: 15, height: 1.4, color: Colors.black87)),
//           //   ),
//           // Content
//           if (widget.vibe.content.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//               child: Text(
//                 widget.vibe.content, 
//                 style: const TextStyle(
//                   fontSize: 15, 
//                   height: 1.4, 
//                   color: Colors.black87, // Color add kiya hai visibility ke liye
//                 ), // TextStyle yahan close hua
//               ), // Text yahan close hua
//             ), // Padding yahan close hui aur comma lagaya

//           // Image
//           if (widget.vibe.type == 'photo' && widget.vibe.imageUrl.isNotEmpty)
//             GestureDetector(
//               onDoubleTap: _handleDoubleTapLike,
//               child: Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8),
//                     child: CachedNetworkImage(
//                       imageUrl: widget.vibe.imageUrl,
//                       width: double.infinity,
//                       fit: BoxFit.cover,
//                       placeholder: (context, url) => Container(height: 300, color: Colors.grey[100]),
//                     ),
//                   ),
//                   if (_showHeartAnimation)
//                     TweenAnimationBuilder<double>(
//                       tween: Tween(begin: 0.5, end: 1.5),
//                       duration: const Duration(milliseconds: 300),
//                       builder: (context, value, child) => Transform.scale(scale: value, child: const Icon(Icons.favorite, color: Colors.white, size: 100)),
//                     ),
//                 ],
//               ),
//             ),

//           // Actions
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//             child: Row(
//               children: [
//                 IconButton(
//                   icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : const Color(0xFF1B3022), size: 28),
//                   onPressed: () => VibeService().toggleLike(widget.vibe.id, isLiked),
//                 ),
//                 Text('${widget.vibe.likesCount}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//                 const SizedBox(width: 16),
//                 IconButton(
//                   icon: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF1B3022), size: 26),
//                   onPressed: () => CommentSheet.show(context, widget.vibe.id),
//                 ),
//                 Text('${widget.vibe.commentsCount}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//                 const Spacer(),
//                 IconButton(icon: const Icon(Icons.send_outlined, color: Color(0xFF1B3022)), onPressed: () {}),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import '../../models/vibe_model.dart';
import '../../services/vibe_service.dart';
import 'comment_sheet.dart';
import '../../services/share_service.dart';
import 'vibe_options_sheet.dart';

class FeedCard extends StatefulWidget {
  final VibeModel vibe;
  const FeedCard({super.key, required this.vibe});

  @override
  State<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> {
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
  bool _showHeartAnimation = false;

  void _handleDoubleTapLike() {
    if (currentUserId == null) return;
    bool isLiked = widget.vibe.likedBy.contains(currentUserId);
    
    if (!isLiked) {
      HapticFeedback.mediumImpact(); // Physical vibration
      VibeService().toggleLike(widget.vibe.id, false);
      setState(() => _showHeartAnimation = true);
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) setState(() => _showHeartAnimation = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLiked = widget.vibe.likedBy.contains(currentUserId);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(16), // Rounded corners
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF8F9779).withOpacity(0.3),
              backgroundImage: widget.vibe.userProfilePic.isNotEmpty ? CachedNetworkImageProvider(widget.vibe.userProfilePic) : null,
              child: widget.vibe.userProfilePic.isEmpty ? const Icon(Icons.person, color: Color(0xFF1B3022)) : null,
            ),
            title: Text(widget.vibe.username, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B3022), fontSize: 15)),
            subtitle: Text(timeago.format(widget.vibe.timestamp), style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            trailing: IconButton(
              icon: const Icon(Icons.more_horiz, color: Colors.black87), 
              onPressed: () => VibeOptionsSheet.show(context, widget.vibe), // 3-Dot Menu Hooked up
            ),
          ), // <--- YAHAN MISSING THA CLOSING BRACKET

          // Content
          if (widget.vibe.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                widget.vibe.content, 
                style: const TextStyle(fontSize: 15, height: 1.4, color: Colors.black87),
              ), 
            ), 

          // Image
          if (widget.vibe.type == 'photo' && widget.vibe.imageUrl.isNotEmpty)
            GestureDetector(
              onDoubleTap: _handleDoubleTapLike,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: CachedNetworkImage(
                      imageUrl: widget.vibe.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(height: 300, color: Colors.grey[100]),
                    ),
                  ),
                  if (_showHeartAnimation)
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.5, end: 1.5),
                      duration: const Duration(milliseconds: 300),
                      builder: (context, value, child) => Transform.scale(scale: value, child: const Icon(Icons.favorite, color: Colors.white, size: 100)),
                    ),
                ],
              ),
            ),

          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : const Color(0xFF1B3022), size: 28),
                  onPressed: () => VibeService().toggleLike(widget.vibe.id, isLiked),
                ),
                Text('${widget.vibe.likesCount}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF1B3022), size: 26),
                  onPressed: () => CommentSheet.show(context, widget.vibe.id),
                ),
                Text('${widget.vibe.commentsCount}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                
                const Spacer(),
                
                // Share Button ekdum sahi jagah (Bottom Row me) aa gaya
                IconButton(
                  icon: const Icon(Icons.send_outlined, color: Color(0xFF1B3022)), 
                  onPressed: () => ShareService.shareVibe(widget.vibe),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}