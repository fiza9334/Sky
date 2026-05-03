import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'gender_selection_screen.dart';

class OtpScreen extends StatefulWidget {
  final ConfirmationResult confirmationResult; // Verification handler

  const OtpScreen({super.key, required this.confirmationResult});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  void _verifyOtp() async {
    if (_otpController.text.length < 6) return;

    setState(() => _isLoading = true);

    try {
      // Real verification check
      UserCredential userCredential = await widget.confirmationResult.confirm(_otpController.text);
      
      if (userCredential.user != null && mounted) {
        // Success! User is now officially logged in
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GenderSelectionScreen()),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid OTP! Try again.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Verify OTP", style: TextStyle(color: Colors.white, fontSize: 24)),
              const SizedBox(height: 20),
              TextField(
                controller: _otpController,
                maxLength: 6,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 10),
                decoration: const InputDecoration(counterText: ""),
              ),
              const SizedBox(height: 20),
              _isLoading 
                ? const CircularProgressIndicator() 
                : ElevatedButton(onPressed: _verifyOtp, child: const Text("Verify & Continue")),
            ],
          ),
        ),
      ),
    );
  }
}