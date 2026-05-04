import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Naya import
import 'dashboard_screen.dart'; 

class ProfileSetupScreen extends StatefulWidget {
  final String gender; 

  const ProfileSetupScreen({super.key, required this.gender});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  
  Uint8List? _profileImageBytes;
  DateTime? _selectedDate;
  int? _calculatedAge;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance; // Storage instance

  // 1. Pick Image (Web & Mobile Compatible)
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, 
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _profileImageBytes = bytes;
      });
    }
  }

  // 2. Select Date of Birth & Calculate Age
  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: const Color(0xFFA5B880), // Olive Accent
              onPrimary: Colors.black,
              surface: const Color(0xFF141A14), // Deep Jungle Green
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _calculateAge(picked);
      });
    }
  }

  void _calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    if (currentDate.month < birthDate.month || 
        (currentDate.month == birthDate.month && currentDate.day < birthDate.day)) {
      age--;
    }
    setState(() {
      _calculatedAge = age;
    });
  }






//   Future<void> _saveProfile() async {
//   print("STEP 1: Button Clicked");
//   final User? currentUser = _auth.currentUser;
  
//   if (currentUser == null) {
//     print("ERROR: User session null hai!");
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('User session not found.')),
//     );
//     return;
//   }

//   setState(() {
//     _isLoading = true;
//   });
  
//   print("STEP 2: Loading start ho gayi. UID: ${currentUser.uid}");

//   try {
//     String uid = currentUser.uid;

//     // 🚨 IMAGE UPLOAD PURI TARAH COMMENT KAR DIYA HAI 🚨
//     // Abhi ke liye hum Storage ko touch hi nahi karenge.
//     print("STEP 3: Firestore mein data save karne ki koshish kar rahe hain...");

//     await _firestore.collection('users').doc(uid).set({
//       'username': _usernameController.text.trim(),
//       'bio': _bioController.text.trim(),
//       'dateOfBirth': _selectedDate?.toIso8601String(),
//       'age': _calculatedAge,
//       'gender': widget.gender,
//       'profileImageUrl': "", // Khali chhod diya
//       'createdAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true))
//     .timeout(const Duration(seconds: 5), onTimeout: () {
//       // Agar 5 second mein save nahi hua toh zabardasti error throw karega
//       throw Exception("Firestore request TIME OUT ho gayi! Rules ya Internet issue hai.");
//     });

//     print("STEP 4: Firestore save SUCCESS!");

//     if (mounted) {
//       print("STEP 5: Dashboard ki taraf ja rahe hain...");
//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (context) => const DashboardScreen()),
//         (route) => false,
//       );
//     }
//   } catch (e) {
//     print("🚨 CATCH ERROR: Yahan code fasa -> $e");
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Error: $e')),
//     );
//   } finally {
//     print("STEP 6: Finally block chal gaya, loading band.");
//     if (mounted) {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
// }





  // 3. Save Profile with Image Upload Fix
  Future<void> _saveProfile() async {
    final User? currentUser = _auth.currentUser;
    
    if (currentUser == null) {
      _showSnackBar('User session not found. Please login again.');
      return;
    }

    // if (_usernameController.text.trim().isEmpty || _selectedDate == null) {
    //   _showSnackBar('Please fill all required fields');
    //   return;
    // }

    setState(() =>_isLoading = true);

    try {
      String uid = currentUser.uid;
      String? imageUrl;

      if (_profileImageBytes != null) {
      try {
        Reference ref = _storage.ref().child('user_profiles').child('$uid.jpg');
        UploadTask uploadTask = ref.putData(_profileImageBytes!);
        TaskSnapshot snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
      } catch (storageError) {
        // Agar Storage upgrade maange toh error print karein aur aage badhein
        print("Storage Error (Upgrade needed?): $storageError");
      }
    }

      // --- IMAGE UPLOAD LOGIC ---
/*      if (_profileImageBytes != null) {
        Reference ref = _storage.ref().child('user_profiles').child('$uid.jpg');
        
        // Metadata set karna achha rehta hai
        SettableMetadata metadata = SettableMetadata(contentType: 'image/jpeg');
        
        UploadTask uploadTask = ref.putData(_profileImageBytes!, metadata);
        TaskSnapshot snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
      }
*/


      // --- FIRESTORE SAVE LOGIC ---
      await _firestore.collection('users').doc(uid).set({
        'username': _usernameController.text.trim(),
        'bio': _bioController.text.trim(),
        'dateOfBirth': _selectedDate?.toIso8601String(),
        'age': _calculatedAge,
        'gender': widget.gender,
        'profileImageUrl': imageUrl ?? "", // Image URL save ho raha hai
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    } catch (e) {
      _showSnackBar('Error saving profile: $e');
      print("Firebase Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    // Theme colors using your Earthy Minimalist palette
    final Color primaryDark = const Color(0xFF141A14); 
    final Color accentOlive = const Color(0xFFA5B880);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Setup Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: primaryDark,
                        backgroundImage: _profileImageBytes != null 
                            ? MemoryImage(_profileImageBytes!) 
                            : null,
                        child: _profileImageBytes == null
                            ? Icon(Icons.person, size: 60, color: accentOlive)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: CircleAvatar(
                          backgroundColor: accentOlive,
                          radius: 18,
                          child: const Icon(Icons.camera_alt, size: 18, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Center(child: Text('Tap to add photo', style: TextStyle(color: Colors.grey))),
              const SizedBox(height: 32),
              
              // Username Field
              TextField(
                controller: _usernameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Username *',
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: primaryDark,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: accentOlive),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // DOB and Age Row
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: _selectDateOfBirth,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        decoration: BoxDecoration(
                          color: primaryDark,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _selectedDate == null 
                              ? 'Date of Birth *' 
                              : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                          style: TextStyle(color: _selectedDate == null ? Colors.grey : Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      decoration: BoxDecoration(
                        color: primaryDark,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          _calculatedAge == null ? 'Age' : '$_calculatedAge yrs',
                          style: TextStyle(
                            color: _calculatedAge == null ? Colors.grey : accentOlive,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Bio Field
              TextField(
                controller: _bioController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Short Bio (Optional)',
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: primaryDark,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: accentOlive),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              
              // Submit Button
              _isLoading
                  ? Center(child: CircularProgressIndicator(color: accentOlive))
                  : ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentOlive,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Complete Setup',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}