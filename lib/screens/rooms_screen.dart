import 'package:echoo/screens/social/create_room_screen.dart';
import 'package:echoo/screens/social/widgets/room_card_horizontal.dart';
import 'package:echoo/screens/social/widgets/room_card_vertical.dart';
import 'package:flutter/material.dart';
import '../../../models/room_model.dart';
import '../services/firebase_service.dart';

// import '../../../widgets/wakie_bottom_nav.dart'; // Optional custom bottom nav to match image_9.png exactly

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> with SingleTickerProviderStateMixin {
  late TabController _clubTabController;
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _clubTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _clubTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dark Wakie Theme Colors
    const Color darkBackground = Color(0xFF131313);
    const Color cardColor = Color(0xFF1E1E1E);
    const Color primaryText = Colors.white;
    const Color secondaryText = Colors.white70;
    const Color liveGreen = Color(0xFF1E8D1E);
    const Color countText = Color(0xFFA5D6A7);

    return Scaffold(
      backgroundColor: darkBackground,
      // bottomNavigationBar: const WakieBottomNav(), // Simplified bottom navigation matching image_9.png
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Color(0xFF6B8D1B), // Olive green color
        label: Text("Create A Club", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: Icon(Icons.add, color: Colors.white),
        onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateRoomScreen()), // <-- Ye aapki Create Room screen ko khol dega
          );
        }
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ON STAGE NOW Section with 🔥
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Text(
                    "ON STAGE NOW",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text("🔥", style: TextStyle(fontSize: 18)), // Modernized header style
                ],
              ),
            ),

            // Horizontal Live List (Solves dummy data - Wakie style)
            SizedBox(
              height: 250,
              child: StreamBuilder<List<RoomModel>>(
                stream: _firebaseService.getLiveOnStageRooms(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    // This handles if user has not yet created composite index
                    return Center(child: Text("Error: Check Composite Indexes.", style: TextStyle(color: Colors.white70)));
                  }
                  final rooms = snapshot.data ?? [];
                  if (rooms.isEmpty) {
                    return Center(child: Text("No live rooms right now.", style: TextStyle(color: Colors.white70)));
                  }
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: rooms.length,
                    itemBuilder: (context, index) {
                      return RoomCardHorizontal(room: rooms[index]);
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            // Tabs for Club list
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Theme(
                data: ThemeData(highlightColor: Colors.transparent, splashColor: Colors.transparent),
                child: TabBar(
                  controller: _clubTabController,
                  dividerColor: Colors.transparent,
                  isScrollable: true,
                  labelColor: primaryText,
                  unselectedLabelColor: secondaryText,
                  labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
                  indicator: UnderlineTabIndicator(borderSide: BorderSide(color: Color(0xFF6B8D1B), width: 3), insets: EdgeInsets.symmetric(horizontal: 15)),
                  tabs: [
                    Tab(text: "My Room"),
                    Tab(text: "Popular"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // TabBarView requires expanded or finite height. SingleChildScrollView needs fixed height.
            // Using constrained box based on general screen height
            SizedBox(
              height: 400, // Fixed height to allow SingleChildScrollView
              child: TabBarView(
                controller: _clubTabController,
                children: [
                  _buildMyRoomsList(),
                  _buildPopularRoomsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyRoomsList() {
    return Center(child: Text("Logic to filter rooms where you are host/moderator", style: TextStyle(color: Colors.white70)));
  }

  Widget _buildPopularRoomsList() {
    return StreamBuilder<List<RoomModel>>(
      stream: _firebaseService.getPopularClubs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        final rooms = snapshot.data ?? [];
        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(), // Scroll handled by parent
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            return RoomCardVertical(room: rooms[index]);
          },
        );
      },
    );
  }
}