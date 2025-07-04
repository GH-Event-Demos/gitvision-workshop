import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/coding_mood.dart';

class SocialSharingService {
  static final SocialSharingService _instance =
      SocialSharingService._internal();
  factory SocialSharingService() => _instance;
  SocialSharingService._internal();

  /// Share playlist to a specific platform
  Future<bool> sharePlaylist({
    required Map<String, dynamic> playlistData,
    required String githubHandle,
    required String platform,
  }) async {
    final playlist = playlistData['playlist'] as Map<String, dynamic>;
    final CodingMood mood = CodingMood.fromString(playlist['mood'] as String);

    // Generate message
    final message =
        'My coding vibe today: ${mood.description}! Generated with GitVision from my GitHub commits (@$githubHandle)!';
    final appUrl = 'https://gitvision.dev?mood=${mood.name}';

    return await _shareToUrl(platform, message, appUrl);
  }

  /// Handle platform-specific sharing
  Future<bool> _shareToUrl(
      String platform, String message, String appUrl) async {
    try {
      String? shareUrl;

      switch (platform.toLowerCase()) {
        case 'twitter':
          shareUrl =
              'https://twitter.com/intent/tweet?text=${Uri.encodeComponent(message)}&url=${Uri.encodeComponent(appUrl)}';
          break;
        case 'facebook':
          shareUrl =
              'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(appUrl)}&quote=${Uri.encodeComponent(message)}';
          break;
        case 'linkedin':
          shareUrl =
              'https://www.linkedin.com/shareArticle?mini=true&url=${Uri.encodeComponent(appUrl)}&title=My%20Coding%20Vibe&summary=${Uri.encodeComponent(message)}';
          break;
        case 'reddit':
          final title = 'My Coding Vibe (from GitVision)';
          shareUrl =
              'https://www.reddit.com/submit?url=${Uri.encodeComponent(appUrl)}&title=${Uri.encodeComponent(title)}&text=${Uri.encodeComponent(message)}';
          break;
        case 'instagram':
        case 'clipboard':
          await Clipboard.setData(ClipboardData(text: '$message $appUrl'));
          return true;
        case 'general':
          await Clipboard.setData(ClipboardData(text: '$message $appUrl'));
          return true;
        default:
          return false;
      }

      // Launch URL for social platforms
      if (await canLaunchUrl(Uri.parse(shareUrl))) {
        await launchUrl(Uri.parse(shareUrl),
            mode: LaunchMode.externalApplication);
        return true;
      }
      return false;
    } catch (e) {
      print('Error sharing to $platform: $e');
      return false;
    }
  }
}
