import 'package:flutter/material.dart';
import 'social/social_screen.dart'; 
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  // Aapki screens ki list
  final List<Widget> _screens = [
    const _VibesScreenStub(), 
    const SocialScreen(),     
    const ProfileScreen(),  
  ];

  @override
  Widget build(BuildContext context) {
    const Color jungleGreen = Color(0xFF141A14);
    const Color oliveAccent = Color(0xFFA5B880);

    // 1. PopScope ko yahan sabse upar rakha hai taaki pura Dashboard lock ho jaye
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0, // AppBar ki height 0 kar di taaki dikhe nahi
          elevation: 0,
          automaticallyImplyLeading: false, // Back option block
    ),
      // canPop: false, // Hardware back button disable ho gaya
      // onPopInvokedWithResult: (didPop, result) {
      //   if (didPop) return;
      //   // Agar aap chahte hain ki back dabane par app band na ho, toh ise aise hi rehne dein
      // },
      // child: Scaffold(
      //   backgroundColor: jungleGreen, 
        
        // 2. Body mein aapka current screen dikhega
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        
        bottomNavigationBar: NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: oliveAccent.withOpacity(0.2),
            labelTextStyle: WidgetStateProperty.all(
              const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          child: NavigationBar(
            backgroundColor: Colors.black,
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.waves_outlined, color: Colors.grey),
                selectedIcon: Icon(Icons.waves, color: oliveAccent),
                label: 'Vibes',
              ),
              NavigationDestination(
                icon: Icon(Icons.groups_outlined, color: Colors.grey),
                selectedIcon: Icon(Icons.groups, color: oliveAccent),
                label: 'Social',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline, color: Colors.grey),
                selectedIcon: Icon(Icons.person, color: oliveAccent),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Vibes ke liye temporary stub
class _VibesScreenStub extends StatelessWidget {
  const _VibesScreenStub();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Text(
          "Vibes Screen Coming Soon...",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}