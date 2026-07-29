// BarcodeContent: payload that gets encoded into a code.
// Captures structured inputs (WiFi, vCard, calendar) AND raw text.
//
// The `encoded` getter produces the final string passed to the barcode engine.

import 'package:equatable/equatable.dart';

import '../../core/constants/content_type.dart';

class BarcodeContent extends Equatable {
  const BarcodeContent({
    required this.type,
    required this.raw,
    this.structured,
  });

  factory BarcodeContent.fromJson(Map<String, dynamic> json) {
    final s = json['structured'] as Map<String, dynamic>?;
    return BarcodeContent(
      type: ContentType.fromString(json['type'] as String? ?? 'plainText'),
      raw: json['raw'] as String? ?? '',
      structured: s == null ? null : StructuredPayload.fromJson(s),
    );
  }

  final ContentType type;
  final String raw;

  /// Optional structured payload (Wi-Fi, vCard, etc.).
  /// When present, `raw` should equal `structured.encode()`.
  final StructuredPayload? structured;

  /// Convenience: returns the encoded string for the barcode engine.
  /// For QR-family formats this is the raw payload (possibly URI scheme).
  /// For 1D barcodes this is the raw input string.
  String get encoded => structured?.encode() ?? raw;

  /// Returns a short, human-readable label (used in history list).
  String get displayName {
    if (structured != null) return structured!.displayName;
    return raw.length > 40 ? '${raw.substring(0, 40)}…' : raw;
  }

  BarcodeContent copyWith({
    ContentType? type,
    String? raw,
    StructuredPayload? structured,
  }) {
    return BarcodeContent(
      type: type ?? this.type,
      raw: raw ?? this.raw,
      structured: structured ?? this.structured,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'raw': raw,
        'structured': structured?.toJson(),
      };

  @override
  List<Object?> get props => [type, raw, structured];
}

/// Sealed class for structured payloads (WiFi, vCard, calendar, etc.).
/// Each subclass implements `encode()` to produce the QR payload string.
sealed class StructuredPayload extends Equatable {
  const StructuredPayload();

  String encode();
  String get displayName;
  String get typeName;

  Map<String, dynamic> toJson();

  static StructuredPayload? fromJson(Map<String, dynamic> json) {
    final type = json['typeName'] as String?;
    return switch (type) {
      'wifi' => WifiPayload.fromJson(json),
      'vcard' => VCardPayload.fromJson(json),
      'calendar' => CalendarPayload.fromJson(json),
      'geo' => GeoPayload.fromJson(json),
      'sms' => SmsPayload.fromJson(json),
      'email' => EmailPayload.fromJson(json),
      'crypto' => CryptoPayload.fromJson(json),
      'social' => SocialPayload.fromJson(json),
      'appStore' => AppStorePayload.fromJson(json),
      _ => null,
    };
  }
}

// ---------------------------------------------------------------------------
// WiFi
// ---------------------------------------------------------------------------

class WifiPayload extends StructuredPayload {
  const WifiPayload({
    required this.ssid,
    required this.password,
    required this.encryption,
    this.hidden = false,
  });

  final String ssid;
  final String password;
  final WifiEncryption encryption;
  final bool hidden;

  @override
  String get typeName => 'wifi';

  @override
  String encode() {
    // WIFI:S:<ssid>;T:<WPA|WEP|nopass>;P:<password>;H:<true|false>;;
    final escapedSsid = ssid.replaceAll(r'\\', r'\\\\').replaceAll(';', r'\;');
    final escapedPass = password.replaceAll(r'\\', r'\\\\').replaceAll(';', r'\;');
    return 'WIFI:S:$escapedSsid;T:${encryption.value};P:$escapedPass;'
        'H:${hidden ? 'true' : 'false'};;';
  }

  @override
  String get displayName => 'Wi-Fi: $ssid';

