import 'package:share_plus/share_plus.dart';
import '../models/vibe_model.dart';

class ShareService {
  static Future<void> shareVibe(VibeModel vibe) async {
    // Generate a shareable link (You can replace this with Firebase Dynamic Links later)
    String shareLink = "https://yourapp.com/vibe/${vibe.id}";
    String shareText = "Check out this vibe by ${vibe.username}!\n\n\"${vibe.content}\"\n\n$shareLink";

    // Launch native share sheet
    await Share.share(shareText, subject: 'Shared from Vibes App');
  }
}