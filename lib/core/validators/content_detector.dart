// ContentDetector: smart auto-detection of input content type.
// Returns a ranked list of ContentType candidates based on heuristics.
//
// Detection order matters — more specific patterns first.

import 'package:url_launcher/url_launcher.dart';

import '../constants/content_type.dart';

class ContentDetector {
  ContentDetector._();

  /// Returns the most likely ContentType for [input].
  /// Falls back to ContentType.plainText.
  static ContentType detect(String input) {
    final candidates = detectAll(input);
    return candidates.isEmpty ? ContentType.plainText : candidates.first;
  }

  /// Returns ranked candidates — first is most likely.
  static List<ContentType> detectAll(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return const [ContentType.plainText];

    final candidates = <_Candidate>[];

    // Wi-Fi: "WIFI:S:...;T:...;P:...;H:;;" or starts with WIFI:
    if (trimmed.startsWith('WIFI:') || _isWifiPattern(trimmed)) {
      candidates.add(const _Candidate(ContentType.wifi, 100));
    }

    // vCard: BEGIN:VCARD
    if (trimmed.startsWith('BEGIN:VCARD') || trimmed.contains('BEGIN:VCARD')) {
      candidates.add(const _Candidate(ContentType.vcard, 100));
    }

    // Calendar event: BEGIN:VEVENT
    if (trimmed.startsWith('BEGIN:VEVENT') || trimmed.contains('BEGIN:VEVENT')) {
      candidates.add(const _Candidate(ContentType.calendarEvent, 100));
    }

    // Geo: "geo:lat,lng" or "GEO:"
    if (trimmed.toLowerCase().startsWith('geo:')) {
      candidates.add(const _Candidate(ContentType.geo, 100));
    }

    // Mailto: explicit email
    if (trimmed.toLowerCase().startsWith('mailto:')) {
      candidates.add(const _Candidate(ContentType.email, 100));
    }

    // SMS / SMSTO:
    if (trimmed.toLowerCase().startsWith('sms:') ||
        trimmed.toLowerCase().startsWith('smsto:')) {
      candidates.add(const _Candidate(ContentType.sms, 100));
    }

    // Tel:
    if (trimmed.toLowerCase().startsWith('tel:')) {
      candidates.add(const _Candidate(ContentType.phone, 100));
    }

    // Cryptocurrency: explicit prefixes
    if (_isCryptoAddress(trimmed)) {
      candidates.add(const _Candidate(ContentType.crypto, 95));
    }

    // Email pattern (RFC 5322 simplified)
    if (_isEmail(trimmed)) {
      candidates.add(const _Candidate(ContentType.email, 90));
    }

    // Phone number: +digits with optional separators
    if (_isPhoneNumber(trimmed)) {
      candidates.add(const _Candidate(ContentType.phone, 70));
    }

    // Social media: known domains
    if (_isSocialLink(trimmed)) {
      candidates.add(const _Candidate(ContentType.social, 85));
    }

    // App store: known market domains
    if (_isAppStoreLink(trimmed)) {
      candidates.add(const _Candidate(ContentType.appStore, 90));
    }

    // URL
    if (_isUrl(trimmed)) {
      candidates.add(const _Candidate(ContentType.url, 80));
    }

    // ISBN: 10 or 13 digits with optional hyphens, may start with ISBN
    if (_isIsbn(trimmed)) {
      candidates.add(const _Candidate(ContentType.isbn, 80));
    }

    // Product codes
    if (_isEan13(trimmed)) {
      candidates.add(const _Candidate(ContentType.ean, 75));
    }
    if (_isUpcA(trimmed)) {
      candidates.add(const _Candidate(ContentType.upc, 70));
    }
    if (_isEan8(trimmed)) {
      candidates.add(const _Candidate(ContentType.ean, 65));
    }

    // Always include plainText as fallback with low score.
    candidates.add(const _Candidate(ContentType.plainText, 10));

    candidates.sort((a, b) => b.score.compareTo(a.score));
    return candidates.map((c) => c.type).toList();
  }

