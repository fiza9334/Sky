import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';
import 'dashboard_screen.dart';

class SetupTopicScreen extends StatefulWidget {
  const SetupTopicScreen({super.key});

  @override
  State<SetupTopicScreen> createState() => _SetupTopicScreenState();
}

class _SetupTopicScreenState extends State<SetupTopicScreen> {
  final List<String> _topics = [
    "🎵 Music", "🎮 Gaming", "⚽ Sports", "🎬 Movies",
    "💻 Tech", "🎨 Art", "⛩️ Anime", "💪 Fitness",
    "🍳 Cooking", "📈 Business", "🚗 Cars", "📸 Photo"
  ];

  final List<String> _selectedTopics = [];
  bool _isLoading = false; // Loading state add kiya

  void _onTopicTap(String topic) {
    setState(() {
      if (_selectedTopics.contains(topic)) {
        _selectedTopics.remove(topic);
      } else {
        _selectedTopics.add(topic);
      }
    });
  }

  // Database mein save karne ka naya function

  // Database mein save karne ka naya function
  Future<void> _saveVibesAndProceed() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      // User document mein topics list save kar rahe hain
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'interests': _selectedTopics,
        'setupComplete': true, 
      }, SetOptions(merge: true));

      if (mounted) {
        // --- NAVIGATION CHANGE HERE ---
        // Yeh line history clear karke Dashboard par bhej degi
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
          (route) => false, // Isse back jane ka option khatam ho jayega
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving interests: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }



  // Future<void> _saveVibesAndProceed() async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user == null) return;

  //   setState(() => _isLoading = true);

  //   try {
  //     // User document mein topics list save kar rahe hain
  //     await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
  //       'interests': _selectedTopics,
  //       'setupComplete': true, // Taaki dobara setup na dikhana pade
  //     }, SetOptions(merge: true));

  //     if (mounted) {
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => const DashboardScreen()),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error saving interests: $e')),
  //     );
  //   } finally {
  //     if (mounted) setState(() => _isLoading = false);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    bool canProceed = _selectedTopics.length >= 3;

    return Scaffold(
      backgroundColor: Colors.black, // Background color consistent rakha
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                "Pick Your Vibes",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.accent),
              ),
              const SizedBox(height: 8),
              Text(
                "Select at least 3 topics (${_selectedTopics.length} selected)",
                style: const TextStyle(color: Colors.white60, fontSize: 16),
              ),
              const SizedBox(height: 30),

              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _topics.map((topic) {
                      bool isSelected = _selectedTopics.contains(topic);
                      return GestureDetector(
                        onTap: () => _onTopicTap(topic),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.accent : AppColors.card,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: isSelected ? Colors.white30 : Colors.white10,
                            ),
                          ),
                          child: Text(
                            topic,
                            style: TextStyle(
                              color: isSelected ? AppColors.background : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Finish Button with Loader
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: _isLoading 
                    ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canProceed ? AppColors.accent : Colors.white10,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        onPressed: canProceed ? _saveVibesAndProceed : null,
                        child: Text(
                          canProceed ? "Let's Go!" : "Select ${3 - _selectedTopics.length} more",
                          style: TextStyle(
                            color: canProceed ? AppColors.background : Colors.white24,
                            fontWeight: FontWeight.bold,
                            fontSize: 18
                          ),
                        ),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}