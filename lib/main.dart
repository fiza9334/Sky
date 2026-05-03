import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:firebase_auth/firebase_auth.dart';
// Files check karein
import 'firebase_options.dart';
import 'theme/app_colors.dart';
// import 'package:echoo/api_service.dart'; // Agar use nahi ho raha to ise hata sakte hain

// Screens
import 'screens/auth_screen.dart';
import 'screens/gender_selection_screen.dart';
import 'screens/language_selection_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/age_selection_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/setup_topic_screen.dart';
import 'screens/profile_screen.dart';
Future<void> main() async {
  // 1. Sabse pehle binding ensure karein
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // 2. Environment variables load karna
    await dotenv.load(fileName: ".env");
    debugPrint("Environment loaded ✅");

    // 3. Firebase initialize karna
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("Firebase Connected ✅");
  } catch (e) {
    debugPrint("Initialization Error: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Echoo',
      theme: ThemeData(
        useMaterial3: true, // Modern UI ke liye zaruri hai
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.accent,
        fontFamily: 'Inter', 
      ),
      
      // Starting point: Agar LoginScreen me 'const' hai to yahan bhi 'const' lagayein
      // home: AuthScreen(), //ye sbse important h 
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ProfileScreen(); // Agar logged in hai toh direct ye dikhega
          }
          return AuthScreen(); // Warna login dikhega
          },
          ),
      // Named Routes
      routes: {
        '/login': (context) =>AuthScreen(),
        // '/gender_selection': (context) => const GenderSelectionScreen(),
        '/language_selection': (context) => const LanguageSelectionScreen(),
        '/setup_topic_screen': (context) => const SetupTopicScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}

