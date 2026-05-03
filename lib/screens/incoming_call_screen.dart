// Required dependencies in pubspec.yaml:
// audioplayers: ^5.2.1
// vibration: ^1.8.3
// 
// Android Permissions (AndroidManifest.xml):
// <uses-permission android:name="android.permission.VIBRATE"/>
// <uses-permission android:name="android.permission.RECORD_AUDIO" />

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

class AppColors {
  static const Color darkJungle = Color(0xFF1A2421);
  static const Color softGlowingOlive = Color(0xFF8A9A5B);
  static const Color mutedGold = Color(0xFFC5A059);
  static const Color rejectRed = Color(0xFF8C3A3A);
  static const Color backgroundLight = Color(0xFFF5F6F2);
}

class IncomingCallScreen extends StatefulWidget {
  final String callerName;
  final String callerAvatarUrl;
  final String callType; // 'Audio' or 'Video'

  const IncomingCallScreen({
    super.key,
    required this.callerName,
    this.callerAvatarUrl = 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?auto=format&fit=crop&w=150&q=80',
    this.callType = 'Audio',
  });

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _timeoutTimer;
  bool _isMissedCall = false;

  @override
  void initState() {
    super.initState();
    _startRingtoneAndVibration();
    _startCallTimeout();
  }

  @override
  void dispose() {
    _stopRingtoneAndVibration();
    super.dispose();
  }

  Future<void> _startRingtoneAndVibration() async {
    try {
      // Set audio to loop continuously
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      // Play your local ringtone asset (ensure it is added in pubspec.yaml)
      await _audioPlayer.play(AssetSource('audio/echoo_ringtone.mp3'));
    } catch (e) {
      debugPrint("Error playing ringtone: $e");
    }

    try {
      bool? hasVibrator = await Vibration.hasVibrator();
      bool? hasCustomVibrationsSupport = await Vibration.hasCustomVibrationsSupport();
      
      if (hasVibrator == true) {
        if (hasCustomVibrationsSupport == true) {
          // Pattern: [wait 0ms, vibrate 1000ms, wait 1000ms], repeat from index 1
          Vibration.vibrate(pattern: [0, 1000, 1000], repeat: 1);
        } else {
          Vibration.vibrate();
        }
      }
    } catch (e) {
      debugPrint("Error starting vibration: $e");
    }
  }

  Future<void> _stopRingtoneAndVibration() async {
    await _audioPlayer.stop();
    await _audioPlayer.dispose();
    Vibration.cancel();
    _timeoutTimer?.cancel();
  }

  void _startCallTimeout() {
    // Auto stop after 30 seconds
    _timeoutTimer = Timer(const Duration(seconds: 30), () {
      if (mounted) {
        setState(() {
          _isMissedCall = true;
        });
        _stopRingtoneAndVibration();
        
        // Auto close the screen after showing "Missed Call" for 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) Navigator.pop(context, 'missed');
        });
      }
    });
  }

  void _acceptCall() {
    _stopRingtoneAndVibration();
    // Navigate to actual Agora Call Screen
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AgoraCallScreen()));
    Navigator.pop(context, 'accepted');
  }

  void _rejectCall() {
    _stopRingtoneAndVibration();
    Navigator.pop(context, 'rejected');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkJungle,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Top Section: Caller Info
            Column(
              children: [
                const SizedBox(height: 40),
                Text(
                  _isMissedCall ? "Missed Call" : "Incoming ${widget.callType} Call...",
                  style: TextStyle(
                    color: _isMissedCall ? AppColors.rejectRed : AppColors.mutedGold,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.softGlowingOlive,
                      width: 3,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 70,
                    backgroundImage: NetworkImage(widget.callerAvatarUrl),
                    backgroundColor: AppColors.darkJungle,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.callerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Echoo Audio",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            // Bottom Section: Actions
            if (!_isMissedCall)
              Padding(
                padding: const EdgeInsets.only(bottom: 60.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Reject Button
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: _rejectCall,
                          child: Container(
                            height: 75,
                            width: 75,
                            decoration: const BoxDecoration(
                              color: AppColors.rejectRed,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                )
                              ],
                            ),
                            child: const Icon(
                              Icons.call_end,
                              color: Colors.white,
                              size: 35,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Decline",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    // Accept Button
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: _acceptCall,
                          child: Container(
                            height: 75,
                            width: 75,
                            decoration: const BoxDecoration(
                              color: AppColors.softGlowingOlive,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                )
                              ],
                            ),
                            child: const Icon(
                              Icons.call,
                              color: Colors.white,
                              size: 35,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Accept",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}