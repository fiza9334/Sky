// // --- lib/screens/age_selection_screen.dart ---
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import '../theme/app_colors.dart';
// import 'dashboard_screen.dart';

// class AgeSelectionScreen extends StatefulWidget {
//   final String gender;
//   final String username;
//   final File? imageFile;

//   const AgeSelectionScreen({super.key, required this.gender, required this.username, this.imageFile});

//   @override
//   State<AgeSelectionScreen> createState() => _AgeSelectionScreenState();
// }

// class _AgeSelectionScreenState extends State<AgeSelectionScreen> {
//   double _age = 22;
//   bool _isLoading = false;

//   Future<void> _completeProfile() async {
//     setState(() => _isLoading = true);
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) return;

//       String imageUrl = '';
//       if (widget.imageFile != null) {
//         final ref = FirebaseStorage.instance.ref().child('profile_pics/${user.uid}.jpg');
//         await ref.putFile(widget.imageFile!);
//         imageUrl = await ref.getDownloadURL();
//       }

//       await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
//         'phone': user.phoneNumber ?? '',
//         'email': user.email ?? '',
//         'username': widget.username,
//         'profilePic': imageUrl,
//         'gender': widget.gender,
//         'age': _age.toInt(),
//         'createdAt': FieldValue.serverTimestamp(),
//       }, SetOptions(merge: true));

//       if (mounted) {
//         Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const DashboardScreen()), (route) => false);
//       }
//     } catch (e) {
//       setState(() => _isLoading = false);
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving profile: $e')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       backgroundColor: isDark ? AppColors.darkJungle : AppColors.backgroundLight,
//       appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text("How old are you?", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.darkJungle)),
//               const SizedBox(height: 80),
//               Center(
//                 child: Text(_age.toInt().toString(), style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: AppColors.softGlowingOlive)),
//               ),
//               const SizedBox(height: 40),
//               Slider(
//                 value: _age,
//                 min: 13,
//                 max: 100,
//                 activeColor: AppColors.softGlowingOlive,
//                 inactiveColor: isDark ? Colors.grey[800] : Colors.grey[300],
//                 onChanged: (val) => setState(() => _age = val),
//               ),
//               const Spacer(),
//               SizedBox(
//                 width: double.infinity,
//                 height: 56,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _completeProfile,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.softGlowingOlive,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                   ),
//                   child: _isLoading
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : const Text("Complete", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
//                 ),
//               ),
//               const SizedBox(height: 30),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../theme/app_colors.dart';
import 'dashboard_screen.dart';

class AgeSelectionScreen extends StatefulWidget {
  final String gender;
  final String username;
  final File? imageFile;

  const AgeSelectionScreen({
    super.key, 
    required this.gender, 
    required this.username, 
    this.imageFile
  });

  @override
  State<AgeSelectionScreen> createState() => _AgeSelectionScreenState();
}

class _AgeSelectionScreenState extends State<AgeSelectionScreen> {
  double _age = 22.0;
  bool _isLoading = false;

  Future<void> _completeProfile() async {
    setState(() => _isLoading = true);
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User session expired. Please login again.");
      }

      String imageUrl = '';
      
      // Professional way to handle image upload
      if (widget.imageFile != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_pics/${user.uid}.jpg');
        
        // Metadata add karna professional practice hai
        final uploadTask = await storageRef.putFile(
          widget.imageFile!,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        
        imageUrl = await uploadTask.ref.getDownloadURL();
      }

      // Firestore Update
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'phone': user.phoneNumber ?? '',
        'email': user.email ?? '',
        'username': widget.username,
        'profilePic': imageUrl,
        'gender': widget.gender,
        'age': _age.toInt(),
        'isProfileCompleted': true, // Feature gate ke liye useful hai
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        // Saari previous screens clear karke Dashboard par bhejna
        Navigator.pushAndRemoveUntil(
          context, 
          MaterialPageRoute(builder: (_) => const DashboardScreen()), 
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkJungle : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              SizedBox(height: size.height * 0.02),
              Text(
                "How old are you?",
                style: TextStyle(
                  fontSize: 32, 
                  fontWeight: FontWeight.bold, 
                  color: isDark ? Colors.white : AppColors.darkJungle,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Select your age to help us find the best\ncommunity for you.",
                style: TextStyle(
                  fontSize: 16, 
                  color: isDark ? Colors.white60 : Colors.black54,
                  height: 1.5,
                ),
              ),

              const Spacer(flex: 1), // Dynamic spacing

              // Age Display
              Center(
                child: Column(
                  children: [
                    Text(
                      _age.toInt().toString(),
                      style: const TextStyle(
                        fontSize: 100, // Thoda bada size for emphasis
                        fontWeight: FontWeight.bold,
                        color: AppColors.softGlowingOlive,
                        letterSpacing: -2,
                      ),
                    ),
                    const Text(
                      "YEARS OLD",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 4,
                        color: AppColors.mutedGold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Responsive Slider
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
                ),
                child: Slider(
                  value: _age,
                  min: 13,
                  max: 100,
                  activeColor: AppColors.softGlowingOlive,
                  inactiveColor: isDark ? Colors.white10 : Colors.black12,
                  onChanged: (val) => setState(() => _age = val),
                ),
              ),

              const Spacer(flex: 2), // Neeche zyada space balance ke liye

              // Action Button
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _completeProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.softGlowingOlive,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Complete Profile",
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}