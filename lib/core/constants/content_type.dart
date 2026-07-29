// ContentType: enum of every input content type the app can encode.
// Used by auto-detection, generator UI, and history filter.
//
// Order matters — most-common types first so auto-detect heuristic
// checks them earlier. Each entry has an associated vCard/format builder.

enum ContentType {
  plainText('Plain Text'),
  url('URL / Website'),
  email('Email'),
  phone('Phone Number'),
  sms('SMS'),
  wifi('Wi-Fi'),
  vcard('Contact (vCard)'),
  calendarEvent('Calendar Event'),
  geo('Geographic Coordinates'),
  crypto('Cryptocurrency Address'),
  social('Social Media'),
  appStore('App Store / Google Play'),
  product('Product Code'),
  isbn('ISBN'),
  upc('UPC'),
  ean('EAN'),
  code128('Code128'),
  code39('Code39'),
  codabar('Codabar'),
  itf('ITF'),
  pdf417('PDF417'),
  dataMatrix('Data Matrix'),
  aztec('Aztec'),
  gs1('GS1'),
  custom('Custom'),
  clipboard('Clipboard');

  final String label;
  const ContentType(this.label);

  /// True for 2D matrix formats (QR-family). False for 1D barcodes.
  bool get is2D =>
      this == ContentType.pdf417 ||
      this == ContentType.dataMatrix ||
      this == ContentType.aztec ||
      this == ContentType.gs1;

  /// True for content types that ship as a structured payload (vCard, WiFi, SMS).
  bool get isStructured =>
      this == ContentType.wifi ||
      this == ContentType.vcard ||
      this == ContentType.calendarEvent ||
      this == ContentType.sms ||
      this == ContentType.email ||
      this == ContentType.geo ||
      this == ContentType.wifi ||
      this == ContentType.crypto;

  /// Localization key for this content type.
  String get l10nKey => 'contentType_$name';

  static ContentType fromString(String value) {
    return ContentType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ContentType.plainText,
    );
  }
}
