import 'package:flutter/material.dart';


class AppColors {
  // Base
  static const Color background = Color(0xFF141A14); // Deepest Jungle Green / Charcoal
  static const Color card = Color(0xFF1E261E);       // Dark Olive Tint
  
  // Accents
  static const Color accent = Color(0xFFA5B880);     // Soft Glowing Olive / Pistachio
  static const Color accentSecondary = Color(0xFFD4AF37); // Muted Gold (Perfect for premium clubs)
  
  // States
  static const Color success = Color(0xFF4C9F70);    // Fresh Green
  static const Color error = Color(0xFFD9534F);      // Muted Brick Red
  
  // Text
  static const Color textMain = Color(0xFFE5E8E1);   // Sage White
  static const Color textMuted = Color(0xFF8B938A);  // Mossy Grey



  static const Color darkJungle = Color(0xFF1A2421);
  static const Color softGlowingOlive = Color(0xFF8A9A5B);
  static const Color mutedGold = Color(0xFFC5A059);
  static const Color backgroundLight = Color(0xFFF5F6F2);
  static const Color errorRed = Color(0xFF8C3A3A);

  
}

class AppTheme {
  // Cleaned up Light Theme to match the Olive aesthetic
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF4A5D23),     // Deep Olive Green
      secondary: Color(0xFFC48B5D),   // Terracotta / Clay
      surface: Color(0xFFF6F7F2),     // Warm Cream
      onSurface: Color(0xFF1B1E19),   // Near Black with Olive undertone
      error: Color(0xFFC62828),       // Deep Crimson
    ),
    scaffoldBackgroundColor: const Color(0xFFF6F7F2),
    cardTheme: CardThemeData(
      color: const Color(0xFFEBEDE4), // Light Sage / Soft Olive
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFFD3D6CB)), // Subtle sage border
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );

  // Corrected Dark Theme using your exact AppColors
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      secondary: AppColors.accentSecondary, // Fixed from slate blue
      surface: AppColors.background,        // Fixed from random purple
      onSurface: AppColors.textMain,
      surfaceContainer: AppColors.card,
      error: AppColors.error,               // Fixed to your muted red
    ),
    scaffoldBackgroundColor: AppColors.background,
    cardTheme: CardThemeData(
      color: AppColors.card,                // Fixed from random purple
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFF2A332A)), // Subtle olive border 
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
