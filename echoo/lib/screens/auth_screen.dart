import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'otp_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true; // Toggle state
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  void _sendOtp() async {
    String phone = _phoneController.text.trim();
    if (phone.isEmpty || !phone.startsWith('+')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter number with country code (e.g. +91)")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      ConfirmationResult result = await FirebaseAuth.instance.signInWithPhoneNumber(phone);
      if (mounted) {
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => OtpScreen(confirmationResult: result))
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              // App Branding
              const Text("Echoo", 
                style: TextStyle(color: Color(0xFFC5A059), fontSize: 40, fontWeight: FontWeight.bold, letterSpacing: 1.5)
              ),
              const SizedBox(height: 40),

              // Sign In / Sign Up Toggle
              Row(
                children: [
                  _buildTabOption("Sign In", isLogin, () => setState(() => isLogin = true)),
                  const SizedBox(width: 30),
                  _buildTabOption("Sign Up", !isLogin, () => setState(() => isLogin = false)),
                ],
              ),
              
              const SizedBox(height: 40),
              Text(
                isLogin ? "Welcome back! Login to your account." : "Create a new account to join the community.",
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              
              const SizedBox(height: 30),
              // Phone Input field
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  hintText: "+91 00000 00000",
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: const Color(0xFF383838),
                  prefixIcon: const Icon(Icons.phone_iphone, color: Color(0xFF8A9A5B)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
              ),
              
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8A9A5B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(isLogin ? "Sign In" : "Sign Up", 
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              
              const SizedBox(height: 20),
              const Center(
                child: Text("By continuing, you agree to our Terms of Service", 
                  style: TextStyle(color: Colors.white24, fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget for Tabs
  Widget _buildTabOption(String title, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, 
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white24, 
              fontSize: 22, 
              fontWeight: FontWeight.bold
            )
          ),
          const SizedBox(height: 4),
          if (isSelected)
            Container(height: 3, width: 40, color: const Color(0xFFC5A059)), // Gold underline
        ],
      ),
    );
  }
}