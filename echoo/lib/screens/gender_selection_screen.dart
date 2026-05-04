// --- lib/screens/gender_selection_screen.dart ---
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'profile_setup_screen.dart';

class GenderSelectionScreen extends StatefulWidget {
  const GenderSelectionScreen({super.key});

  @override
  State<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  String? _selectedGender;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkJungle : AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text("What's your gender?", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.darkJungle)),
              const SizedBox(height: 40),
              _buildGenderCard("Male", Icons.male, isDark),
              const SizedBox(height: 16),
              _buildGenderCard("Female", Icons.female, isDark),
              const SizedBox(height: 16),
              _buildGenderCard("Other", Icons.transgender, isDark),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedGender == null ? null : () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileSetupScreen(gender: _selectedGender!)));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.softGlowingOlive,
                    disabledBackgroundColor: Colors.grey[700],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text("Continue", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderCard(String gender, IconData icon, bool isDark) {
    bool isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = gender),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.softGlowingOlive.withOpacity(0.2) : (isDark ? Colors.grey[900] : Colors.white),
          border: Border.all(color: isSelected ? AppColors.softGlowingOlive : Colors.transparent, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const SizedBox(width: 24),
            Icon(icon, size: 32, color: isSelected ? AppColors.softGlowingOlive : (isDark ? Colors.white : Colors.black87)),
            const SizedBox(width: 20),
            Text(gender, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isSelected ? AppColors.softGlowingOlive : (isDark ? Colors.white : Colors.black87))),
          ],
        ),
      ),
    );
  }
}