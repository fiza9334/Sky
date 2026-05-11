// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:shimmer/shimmer.dart';

// import '../models/vibe_model.dart';
// import 'widgets/story_bar.dart';
// import 'widgets/feed_card.dart';

// class VibesScreen extends StatefulWidget {
//   const VibesScreen({super.key});

//   @override
//   State<VibesScreen> createState() => _VibesScreenState();
// }

// class _VibesScreenState extends State<VibesScreen> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose(); // Fix: Prevent memory leaks
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: const Text("Vibes", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
//         bottom: TabBar(
//           controller: _tabController,
//           labelColor: Colors.black,
//           unselectedLabelColor: Colors.grey,
//           indicatorColor: Colors.black,
//           indicatorWeight: 3,
//           tabs: const [Tab(text: "LIVE FEED"), Tab(text: "MY VIBES")],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           _FeedTabView(firestore: _firestore, isMyVibes: false, parentController: _tabController),
//           _FeedTabView(firestore: _firestore, isMyVibes: true, parentController: _tabController),
//         ],
//       ),
//     );
//   }
// }

// // Separated into its own Stateful widget to utilize KeepAlive
// class _FeedTabView extends StatefulWidget {
//   final FirebaseFirestore firestore;
//   final bool isMyVibes;
//   final TabController parentController;

//   const _FeedTabView({required this.firestore, required this.isMyVibes, required this.parentController});

//   @override
//   State<_FeedTabView> createState() => _FeedTabViewState();
// }

// class _FeedTabViewState extends State<_FeedTabView> with AutomaticKeepAliveClientMixin {
//   @override
//   bool get wantKeepAlive => true; // Fix: Prevents list from rebuilding/losing scroll position when switching tabs

//   Future<void> _onRefresh() async {
//     setState(() {}); // Triggers StreamBuilder to re-evaluate
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

//     if (currentUserId == null) return const Center(child: Text("Please Login"));

//     if (!widget.isMyVibes) {
//       Query liveQuery = widget.firestore.collection('vibes')
//           .orderBy('timestamp', descending: true)
//           .limit(20); // Fix: Pagination limit to save reads
//       return _buildList(liveQuery);
//     }

//     return FutureBuilder<DocumentSnapshot>(
//       future: widget.firestore.collection('users').doc(currentUserId).get(),
//       builder: (context, userSnapshot) {
//         if (userSnapshot.connectionState == ConnectionState.waiting) return _buildShimmer();

//         List<dynamic> faveList = (userSnapshot.data?.data() as Map<String, dynamic>?)?['fave'] ?? [];
        
//         if (faveList.isEmpty) return _buildEmptyState();

//         if (!faveList.contains(currentUserId)) faveList.add(currentUserId);

//         // Fix: whereIn limit crash - Take top 10 to prevent hard exception
//         List<dynamic> safeFaveList = faveList.take(10).toList();

//         Query faveQuery = widget.firestore.collection('vibes')
//             .where('userId', whereIn: safeFaveList)
//             .orderBy('timestamp', descending: true)
//             .limit(20);

//         return _buildList(faveQuery);
//       },
//     );
//   }

//   Widget _buildList(Query query) {
//     return RefreshIndicator(
//       onRefresh: _onRefresh,
//       color: Colors.black,
//       child: CustomScrollView(
//         slivers: [
//           const SliverToBoxAdapter(child: StoryBar()), // Stories stick to top of feed
//           StreamBuilder<QuerySnapshot>(
//             stream: query.snapshots(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return SliverToBoxAdapter(child: _buildShimmer());
//               }
//               if (snapshot.hasError) {
//                 return SliverToBoxAdapter(child: Center(child: Text("Error: ${snapshot.error}")));
//               }

//               var docs = snapshot.data?.docs ?? [];
//               if (docs.isEmpty) {
//                 return SliverFillRemaining(child: Center(child: Text("No Vibes yet.")));
//               }

//               return SliverList(
//                 delegate: SliverChildBuilderDelegate(
//                   (context, index) {
//                     var vibe = VibeModel.fromFirestore(docs[index]);
//                     return FeedCard(vibe: vibe);
//                   },
//                   childCount: docs.length,
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.person_add_alt_1_rounded, size: 80, color: Colors.grey[400]),
//           const SizedBox(height: 20),
//           const Text("No Faves Yet", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 10),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: const StadiumBorder()),
//             onPressed: () => widget.parentController.animateTo(0),
//             child: const Text("Explore Live Feed"),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _buildShimmer() {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey[300]!,
//       highlightColor: Colors.grey[100]!,
//       child: Column(
//         children: List.generate(3, (index) => Container(
//           height: 300,
//           margin: const EdgeInsets.only(bottom: 12),
//           color: Colors.white,
//         )),
//       ),
//     );
//   }
// }











// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:shimmer/shimmer.dart';

// import '../../models/vibe_model.dart';
// import 'widgets/story_bar.dart';
// import 'widgets/feed_card.dart';
// import 'search_screen.dart'; // We will create this

// class VibesScreen extends StatefulWidget {
//   const VibesScreen({super.key});

//   @override
//   State<VibesScreen> createState() => _VibesScreenState();
// }