  static bool _isEmail(String s) =>
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(s);

  static bool _isUrl(String s) {
    if (s.isEmpty) return false;
    final lowered = s.toLowerCase();
    if (!lowered.startsWith('http://') &&
        !lowered.startsWith('https://') &&
        !lowered.startsWith('ftp://')) {
      // allow "example.com" form
      if (!RegExp(r'^[a-z0-9-]+\.[a-z]{2,}').hasMatch(lowered)) {
        return false;
      }
    }
    try {
      return Uri.tryParse(s)?.hasAbsolutePath ?? false;
    } catch (_) {
      return false;
    }
  }

  static bool _isPhoneNumber(String s) {
    final cleaned = s.replaceAll(RegExp(r'[\s\-().]'), '');
    return RegExp(r'^\+?\d{7,15}$').hasMatch(cleaned);
  }

  static bool _isWifiPattern(String s) =>
      RegExp(r'^(WIFI|wifi):S:.*;T:.*;P:.*;;?$', dotAll: true).hasMatch(s) ||
      (s.startsWith('WIFI:') && s.contains('S:') && s.contains(';'));

  static bool _isCryptoAddress(String s) {
    // Bitcoin (legacy / bech32)
    if (RegExp(r'^[13][a-km-zA-HJ-NP-Z1-9]{25,34}$').hasMatch(s)) return true;
    if (RegExp(r'^bc1[a-z0-9]{39,59}$').hasMatch(s)) return true;
    // Ethereum
    if (RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(s)) return true;
    // Tron
    if (RegExp(r'^T[A-Za-z1-9]{33}$').hasMatch(s)) return true;
    // Litecoin
    if (RegExp(r'^[LM][a-km-zA-HJ-NP-Z1-9]{26,33}$').hasMatch(s)) return true;
    // Dogecoin
    if (RegExp(r'^D[A-Za-z1-9]{33}$').hasMatch(s)) return true;
    // Solana
    if (RegExp(r'^[1-9A-HJ-NP-Za-km-z]{43,44}$').hasMatch(s)) return true;
    return false;
  }

  static bool _isSocialLink(String s) {
    final lowered = s.toLowerCase();
    const domains = [
      'facebook.com', 'instagram.com', 'twitter.com', 'x.com',
      'linkedin.com', 'tiktok.com', 'youtube.com', 'youtu.be',
      'snapchat.com', 'telegram.me', 't.me', 'whatsapp.com',
      'pinterest.com', 'reddit.com', 'github.com', 'discord.com',
      'discord.gg', 'threads.net',
    ];
    return domains.any((d) => lowered.contains(d));
  }

  static bool _isAppStoreLink(String s) {
    final lowered = s.toLowerCase();
    return lowered.contains('play.google.com/store') ||
        lowered.contains('apps.apple.com') ||
        lowered.contains('itunes.apple.com') ||
        lowered.contains('market.android.com');
  }

  static bool _isIsbn(String s) {
    final cleaned = s
        .toUpperCase()
        .replaceAll('ISBN', '')
        .replaceAll(RegExp(r'[\s\-]'), '');
    if (cleaned.length == 10 && RegExp(r'^\d{9}[\dX]$').hasMatch(cleaned)) {
      return true;
    }
    if (cleaned.length == 13 && RegExp(r'^\d{13}$').hasMatch(cleaned)) {
      return true;
    }
    return false;
  }

  static bool _isEan13(String s) =>
      RegExp(r'^\d{13}$').hasMatch(s);

  static bool _isEan8(String s) =>
      RegExp(r'^\d{8}$').hasMatch(s);

  static bool _isUpcA(String s) =>
      RegExp(r'^\d{12}$').hasMatch(s);

  /// Helper: returns true if the string is a launchable URL.
  static Future<bool> isLaunchable(String s) {
    return canLaunchUrl(Uri.parse(s));
  }
}

class _Candidate {
  const _Candidate(this.type, this.score);
  final ContentType type;
  final int score;
}
