// QrDesign: visual customization config for QR codes.
// Pure value object — no Flutter imports so it's testable in pure Dart.

import 'package:equatable/equatable.dart';

import '../../core/constants/qr_style.dart';

class QrDesign extends Equatable {
  const QrDesign({
    this.foregroundColor = 0xFF0E0E0E,
    this.backgroundColor = 0xFFFFFFFF,
    this.useGradient = false,
    this.gradientStart = 0xFF0E7C6B,
    this.gradientEnd = 0xFF4FC3F7,
    this.gradientDirection = GradientDirection.diagonal,
    this.moduleShape = ModuleShape.square,
    this.eyeShape = EyeShape.square,
    this.errorCorrection = ErrorCorrectionLevel.medium,
    this.size = 1024,
    this.margin = 4,
    this.transparentBackground = false,
    this.borderRadius = 0,
    this.logoPath,
    this.logoSizeRatio = 0.20,
  });

  factory QrDesign.fromJson(Map<String, dynamic> json) => QrDesign(
        foregroundColor: json['foregroundColor'] as int? ?? 0xFF0E0E0E,
        backgroundColor: json['backgroundColor'] as int? ?? 0xFFFFFFFF,
        useGradient: json['useGradient'] as bool? ?? false,
        gradientStart: json['gradientStart'] as int? ?? 0xFF0E7C6B,
        gradientEnd: json['gradientEnd'] as int? ?? 0xFF4FC3F7,
        gradientDirection: GradientDirection.values.firstWhere(
          (e) => e.name == (json['gradientDirection'] as String?),
          orElse: () => GradientDirection.diagonal,
        ),
        moduleShape: ModuleShape.values.firstWhere(
          (e) => e.name == (json['moduleShape'] as String?),
          orElse: () => ModuleShape.square,
        ),
        eyeShape: EyeShape.values.firstWhere(
          (e) => e.name == (json['eyeShape'] as String?),
          orElse: () => EyeShape.square,
        ),
        errorCorrection: ErrorCorrectionLevel.fromCode(
          (json['errorCorrection'] as String?) ?? 'M',
        ),
        size: json['size'] as int? ?? 1024,
        margin: json['margin'] as int? ?? 4,
        transparentBackground: json['transparentBackground'] as bool? ?? false,
        borderRadius: (json['borderRadius'] as num?)?.toDouble() ?? 0,
        logoPath: json['logoPath'] as String?,
        logoSizeRatio: (json['logoSizeRatio'] as num?)?.toDouble() ?? 0.20,
      );

  final int foregroundColor;
  final int backgroundColor;
  final bool useGradient;
  final int gradientStart;
  final int gradientEnd;
  final GradientDirection gradientDirection;
  final ModuleShape moduleShape;
  final EyeShape eyeShape;
  final ErrorCorrectionLevel errorCorrection;
  final int size;
  final int margin;
  final bool transparentBackground;
  final double borderRadius;
  final String? logoPath;
  final double logoSizeRatio; // 0.0–0.35 of QR size

  QrDesign copyWith({
    int? foregroundColor,
    int? backgroundColor,
    bool? useGradient,
    int? gradientStart,
    int? gradientEnd,
    GradientDirection? gradientDirection,
    ModuleShape? moduleShape,
    EyeShape? eyeShape,
    ErrorCorrectionLevel? errorCorrection,
    int? size,
    int? margin,
    bool? transparentBackground,
    double? borderRadius,
    String? logoPath,
    double? logoSizeRatio,
    bool clearLogo = false,
  }) {
    return QrDesign(
      foregroundColor: foregroundColor ?? this.foregroundColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      useGradient: useGradient ?? this.useGradient,
      gradientStart: gradientStart ?? this.gradientStart,
      gradientEnd: gradientEnd ?? this.gradientEnd,
      gradientDirection: gradientDirection ?? this.gradientDirection,
      moduleShape: moduleShape ?? this.moduleShape,
      eyeShape: eyeShape ?? this.eyeShape,
      errorCorrection: errorCorrection ?? this.errorCorrection,
      size: size ?? this.size,
      margin: margin ?? this.margin,
      transparentBackground: transparentBackground ?? this.transparentBackground,
      borderRadius: borderRadius ?? this.borderRadius,
      logoPath: clearLogo ? null : (logoPath ?? this.logoPath),
      logoSizeRatio: logoSizeRatio ?? this.logoSizeRatio,
    );
  }

  /// Apply a built-in palette preset by index.
  QrDesign applyPreset(int index) {
    const presets = QrPalettes.presets;
    if (index < 0 || index >= presets.length) return this;
    final p = presets[index];
    return copyWith(
      foregroundColor: p.fg,
      backgroundColor: p.bg,
      useGradient: p.accent != null,
      gradientStart: p.fg,
      gradientEnd: p.accent ?? p.fg,
    );
  }

  Map<String, dynamic> toJson() => {
        'foregroundColor': foregroundColor,
        'backgroundColor': backgroundColor,
        'useGradient': useGradient,
        'gradientStart': gradientStart,
        'gradientEnd': gradientEnd,
        'gradientDirection': gradientDirection.name,
        'moduleShape': moduleShape.name,
        'eyeShape': eyeShape.name,
        'errorCorrection': errorCorrection.code,
        'size': size,
        'margin': margin,
        'transparentBackground': transparentBackground,
        'borderRadius': borderRadius,
        'logoPath': logoPath,
        'logoSizeRatio': logoSizeRatio,
      };

  @override
  List<Object?> get props => [
        foregroundColor, backgroundColor, useGradient, gradientStart,
        gradientEnd, gradientDirection, moduleShape, eyeShape,
        errorCorrection, size, margin, transparentBackground,
        borderRadius, logoPath, logoSizeRatio,
      ];
}