  @override
  Map<String, dynamic> toJson() => {
        'typeName': 'wifi',
        'ssid': ssid,
        'password': password,
        'encryption': encryption.name,
        'hidden': hidden,
      };

  static WifiPayload fromJson(Map<String, dynamic> json) => WifiPayload(
        ssid: json['ssid'] as String? ?? '',
        password: json['password'] as String? ?? '',
        encryption: WifiEncryption.values.firstWhere(
          (e) => e.name == (json['encryption'] as String?),
          orElse: () => WifiEncryption.wpa,
        ),
        hidden: json['hidden'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [ssid, password, encryption, hidden];
}

enum WifiEncryption { wep('WEP'), wpa('WPA'), nopass('nopass');
  final String value;
  const WifiEncryption(this.value);
}

// ---------------------------------------------------------------------------
// vCard
// ---------------------------------------------------------------------------

class VCardPayload extends StructuredPayload {
  const VCardPayload({
    required this.firstName,
    required this.lastName,
    this.phone,
    this.email,
    this.organization,
    this.title,
    this.url,
    this.address,
  });

  final String firstName;
  final String lastName;
  final String? phone;
  final String? email;
  final String? organization;
  final String? title;
  final String? url;
  final String? address;

  @override
  String get typeName => 'vcard';

  @override
  String encode() {
    final lines = <String>[
      'BEGIN:VCARD',
      'VERSION:3.0',
      'N:$lastName;$firstName;;;',
      'FN:$firstName $lastName',
      if (phone != null) 'TEL;TYPE=CELL:$phone',
      if (email != null) 'EMAIL:$email',
      if (organization != null) 'ORG:$organization',
      if (title != null) 'TITLE:$title',
      if (url != null) 'URL:$url',
      if (address != null) 'ADR:;;$address;;;;',
      'END:VCARD',
    ];
    return lines.join('\n');
  }

  @override
  String get displayName => '$firstName $lastName';

  @override
  Map<String, dynamic> toJson() => {
        'typeName': 'vcard',
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'email': email,
        'organization': organization,
        'title': title,
        'url': url,
        'address': address,
      };

  static VCardPayload fromJson(Map<String, dynamic> json) => VCardPayload(
        firstName: json['firstName'] as String? ?? '',
        lastName: json['lastName'] as String? ?? '',
        phone: json['phone'] as String?,
        email: json['email'] as String?,
        organization: json['organization'] as String?,
        title: json['title'] as String?,
        url: json['url'] as String?,
        address: json['address'] as String?,
      );

  @override
  List<Object?> get props =>
      [firstName, lastName, phone, email, organization, title, url, address];
}

// ---------------------------------------------------------------------------
// Calendar
// ---------------------------------------------------------------------------

class CalendarPayload extends StructuredPayload {
  const CalendarPayload({
    required this.title,
    required this.start,
    required this.end,
    this.location,
    this.description,
  });

  final String title;
  final DateTime start;
  final DateTime end;
  final String? location;
  final String? description;

  @override
  String get typeName => 'calendar';

  @override
  String encode() {
    String fmt(DateTime d) =>
        "${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}T${d.hour.toString().padLeft(2, '0')}${d.minute.toString().padLeft(2, '0')}00";
    final lines = <String>[
      'BEGIN:VEVENT',
      'SUMMARY:$title',
      'DTSTART:${fmt(start)}',
      'DTEND:${fmt(end)}',
      if (location != null) 'LOCATION:$location',
      if (description != null) 'DESCRIPTION:$description',
      'END:VEVENT',
    ];
    return lines.join('\n');
  }

  @override
  String get displayName => title;

  @override
  Map<String, dynamic> toJson() => {
        'typeName': 'calendar',
        'title': title,
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
        'location': location,
        'description': description,
      };

  static CalendarPayload fromJson(Map<String, dynamic> json) => CalendarPayload(
        title: json['title'] as String? ?? '',
        start: DateTime.tryParse(json['start'] as String? ?? '') ?? DateTime.now(),
        end: DateTime.tryParse(json['end'] as String? ?? '') ?? DateTime.now(),
        location: json['location'] as String?,
        description: json['description'] as String?,
      );

  @override
  List<Object?> get props => [title, start, end, location, description];
}

// ---------------------------------------------------------------------------
// Geo
// ---------------------------------------------------------------------------

class GeoPayload extends StructuredPayload {
  const GeoPayload({required this.latitude, required this.longitude});
  final double latitude;
  final double longitude;

  @override
  String get typeName => 'geo';

  @override
  String encode() => 'geo:$latitude,$longitude';

  @override
  String get displayName => '📍 $latitude, $longitude'
      .replaceAll('📍', 'Geo:'); // avoid emoji in pure-dart tests

  @override
  Map<String, dynamic> toJson() => {
        'typeName': 'geo',
        'latitude': latitude,
        'longitude': longitude,
      };

  static GeoPayload fromJson(Map<String, dynamic> json) => GeoPayload(
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      );

  @override
  List<Object?> get props => [latitude, longitude];
}

// ---------------------------------------------------------------------------
// SMS
// ---------------------------------------------------------------------------

class SmsPayload extends StructuredPayload {
  const SmsPayload({required this.phone, this.message = ''});
  final String phone;
  final String message;

  @override
  String get typeName => 'sms';

  @override
  String encode() => 'SMSTO:$phone:$message';

  @override
  String get displayName => 'SMS: $phone';

  @override
  Map<String, dynamic> toJson() => {
        'typeName': 'sms',
        'phone': phone,
        'message': message,
      };

  static SmsPayload fromJson(Map<String, dynamic> json) => SmsPayload(
        phone: json['phone'] as String? ?? '',
        message: json['message'] as String? ?? '',
      );

  @override
  List<Object?> get props => [phone, message];
}

// ---------------------------------------------------------------------------
// Email
// ---------------------------------------------------------------------------

class EmailPayload extends StructuredPayload {
  const EmailPayload({required this.address, this.subject, this.body});
  final String address;
  final String? subject;
  final String? body;

  @override
  String get typeName => 'email';

  @override
  String encode() {
    final params = <String>[];
    if (subject != null) params.add('subject=${Uri.encodeQueryComponent(subject!)}');
    if (body != null) params.add('body=${Uri.encodeQueryComponent(body!)}');
    return 'mailto:$address${params.isEmpty ? '' : '?${params.join('&')}'}';
  }

  @override
  String get displayName => address;

  @override
  Map<String, dynamic> toJson() => {
        'typeName': 'email',
        'address': address,
        'subject': subject,
        'body': body,
      };

  static EmailPayload fromJson(Map<String, dynamic> json) => EmailPayload(
        address: json['address'] as String? ?? '',
        subject: json['subject'] as String?,
        body: json['body'] as String?,
      );

  @override
  List<Object?> get props => [address, subject, body];
}

// ---------------------------------------------------------------------------
// Crypto
// ---------------------------------------------------------------------------

class CryptoPayload extends StructuredPayload {
  const CryptoPayload({required this.coin, required this.address, this.amount});
  final CryptoCoin coin;
  final String address;
  final double? amount;

  @override
  String get typeName => 'crypto';

  @override
  String encode() {
    final uri = coin.scheme(address);
    if (amount != null) {
      return '$uri?amount=$amount';
    }
    return uri;
  }

  @override
  String get displayName => '${coin.name}: ${address.substring(0, address.length.clamp(0, 10))}…';

  @override
  Map<String, dynamic> toJson() => {
        'typeName': 'crypto',
        'coin': coin.name,
        'address': address,
        'amount': amount,
      };

  static CryptoPayload fromJson(Map<String, dynamic> json) => CryptoPayload(
        coin: CryptoCoin.values.firstWhere(
          (c) => c.name == (json['coin'] as String?),
          orElse: () => CryptoCoin.bitcoin,
        ),
        address: json['address'] as String? ?? '',
        amount: (json['amount'] as num?)?.toDouble(),
      );

  @override
  List<Object?> get props => [coin, address, amount];
}

enum CryptoCoin {
  bitcoin('Bitcoin', 'bitcoin:'),
  ethereum('Ethereum', 'ethereum:'),
  litecoin('Litecoin', 'litecoin:'),
  dogecoin('Dogecoin', 'dogecoin:'),
  tron('Tron', 'tron:'),
  solana('Solana', 'solana:'),
  bitcoinCash('Bitcoin Cash', 'bitcoincash:');

  final String label;
  final String schemePrefix;
  const CryptoCoin(this.label, this.schemePrefix);

  String scheme(String address) => '$schemePrefix$address';
}

// ---------------------------------------------------------------------------
// Social
// ---------------------------------------------------------------------------

class SocialPayload extends StructuredPayload {
  const SocialPayload({required this.platform, required this.username});
  final SocialPlatform platform;
  final String username;

  @override
  String get typeName => 'social';

  @override
  String encode() => platform.url(username);

  @override
  String get displayName => '${platform.label}: $username';

  @override
  Map<String, dynamic> toJson() => {
        'typeName': 'social',
        'platform': platform.name,
        'username': username,
      };

  static SocialPayload fromJson(Map<String, dynamic> json) => SocialPayload(
        platform: SocialPlatform.values.firstWhere(
          (p) => p.name == (json['platform'] as String?),
          orElse: () => SocialPlatform.website,
        ),
        username: json['username'] as String? ?? '',
      );

  @override
  List<Object?> get props => [platform, username];
}

enum SocialPlatform {
  facebook('Facebook', 'https://facebook.com/'),
  instagram('Instagram', 'https://instagram.com/'),
  twitter('Twitter / X', 'https://x.com/'),
  linkedin('LinkedIn', 'https://linkedin.com/in/'),
  tiktok('TikTok', 'https://tiktok.com/@'),
  youtube('YouTube', 'https://youtube.com/@'),
  snapchat('Snapchat', 'https://snapchat.com/add/'),
  telegram('Telegram', 'https://t.me/'),
  whatsapp('WhatsApp', 'https://wa.me/'),
  pinterest('Pinterest', 'https://pinterest.com/'),
  reddit('Reddit', 'https://reddit.com/user/'),
  github('GitHub', 'https://github.com/'),
  discord('Discord', 'https://discord.gg/'),
  threads('Threads', 'https://threads.net/@'),
  website('Website', '');

  final String label;
  final String baseUrl;
  const SocialPlatform(this.label, this.baseUrl);

  String url(String username) =>
      baseUrl.isEmpty ? username : '$baseUrl$username';
}

// ---------------------------------------------------------------------------
// App Store
// ---------------------------------------------------------------------------

class AppStorePayload extends StructuredPayload {
  const AppStorePayload({this.appleId, this.googlePackage});
  final String? appleId;
  final String? googlePackage;

  @override
  String get typeName => 'appStore';

  @override
  String encode() {
    if (appleId != null && appleId!.isNotEmpty) {
      return 'https://apps.apple.com/app/id$appleId';
    }
    if (googlePackage != null && googlePackage!.isNotEmpty) {
      return 'https://play.google.com/store/apps/details?id=$googlePackage';
    }
    return '';
  }

  @override
  String get displayName => appleId ?? googlePackage ?? 'App Link';

  @override
  Map<String, dynamic> toJson() => {
        'typeName': 'appStore',
        'appleId': appleId,
        'googlePackage': googlePackage,
      };

  static AppStorePayload fromJson(Map<String, dynamic> json) => AppStorePayload(
        appleId: json['appleId'] as String?,
        googlePackage: json['googlePackage'] as String?,
      );

  @override
  List<Object?> get props => [appleId, googlePackage];
}
