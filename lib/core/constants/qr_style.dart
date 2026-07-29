// QrStyle: visual customization enums for QR codes.
// Foreground module shape, finder eye shape, eye ball shape.

enum ModuleShape {
  square('Square'),
  rounded('Rounded'),
  circular('Circular'),
  hexagon('Hexagon'),
  dots('Dots');

  final String label;
  const ModuleShape(this.label);
}

enum EyeShape {
  square('Square'),
  rounded('Rounded'),
  circular('Circular'),
  leaf('Leaf'),
  bars('Bars');

  final String label;
  const EyeShape(this.label);
}

enum ErrorCorrectionLevel {
  low('Low (7%)', 'L'),
  medium('Medium (15%)', 'M'),
  quartile('Quartile (25%)', 'Q'),
  high('High (30%)', 'H');

  final String label;
  final String code;
  const ErrorCorrectionLevel(this.label, this.code);

  static ErrorCorrectionLevel fromCode(String code) {
    return ErrorCorrectionLevel.values.firstWhere(
      (e) => e.code == code,
      orElse: () => ErrorCorrectionLevel.medium,
    );
  }
}

enum GradientDirection {
  horizontal('Horizontal'),
  vertical('Vertical'),
  diagonal('Diagonal'),
  radial('Radial'),
  sweep('Sweep');

  final String label;
  const GradientDirection(this.label);
}

enum ExportFormat {
  png('PNG Image', 'png'),
  svg('SVG Vector', 'svg'),
  pdf('PDF Document', 'pdf'),
  highRes('High-Res PNG (8K)', 'png');

  final String label;
  final String extension;
  const ExportFormat(this.label, this.extension);
}

/// Built-in color palettes for QR designs.
class QrPalettes {
  QrPalettes._();

  static const List<({String name, int fg, int bg, int? accent})> presets = [
    (name: 'Classic', fg: 0xFF0E0E0E, bg: 0xFFFFFFFF, accent: null),
    (name: 'Ocean', fg: 0xFF0E7C6B, bg: 0xFFFFFFFF, accent: 0xFF4FC3F7),
    (name: 'Sunset', fg: 0xFFF47B20, bg: 0xFFFFFFFF, accent: 0xFFFFB199),
    (name: 'Forest', fg: 0xFF2E7D32, bg: 0xFFFFFFFF, accent: 0xFFA5D6A7),
    (name: 'Berry', fg: 0xFFAD1457, bg: 0xFFFFFFFF, accent: 0xFFF8BBD0),
    (name: 'Royal', fg: 0xFF3F51B5, bg: 0xFFFFFFFF, accent: 0xFF9FA8DA),
    (name: 'Carbon', fg: 0xFFFFFFFF, bg: 0xFF1A1A1A, accent: 0xFFF47B20),
    (name: 'Sand', fg: 0xFF5D4037, bg: 0xFFFFF8E1, accent: 0xFFD7CCC8),
    (name: 'Mint', fg: 0xFF00897B, bg: 0xFFE0F2F1, accent: 0xFF80CBC4),
    (name: 'Berry Dark', fg: 0xFFE91E63, bg: 0xFF1A1A1A, accent: 0xFFFFCDD2),
  ];
}
