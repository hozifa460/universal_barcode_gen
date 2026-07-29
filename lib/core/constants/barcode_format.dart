// BarcodeFormat: every supported 1D/2D barcode format with metadata.
// Maps cleanly to the underlying `barcode` package's BarcodeType enum
// while exposing richer info (supportsChecksum, maxChars, isLinear).

enum BarcodeFormat {
  qr('QR Code', 'qr', is2D: true, maxChars: 2953),
  pdf417('PDF417', 'pdf417', is2D: true, maxChars: 2710),
  dataMatrix('Data Matrix', 'datamatrix', is2D: true, maxChars: 2335),
  aztec('Aztec', 'aztec', is2D: true, maxChars: 3832),
  code128('Code 128', 'code128', is1D: true, maxChars: 80),
  code39('Code 39', 'code39', is1D: true, maxChars: 80),
  code93('Code 93', 'code93', is1D: true, maxChars: 80),
  codabar('Codabar', 'codabar', is1D: true, maxChars: 80),
  itf('ITF', 'itf', is1D: true, maxChars: 80),
  ean13('EAN-13', 'ean13', is1D: true, maxChars: 13, fixedLength: 13),
  ean8('EAN-8', 'ean8', is1D: true, maxChars: 8, fixedLength: 8),
  upcA('UPC-A', 'upca', is1D: true, maxChars: 12, fixedLength: 12),
  upcE('UPC-E', 'upce', is1D: true, maxChars: 8, fixedLength: 8),
  isbn('ISBN', 'isbn', is1D: true, maxChars: 13, fixedLength: 13),
  gs1('GS1-128', 'gs1', is1D: true, maxChars: 80),
  telepen('Telepen', 'telepen', is1D: true, maxChars: 80),
  rm4scc('RM4SCC', 'rm4scc', is1D: true, maxChars: 50);

  final String label;
  final String codeKey;
  final bool is1D;
  final bool is2D;
  final int maxChars;
  final int? fixedLength;

  const BarcodeFormat(
    this.label,
    this.codeKey, {
    this.is1D = false,
    this.is2D = false,
    this.maxChars = 2953,
    this.fixedLength,
  });

  bool get isFixedLength => fixedLength != null;

  /// Returns the list of barcode formats compatible with [length] of content.
  /// Used by the Universal Code Converter to recommend the best format.
  static List<BarcodeFormat> compatibleWith(int length) {
    return BarcodeFormat.values.where((f) => length <= f.maxChars).toList();
  }

  static BarcodeFormat fromString(String value) {
    return BarcodeFormat.values.firstWhere(
      (f) => f.name == value,
      orElse: () => BarcodeFormat.qr,
    );
  }
}
