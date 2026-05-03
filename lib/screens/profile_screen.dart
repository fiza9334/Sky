

/*
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:io'; // Isse File wala error chala jayega
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'list_detail_screen.dart'; // Naya file banayein list dikhane ke liye
class ProfileScreen extends StatefulWidget {
  
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Earthy Dark Palette (Image se match karta hua)
  static const Color backgroundGreen = Color(0xFF0C100C);
  static const Color cardGreen = Color(0xFF141A14);
  static const Color oliveAccent = Color(0xFFA5B880);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- NAVIGATION LOGIC ---
  void _navigateToList(BuildContext context, String title, String collectionPath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListDetailScreen(title: title, collectionPath: collectionPath),
      ),
    );
  }

  // --- PROFILE PICTURE UPDATE LOGIC ---

  // Profile Screen ke andar update function
Future<void> _updateProfilePicture() async {
  final ImagePicker picker = ImagePicker();
  // Photo select karein
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
  
  if (image != null) {
    File file = File(image.path);
    String uid = _auth.currentUser!.uid;
    
    try {
      // Storage mein upload karein
      Reference ref = FirebaseStorage.instance.ref().child('profile_pics').child('$uid.jpg');
      await ref.putFile(file);
      
      // Download URL lein
      String downloadUrl = await ref.getDownloadURL();
      
      // Firestore mein update karein
      await _firestore.collection('users').doc(uid).update({
        'profileImageUrl': downloadUrl,
      });
      
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Photo Updated!")));
    } catch (e) {
      print("Error: $e");
    }
  }
}


  // Future<void> _updateProfilePicture() async {
  //   // print("Opening Image Picker...");
  //   // TODO: ImagePicker use karke gallery/camera se photo lein
  //   // TODO: Firebase Storage mein upload karein
  //   // TODO: Firestore mein imageURL update karein
  //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Image upload logic needs to be implemented")));
  // }

  // --- EDIT PROFILE MODAL (With 30 Days Logic) ---
  void _showEditProfileModal(BuildContext context, Map<String, dynamic> userData) {
    TextEditingController nameController = TextEditingController(text: userData['username']);
    TextEditingController bioController = TextEditingController(text: userData['bio'] ?? '');

    // Check karein ki kya username update ho sakta hai
    bool canUpdateUsername = true;
    String statusMessage = "";

    // if (userData['lastUsernameUpdate'] != null) {
    //   DateTime lastUpdate = (userData['lastUsernameUpdate'] as Timestamp).toDate();
    //   DateTime nextAllowedUpdate = lastUpdate.add(const Duration(days: 30));
    //   if (DateTime.now().isBefore(nextAllowedUpdate)) {
    //     canUpdateUsername = false;
    //     String formattedDate = DateFormat('dd MMM yyyy').format(nextAllowedUpdate);
    //     statusMessage = "Username can be changed after $formattedDate";
    //   }
    // }

    if (userData['lastUsernameUpdate'] != null) {
  DateTime lastUpdate = (userData['lastUsernameUpdate'] as Timestamp).toDate();
  // Check karein ki kya 30 din pure ho gaye hain
  if (DateTime.now().difference(lastUpdate).inDays < 30) {
    // Update allow nahi hoga
  }
}

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardGreen,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: Text("Edit Profile", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
            const SizedBox(height: 20),

            // Username Input (Conditional)
            const Text("Username", style: TextStyle(color: Colors.grey, fontSize: 12)),
            TextField(
              controller: nameController,
              enabled: canUpdateUsername, // 30 din ka lock
              style: TextStyle(color: canUpdateUsername ? Colors.white : Colors.grey),
              decoration: InputDecoration(
                hintText: "Enter username",
                hintStyle: const TextStyle(color: Colors.grey),
                suffixIcon: canUpdateUsername ? null : const Icon(Icons.lock_outline, color: Colors.grey, size: 16),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: oliveAccent)),
              ),
            ),
            if (!canUpdateUsername)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(statusMessage, style: const TextStyle(color: Colors.redAccent, fontSize: 11)),
              ),
            const SizedBox(height: 15),

            // Bio Input (Hamesha active)
            const Text("Bio", style: TextStyle(color: Colors.grey, fontSize: 12)),
            TextField(
              controller: bioController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Tell us about yourself...",
                hintStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: oliveAccent)),
              ),
            ),
            const SizedBox(height: 25),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: oliveAccent, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: () async {
                  Map<String, dynamic> updates = {
                    'bio': bioController.text.trim(),
                  };

                  if (canUpdateUsername && nameController.text.trim() != userData['username']) {
                    updates['username'] = nameController.text.trim();
                    updates['lastUsernameUpdate'] = FieldValue.serverTimestamp(); // Timestamp set karein
                  }

                  await _firestore.collection('users').doc(_auth.currentUser!.uid).update(updates);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text("Save", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    return Scaffold(
      backgroundColor: backgroundGreen,
      // --- HEADER (Updated as per request) ---
      appBar: AppBar(
        backgroundColor: backgroundGreen,
        elevation: 0,
        automaticallyImplyLeading: false, // Back button hataya
        // title mein 'Profile' ki jagah Visitor counter
        title: StreamBuilder<DocumentSnapshot>(
          stream: _firestore.collection('users').doc(currentUser?.uid).snapshots(),
          builder: (context, snapshot) {
            int views = 0;
            if (snapshot.hasData && snapshot.data!.exists) {
              views = snapshot.data!.get('profileViews') ?? 0;
            }
            return Row(
              children: [
                const Icon(Icons.remove_red_eye_outlined, color: oliveAccent, size: 18),
                const SizedBox(width: 5),
                Text("$views Views", style: const TextStyle(color: oliveAccent, fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () { /* Navigate to Settings Screen */ },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('users').doc(currentUser?.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: oliveAccent));
          if (!snapshot.hasData || !snapshot.data!.exists) return const Center(child: Text("User data not found", style: TextStyle(color: Colors.white)));

          var userData = snapshot.data!.data() as Map<String, dynamic>;
          String imageUrl = userData['profileImageUrl'] ?? '';

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // --- PROFILE PICTURE (Clickable to update) ---
                GestureDetector(
                  onTap: _updateProfilePicture, // Photo update logic
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: cardGreen,
                        backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                        child: imageUrl.isEmpty ? const Icon(Icons.person, size: 50, color: oliveAccent) : null,
                      ),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, size: 14, color: Colors.black),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                // --- USERNAME & GENDER ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(userData['username'] ?? 'jj', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    // Image mein cyan color ka gender icon hai
                    Text(userData['gender'] == "Female" ? "♀" : "♂", style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),

                const SizedBox(height: 4),
                Text(userData['bio'] ?? '||', style: const TextStyle(color: Colors.grey, fontSize: 14)),

                const SizedBox(height: 15),

                // --- EDIT PROFILE BUTTON ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: SizedBox(
                    width: double.infinity,
                    height: 35,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey, width: 0.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _showEditProfileModal(context, userData),
                      child: const Text("Edit Profile", style: TextStyle(color: Colors.white, fontSize: 13)),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // --- STATS ROW (Clickable & Responsive) ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildClickableStat(context, Icons.door_front_door_outlined, "Rooms", userData['roomsCount'] ?? 0, "rooms_list"),
                    _buildClickableStat(context, Icons.waves, "Vibes", userData['vibesCreated'] ?? 0, "vibes_list"),
                    _buildClickableStat(context, Icons.favorite_border, "Fave", userData['faveCount'] ?? 0, "my_faves_list"),
                    _buildClickableStat(context, Icons.favorite, "Faves", userData['favesReceived'] ?? 0, "favourited_by_list"),
                  ],
                ),

                const SizedBox(height: 30),

                // --- PERSONAL INFO SECTION (From Image) ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Personal Info", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      _buildInfoTile(Icons.language, "Languages", ""), // Blank value as requested
                      const SizedBox(height: 10),
                      _buildInfoTile(Icons.calendar_month, "Signup Date", userData['signupDate'] ?? "01-01-2024"),
                      const SizedBox(height: 10),
                      _buildInfoTile(Icons.access_time, "Local Time", DateFormat('hh:mm a').format(DateTime.now())),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _buildInfoTile(Icons.call, "Calls", (userData['totalCalls'] ?? 0).toString())),
                          const SizedBox(width: 10),
                          Expanded(child: _buildInfoTile(Icons.cake, "Age", "${userData['age'] ?? 17} yrs")),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- Helper Widget: Clickable Stat Item ---
  Widget _buildClickableStat(BuildContext context, IconData icon, String label, int count, String path) {
    return Expanded(
      child: InkWell(
        onTap: () => _navigateToList(context, label, path), // Click karne par list khulegi
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Icon(icon, color: oliveAccent, size: 26),
              const SizedBox(height: 5),
              Text(count.toString(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widget: Info Tile ---
  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: cardGreen, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: oliveAccent, size: 20),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              if (value.isNotEmpty) Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}

*/

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Upar ka red bar hatane ke liye
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:io'; 
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'list_detail_screen.dart'; 
import 'dart:typed_data';
import '../settings/settings_screen.dart';
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Earthy Dark Palette
  static const Color backgroundGreen = Color(0xFF0C100C);
  static const Color cardGreen = Color(0xFF141A14);
  static const Color oliveAccent = Color(0xFFA5B880);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- NAVIGATION LOGIC ---
  void _navigateToList(BuildContext context, String title, String collectionPath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListDetailScreen(title: title, collectionPath: collectionPath),
      ),
    );
  }

  // --- PROFILE PICTURE UPDATE LOGIC ---
  Future<void> _updateProfilePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      String uid = _auth.currentUser!.uid;
      
      try {
        Reference ref = FirebaseStorage.instance.ref().child('profile_pics').child('$uid.jpg');
        
        // WEB & MOBILE FIX: File() ki jagah image ke bytes read karenge
        Uint8List imageData = await image.readAsBytes();
        await ref.putData(imageData); // putFile ki jagah putData
        
        String downloadUrl = await ref.getDownloadURL();
        
        await _firestore.collection('users').doc(uid).update({
          'profileImageUrl': downloadUrl,
        });
        
        // Beautiful Success SnackBar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 10),
                  Text("Profile Photo Updated Successfully!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
              backgroundColor: oliveAccent.withOpacity(0.9),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(20),
            )
          );
        }
      } catch (e) {
        print("Error uploading image: $e");
      }
    }
  }




  // Future<void> _updateProfilePicture() async {
  //   final ImagePicker picker = ImagePicker();
  //   final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
  //   if (image != null) {
  //     File file = File(image.path);
  //     String uid = _auth.currentUser!.uid;
      
  //     try {
  //       Reference ref = FirebaseStorage.instance.ref().child('profile_pics').child('$uid.jpg');
  //       await ref.putFile(file);
        
  //       String downloadUrl = await ref.getDownloadURL();
        
  //       await _firestore.collection('users').doc(uid).update({
  //         'profileImageUrl': downloadUrl,
  //       });
        
  //       // Beautiful Success SnackBar
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: const Row(
  //               children: [
  //                 Icon(Icons.check_circle, color: Colors.white),
  //                 SizedBox(width: 10),
  //                 Text("Profile Photo Updated Successfully!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
  //               ],
  //             ),
  //             backgroundColor: oliveAccent.withOpacity(0.9), // Stylish translucent look
  //             behavior: SnackBarBehavior.floating,
  //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //             margin: const EdgeInsets.all(20),
  //           )
  //         );
  //       }
  //     } catch (e) {
  //       print("Error: $e");
  //     }
  //   }
  // }

  // --- EDIT PROFILE MODAL ---
  void _showEditProfileModal(BuildContext context, Map<String, dynamic> userData) {
    TextEditingController nameController = TextEditingController(text: userData['username']);
    TextEditingController bioController = TextEditingController(text: userData['bio'] ?? '');

    bool canUpdateUsername = true;
    String statusMessage = "";

    if (userData['lastUsernameUpdate'] != null) {
      DateTime lastUpdate = (userData['lastUsernameUpdate'] as Timestamp).toDate();
      if (DateTime.now().difference(lastUpdate).inDays < 30) {
        canUpdateUsername = false;
        statusMessage = "Username can only be changed once every 30 days.";
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardGreen,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: Text("Edit Profile", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
            const SizedBox(height: 20),

            // Username Input
            const Text("Username", style: TextStyle(color: Colors.grey, fontSize: 12)),
            TextField(
              controller: nameController,
              enabled: canUpdateUsername, 
              style: TextStyle(color: canUpdateUsername ? Colors.white : Colors.grey),
              decoration: InputDecoration(
                hintText: "Enter username",
                hintStyle: const TextStyle(color: Colors.grey),
                suffixIcon: canUpdateUsername ? null : const Icon(Icons.lock_outline, color: Colors.grey, size: 16),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: oliveAccent)),
              ),
            ),
            if (!canUpdateUsername)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(statusMessage, style: const TextStyle(color: Colors.redAccent, fontSize: 11)),
              ),
            const SizedBox(height: 15),

            // Bio Input
            const Text("Bio", style: TextStyle(color: Colors.grey, fontSize: 12)),
            TextField(
              controller: bioController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Tell us about yourself...",
                hintStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: oliveAccent)),
              ),
            ),
            const SizedBox(height: 20),

            // --- THEME CHANGE OPTION ADDED HERE ---
            const Divider(color: Colors.white10),
            const Text("Customization", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.color_lens_outlined, color: oliveAccent),
              title: const Text("Change Theme & Fonts", style: TextStyle(color: Colors.white, fontSize: 14)),
              subtitle: const Text("Background color, font style & more", style: TextStyle(color: Colors.grey, fontSize: 12)),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
              onTap: () {
                // TODO: Yahan Theme Settings ka page open karein
              },
            ),
            const Divider(color: Colors.white10),
            const SizedBox(height: 10),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: oliveAccent, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: () async {
                  Map<String, dynamic> updates = {
                    'bio': bioController.text.trim(),
                  };

                  if (canUpdateUsername && nameController.text.trim() != userData['username']) {
                    updates['username'] = nameController.text.trim();
                    updates['lastUsernameUpdate'] = FieldValue.serverTimestamp(); 
                  }

                  await _firestore.collection('users').doc(_auth.currentUser!.uid).update(updates);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text("Save Changes", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    return Scaffold(
      backgroundColor: backgroundGreen,
      appBar: AppBar(
        backgroundColor: backgroundGreen,
        elevation: 0,
        surfaceTintColor: Colors.transparent, // Material 3 tint remove
        systemOverlayStyle: SystemUiOverlayStyle.light, // RED BOX FIX: Status bar ko clean/light karega
        automaticallyImplyLeading: false, 
        title: null,
        //   stream: _firestore.collection('users').doc(currentUser?.uid).snapshots(),
        //   builder: (context, snapshot) {
        //     int views = 0;
        //     if (snapshot.hasData && snapshot.data!.exists) {
        //       // SAFE FIX YAHAN ADD HUA HAI
        //       var dataMap = snapshot.data!.data() as Map<String, dynamic>?;
        //       views = dataMap?['profileViews'] ?? 0; 
        //     }
        //     return Row(
        //       children: [
        //         const Icon(Icons.remove_red_eye_outlined, color: oliveAccent, size: 18),
        //         const SizedBox(width: 5),
        //         Text("$views Views", style: const TextStyle(color: oliveAccent, fontSize: 13, fontWeight: FontWeight.bold)),
        //       ],
        //     );
        //   },
        // ),
        actions: [
          StreamBuilder<DocumentSnapshot>(
            stream: _firestore.collection('users').doc(currentUser?.uid).snapshots(),
            builder: (context, snapshot) {
              int views = 0;
              if (snapshot.hasData && snapshot.data!.exists) {
                var dataMap = snapshot.data!.data() as Map<String, dynamic>?;
                views = dataMap?['profileViews'] ?? 0; 
              }
              return TextButton.icon(
                onPressed: () {
                  // Click karne par visitors ki list khulegi
                  _navigateToList(context, "Profile Visitors", "profile_visitors"); 
                },
                icon: const Icon(Icons.remove_red_eye_outlined, color: oliveAccent, size: 20),
                label: Text(
                  "$views Views", 
                  style: const TextStyle(color: oliveAccent, fontSize: 13, fontWeight: FontWeight.bold)
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  foregroundColor: oliveAccent, // Touch ripple color
                ),
              );
            },
          ),
          // --- SETTINGS BUTTON ---
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // Settings screen pe jane ka code
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('users').doc(currentUser?.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: oliveAccent));
          if (!snapshot.hasData || !snapshot.data!.exists) return const Center(child: Text("User data not found", style: TextStyle(color: Colors.white)));

          var userData = snapshot.data!.data() as Map<String, dynamic>;
          String imageUrl = userData['profileImageUrl'] ?? '';

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Profile Picture (Clickable)
                GestureDetector(
                  onTap: _updateProfilePicture, 
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: cardGreen,
                        backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                        child: imageUrl.isEmpty ? const Icon(Icons.person, size: 50, color: oliveAccent) : null,
                      ),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, size: 14, color: Colors.black),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                // Username & Gender
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(userData['username'] ?? 'User', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Text(userData['gender'] == "Female" ? "♀" : "♂", style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),

                const SizedBox(height: 4),
                Text(userData['bio'] ?? 'Write a bio...', style: const TextStyle(color: Colors.grey, fontSize: 14)),

                const SizedBox(height: 15),

                // Edit Profile Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: SizedBox(
                    width: double.infinity,
                    height: 35,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey, width: 0.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _showEditProfileModal(context, userData),
                      child: const Text("Edit Profile", style: TextStyle(color: Colors.white, fontSize: 13)),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildClickableStat(context, Icons.door_front_door_outlined, "Rooms", userData['roomsCount'] ?? 0, "rooms_list"),
                    _buildClickableStat(context, Icons.waves, "Vibes", userData['vibesCreated'] ?? 0, "vibes_list"),
                    _buildClickableStat(context, Icons.favorite_border, "Fave", userData['faveCount'] ?? 0, "my_faves_list"),
                    _buildClickableStat(context, Icons.favorite, "Faves", userData['favesReceived'] ?? 0, "favourited_by_list"),
                  ],
                ),

                const SizedBox(height: 30),

                // Personal Info Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Personal Info", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      _buildInfoTile(Icons.language, "Languages", ""), 
                      const SizedBox(height: 10),
                      _buildInfoTile(Icons.calendar_month, "Signup Date", userData['signupDate'] ?? "01-01-2024"),
                      const SizedBox(height: 10),
                      _buildInfoTile(Icons.access_time, "Local Time", DateFormat('hh:mm a').format(DateTime.now())),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _buildInfoTile(Icons.call, "Calls", (userData['totalCalls'] ?? 0).toString())),
                          const SizedBox(width: 10),
                          Expanded(child: _buildInfoTile(Icons.cake, "Age", "${userData['age'] ?? 17} yrs")),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildClickableStat(BuildContext context, IconData icon, String label, int count, String path) {
    return Expanded(
      child: InkWell(
        onTap: () => _navigateToList(context, label, path), 
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Icon(icon, color: oliveAccent, size: 26),
              const SizedBox(height: 5),
              Text(count.toString(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: cardGreen, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: oliveAccent, size: 20),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              if (value.isNotEmpty) Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}