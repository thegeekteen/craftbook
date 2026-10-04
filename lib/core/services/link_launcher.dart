import 'package:url_launcher/url_launcher.dart';

/// Opens a web address in the phone's browser or the matching app. The one
/// place the app hands anything to the outside world; it makes no network
/// calls of its own.
class LinkLauncher {
  const LinkLauncher();

  /// False when nothing could open [url], so the caller can say so.
  Future<bool> open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
