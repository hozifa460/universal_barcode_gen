// Validators: per-content-type input validators.
// Each returns null if valid, else a localized error key.

import '../constants/content_type.dart';

class InputValidator {
  InputValidator._();

  /// Returns null if valid; otherwise returns an l10n error key.
  static String? validate(ContentType type, String input) {
    switch (type) {
      case ContentType.plainText:
      case ContentType.custom:
      case ContentType.clipboard:
        return input.isEmpty ? 'error_empty_input' : null;

      case ContentType.url:
        if (input.isEmpty) return 'error_empty_input';
        final uri = Uri.tryParse(input);
        if (uri == null || (!uri.hasScheme && !input.contains('.'))) {
          return 'error_invalid_url';
        }
        return null;

      case ContentType.email:
        if (input.isEmpty) return 'error_empty_input';
        if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
            .hasMatch(input)) {
          return 'error_invalid_email';
        }
        return null;

      case ContentType.phone:
        if (input.isEmpty) return 'error_empty_input';
        final cleaned = input.replaceAll(RegExp(r'[\s\-().]'), '');
        if (!RegExp(r'^\+?\d{7,15}$').hasMatch(cleaned)) {
          return 'error_invalid_phone';
        }
        return null;

      case ContentType.sms:
      case ContentType.wifi:
      case ContentType.vcard:
      case ContentType.calendarEvent:
      case ContentType.geo:
      case ContentType.crypto:
      case ContentType.social:
      case ContentType.appStore:
        return input.isEmpty ? 'error_empty_input' : null;

      case ContentType.product:
        if (input.isEmpty) return 'error_empty_input';
        if (!RegExp(r'^\d+$').hasMatch(input)) return 'error_invalid_product';
        return null;

      case ContentType.isbn:
        if (input.isEmpty) return 'error_empty_input';
        final cleaned = input
            .toUpperCase()
            .replaceAll('ISBN', '')
            .replaceAll(RegExp(r'[\s\-]'), '');
        if (!RegExp(r'^(\d{9}[\dX]|\d{13})$').hasMatch(cleaned)) {
          return 'error_invalid_isbn';
        }
        return null;

      case ContentType.upc:
        if (input.isEmpty) return 'error_empty_input';
        if (!RegExp(r'^\d{12}$').hasMatch(input)) return 'error_invalid_upc';
        return null;

      case ContentType.ean:
        if (input.isEmpty) return 'error_empty_input';
        if (!RegExp(r'^\d{8}$|^\d{13}$').hasMatch(input)) {
          return 'error_invalid_ean';
        }
        return null;

      case ContentType.code128:
      case ContentType.code39:
        if (input.isEmpty) return 'error_empty_input';
        if (input.length > 80) return 'error_too_long';
        return null;

      case ContentType.codabar:
        if (input.isEmpty) return 'error_empty_input';
        if (!RegExp(r'^[0-9\-\$\:\/\.\+]+$').hasMatch(input)) {
          return 'error_invalid_codabar';
        }
        return null;

      case ContentType.itf:
        if (input.isEmpty) return 'error_empty_input';
        if (input.length.isOdd) return 'error_itf_odd_length';
        if (!RegExp(r'^\d+$').hasMatch(input)) return 'error_invalid_itf';
        return null;

      case ContentType.pdf417:
      case ContentType.dataMatrix:
      case ContentType.aztec:
      case ContentType.gs1:
        return input.isEmpty ? 'error_empty_input' : null;
    }
  }

  /// Validates the structural checksum for EAN-13 / ISBN-13.
  static bool validateEan13Checksum(String input) {
    if (!RegExp(r'^\d{13}$').hasMatch(input)) return false;
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      final d = int.parse(input[i]);
      sum += (i.isOdd) ? d * 3 : d;
    }
    final check = (10 - (sum % 10)) % 10;
    return check == int.parse(input[12]);
  }

  /// UPC-A checksum validation.
  static bool validateUpcChecksum(String input) {
    if (!RegExp(r'^\d{12}$').hasMatch(input)) return false;
    int sum = 0;
    for (int i = 0; i < 11; i++) {
      final d = int.parse(input[i]);
      sum += (i.isOdd) ? d : d * 3;
    }
    final check = (10 - (sum % 10)) % 10;
    return check == int.parse(input[11]);
  }
}