// class _VibesScreenState extends State<VibesScreen> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F5F0), // Earthy Background
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFF5F5F0),
//         elevation: 0,
//         automaticallyImplyLeading: false, // FIX: Removes back button
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Expanded(
//               child: TabBar(
//                 controller: _tabController,
//                 isScrollable: true,
//                 tabAlignment: TabAlignment.start, // FIX: Left aligns tabs
//                 labelColor: const Color(0xFF1B3022), // Deepest Jungle Green
//                 unselectedLabelColor: Colors.grey,
//                 indicatorColor: const Color(0xFF1B3022),
//                 indicatorWeight: 3,
//                 labelPadding: const EdgeInsets.only(right: 20),
//                 dividerColor: Colors.transparent,
//                 tabs: const [
//                   Tab(child: Text("LIVE FEED", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
//                   Tab(child: Text("MY VIBES", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
//                 ],
//               ),
//             ),
//             IconButton(
//               icon: const Icon(Icons.search_rounded, color: Color(0xFF1B3022), size: 28),
//               onPressed: () {
//                 Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
//               },
//             ),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           _FeedTabView(firestore: _firestore, isMyVibes: false, parentController: _tabController),
//           _FeedTabView(firestore: _firestore, isMyVibes: true, parentController: _tabController),
//         ],
//       ),
//     );
//   }
// }

// // Keep your existing _FeedTabView implementation here, it was mostly correct, 
// // just ensure it passes the VibeModel down to FeedCard.



import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shimmer/shimmer.dart';

import '../../models/vibe_model.dart';
import 'widgets/story_bar.dart';
import 'widgets/feed_card.dart';

class VibesScreen extends StatefulWidget {
  const VibesScreen({super.key});

  @override
  State<VibesScreen> createState() => _VibesScreenState();
}

class _VibesScreenState extends State<VibesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0), // Earthy Background
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F0),
        elevation: 0,
        automaticallyImplyLeading: false, 
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start, 
                labelColor: const Color(0xFF1B3022), // Deepest Jungle Green
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFF1B3022),
                indicatorWeight: 3,
                labelPadding: const EdgeInsets.only(right: 20),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(child: Text("LIVE FEED", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                  Tab(child: Text("MY VIBES", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search_rounded, color: Color(0xFF1B3022), size: 28),
              onPressed: () {
                // Jab aap SearchScreen bana lenge, tab is line ko use karna:
                // Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
                
                // Abhi ke liye temporary message:
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Search screen jaldi aayegi!")));
              },
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _FeedTabView(firestore: _firestore, isMyVibes: false, parentController: _tabController),
          _FeedTabView(firestore: _firestore, isMyVibes: true, parentController: _tabController),
        ],
      ),
    );
  }
}

// ============================================================================
// YAHAN SE _FeedTabView CLASS SHURU HOTI HAI (Ye same file me hi rahegi)
// ============================================================================

class _FeedTabView extends StatefulWidget {
  final FirebaseFirestore firestore;
  final bool isMyVibes;
  final TabController parentController;

  const _FeedTabView({
    super.key, // Linter warning theek karne ke liye super.key add kiya
    required this.firestore,
    required this.isMyVibes,
    required this.parentController,
  });

  @override
  State<_FeedTabView> createState() => _FeedTabViewState();
}

class _FeedTabViewState extends State<_FeedTabView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Scroll position bachane ke liye

  Future<void> _onRefresh() async {
    setState(() {}); // Naya data load karne ke liye
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // KeepAlive ke liye zaroori
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      return const Center(child: Text("Please login to continue"));
    }

    if (!widget.isMyVibes) {
      Query liveQuery = widget.firestore
          .collection('vibes')
          .orderBy('timestamp', descending: true)
          .limit(20);
      return _buildRefreshableList(liveQuery);
    }

    return FutureBuilder<DocumentSnapshot>(
      future: widget.firestore.collection('users').doc(currentUserId).get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmerLoading();
        }

        List<dynamic> faveList = (userSnapshot.data?.data() as Map<String, dynamic>?)?['fave'] ?? [];

        if (faveList.isEmpty) {
          return _buildEmptyState();
        }

        if (!faveList.contains(currentUserId)) {
          faveList.add(currentUserId);
        }

        List<dynamic> safeFaveList = faveList.take(10).toList(); // Safe limit for whereIn query

        Query faveQuery = widget.firestore
            .collection('vibes')
            .where('userId', whereIn: safeFaveList)
            .orderBy('timestamp', descending: true)
            .limit(20);

        return _buildRefreshableList(faveQuery);
      },
    );
  }

  Widget _buildRefreshableList(Query query) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: const Color(0xFF6B8E23), 
      backgroundColor: Colors.white,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: StoryBar()), // Top me story bar
          
          StreamBuilder<QuerySnapshot>(
            stream: query.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverToBoxAdapter(child: _buildShimmerLoading());
              }

              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(child: Text("Error: ${snapshot.error}")),
                );
              }

              var docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text("No vibes found yet.", style: TextStyle(color: Colors.grey))),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final vibe = VibeModel.fromFirestore(docs[index]);
                      return FeedCard(vibe: vibe);
                    },
                    childCount: docs.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded, size: 80, color: const Color(0xFF8F9779).withOpacity(0.5)),
          const SizedBox(height: 20),
          const Text(
            "Your 'My Vibes' is empty",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B3022)),
          ),
          const SizedBox(height: 10),
          const Text("Follow users to see their vibes here.", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 25),
          ElevatedButton(
            onPressed: () => widget.parentController.animateTo(0),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B3022), 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            child: const Text("Explore Live Feed", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => Container(
          height: 350,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}