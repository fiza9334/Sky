// import 'package:flutter/material.dart';
// import '../theme/app_colors.dart';

// class LanguageSelectionScreen extends StatefulWidget {
//   // Add kiya const constructor taaki main.dart mein error na aaye
//   const LanguageSelectionScreen({super.key});

//   @override
//   State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
// }

// class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
//   final List<String> allLanguages = ["Hindi", "English", "Spanish", "French", "German", "Arabic"];
  
//   String? preferredLanguage; 
//   List<String> spokenLanguages = []; 

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background, 
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: const Text("Preferences", style: TextStyle(color: Colors.white)),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text("Preferred Language (Select 1)", 
//               style: TextStyle(color: AppColors.accent, fontSize: 18, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 10),
//             Wrap(
//               spacing: 10,
//               children: allLanguages.map((lang) {
//                 bool isSelected = preferredLanguage == lang;
//                 return ChoiceChip(
//                   label: Text(lang),
//                   selected: isSelected,
//                   onSelected: (val) => setState(() => preferredLanguage = lang),
//                   selectedColor: AppColors.accent,
//                   backgroundColor: AppColors.card,
//                   labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white),
//                 );
//               }).toList(),
//             ),

//             const SizedBox(height: 30),

//             const Text("Languages I Speak (At least 1)", 
//               style: TextStyle(color: AppColors.accent, fontSize: 18, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 10),
//             Container(
//               decoration: BoxDecoration(
//                 color: AppColors.card,
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               child: Column(
//                 children: allLanguages.map((lang) {
//                   return CheckboxListTile(
//                     title: Text(lang, style: const TextStyle(color: Colors.white)),
//                     value: spokenLanguages.contains(lang),
//                     activeColor: AppColors.accent,
//                     checkColor: Colors.black,
//                     onChanged: (bool? checked) {
//                       setState(() {
//                         if (checked!) {
//                           spokenLanguages.add(lang);
//                         } else {
//                           if (spokenLanguages.length > 1) {
//                             spokenLanguages.remove(lang);
//                           }
//                         }
//                       });
//                     },
//                   );
//                 }).toList(),
//               ),
//             ),

//             const SizedBox(height: 40),

//             SizedBox(
//               width: double.infinity,
//               height: 55,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: (preferredLanguage != null && spokenLanguages.isNotEmpty)
//                       ? AppColors.accent
//                       : Colors.grey,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//                 onPressed: (preferredLanguage != null && spokenLanguages.isNotEmpty)
//                     ? () {
//                         // Abhi ke liye seedha Dashboard par bhejte hain
//                         // Jab tum Profile Pic screen banaoge, tab '/profile_pic_setup' kar dena
//                         Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
//                       }
//                     : null,
//                 child: const Text("Continue", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  // Private variables banaye hain (_ lagakar) jo best practice hai
  final List<String> _allLanguages = [
    "Hindi", "English", "Spanish", "French", "German", "Arabic"
  ];
  
  String? _preferredLanguage; 
  final List<String> _spokenLanguages = []; 

  bool get _canContinue => _preferredLanguage != null && _spokenLanguages.isNotEmpty;

  void _handleContinue() {
    // Abhi ke liye seedha Dashboard par bhejte hain
    Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkJungle : AppColors.backgroundLight, 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Preferences", 
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("Preferred Language", "Select 1"),
              SizedBox(height: size.height * 0.02),
              _buildPreferredLanguageChips(isDark),

              SizedBox(height: size.height * 0.05),

              _buildSectionHeader("Languages I Speak", "At least 1"),
              SizedBox(height: size.height * 0.02),
              _buildSpokenLanguagesList(isDark),

              SizedBox(height: size.height * 0.06),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  // Agar onPressed null hota hai, toh Flutter auto-disable (grey) kar deta hai
                  onPressed: _canContinue ? _handleContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.softGlowingOlive,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: isDark ? Colors.white10 : Colors.black12,
                    disabledForegroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Continue", 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI HELPER METHODS (For Clean Architecture) ---

  Widget _buildSectionHeader(String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          title, 
          style: const TextStyle(
            color: AppColors.softGlowingOlive, 
            fontSize: 20, 
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          "($subtitle)", 
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildPreferredLanguageChips(bool isDark) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _allLanguages.map((lang) {
        final isSelected = _preferredLanguage == lang;
        return ChoiceChip(
          label: Text(lang),
          selected: isSelected,
          onSelected: (val) {
            setState(() => _preferredLanguage = val ? lang : null);
          },
          selectedColor: AppColors.softGlowingOlive,
          backgroundColor: isDark ? Colors.white10 : Colors.black12,
          labelStyle: TextStyle(
            color: isSelected 
                ? Colors.white 
                : (isDark ? Colors.white70 : Colors.black87),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected ? AppColors.softGlowingOlive : Colors.transparent,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSpokenLanguagesList(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        children: _allLanguages.map((lang) {
          final isSelected = _spokenLanguages.contains(lang);
          return CheckboxListTile(
            title: Text(
              lang, 
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            value: isSelected,
            activeColor: AppColors.softGlowingOlive,
            checkColor: Colors.white,
            side: BorderSide(color: isDark ? Colors.white54 : Colors.black54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            onChanged: (bool? checked) {
              setState(() {
                if (checked == true) {
                  _spokenLanguages.add(lang);
                } else {
                  // Aapka logic: at least 1 rehna chahiye agar remove kar rahe hain
                  if (_spokenLanguages.length > 1) {
                    _spokenLanguages.remove(lang);
                  } else if (_spokenLanguages.length == 1) {
                    _spokenLanguages.remove(lang); // Better UX: allow empty, button will disable
                  }
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }
}