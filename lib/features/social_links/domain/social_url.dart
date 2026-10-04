/// Turns what was typed into a full web address, or null when it can't be
/// one. People paste `facebook.com/shop` without a scheme, so https is
/// assumed; other schemes (`javascript:`, `file:`…) are refused.
String? normalizeSocialUrl(String input) {
  final text = input.trim();
  if (text.isEmpty || text.contains(RegExp(r'\s'))) return null;

  final hasScheme = RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*://').hasMatch(text);
  final candidate = hasScheme ? text : 'https://$text';

  final uri = Uri.tryParse(candidate);
  if (uri == null) return null;
  if (uri.scheme != 'https' && uri.scheme != 'http') return null;
  // A real site has a dot ("shopee.ph"); this also rejects "https://abc".
  if (!uri.host.contains('.') ||
      uri.host.startsWith('.') ||
      uri.host.endsWith('.')) {
    return null;
  }
  return candidate;
}
