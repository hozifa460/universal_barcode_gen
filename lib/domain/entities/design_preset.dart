// DesignPreset: saved QrDesign with name + icon.
import 'package:equatable/equatable.dart';

import '../../core/constants/qr_style.dart';
import 'qr_design.dart';

class DesignPreset extends Equatable {
  const DesignPreset({
    required this.id,
    required this.name,
    required this.design,
    this.isBuiltIn = false,
  });

  factory DesignPreset.fromJson(Map<String, dynamic> json) => DesignPreset(
        id: json['id'] as String,
        name: json['name'] as String,
        design: QrDesign.fromJson(json['design'] as Map<String, dynamic>),
        isBuiltIn: json['isBuiltIn'] as bool? ?? false,
      );

  final String id;
  final String name;
  final QrDesign design;
  final bool isBuiltIn;

  DesignPreset copyWith({
    String? id,
    String? name,
    QrDesign? design,
    bool? isBuiltIn,
  }) {
    return DesignPreset(
      id: id ?? this.id,
      name: name ?? this.name,
      design: design ?? this.design,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'design': design.toJson(),
        'isBuiltIn': isBuiltIn,
      };

  @override
  List<Object?> get props => [id, name, design, isBuiltIn];
}

/// Built-in starter presets shipped with the app.
class BuiltInPresets {
  BuiltInPresets._();

  static final List<DesignPreset> all = [
    const DesignPreset(
      id: 'preset_classic',
      name: 'Classic',
      isBuiltIn: true,
      design: QrDesign(
        foregroundColor: 0xFF0E0E0E,
        backgroundColor: 0xFFFFFFFF,
      ),
    ),
    DesignPreset(
      id: 'preset_ocean',
      name: 'Ocean',
      isBuiltIn: true,
      design: const QrDesign(
        foregroundColor: 0xFF0E7C6B,
        backgroundColor: 0xFFFFFFFF,
        useGradient: true,
        gradientStart: 0xFF0E7C6B,
        gradientEnd: 0xFF4FC3F7,
        gradientDirection: GradientDirection.diagonal,
        moduleShape: ModuleShape.rounded,
      ),
    ),
    DesignPreset(
      id: 'preset_sunset',
      name: 'Sunset',
      isBuiltIn: true,
      design: const QrDesign(
        foregroundColor: 0xFFF47B20,
        backgroundColor: 0xFFFFFFFF,
        useGradient: true,
        gradientStart: 0xFFF47B20,
        gradientEnd: 0xFFFFB199,
        gradientDirection: GradientDirection.vertical,
        moduleShape: ModuleShape.dots,
        eyeShape: EyeShape.circular,
      ),
    ),
    DesignPreset(
      id: 'preset_carbon',
      name: 'Carbon',
      isBuiltIn: true,
      design: const QrDesign(
        foregroundColor: 0xFFFFFFFF,
        backgroundColor: 0xFF1A1A1A,
        moduleShape: ModuleShape.rounded,
        eyeShape: EyeShape.rounded,
      ),
    ),
    DesignPreset(
      id: 'preset_mint',
      name: 'Mint',
      isBuiltIn: true,
      design: const QrDesign(
        foregroundColor: 0xFF00897B,
        backgroundColor: 0xFFE0F2F1,
        moduleShape: ModuleShape.circular,
        eyeShape: EyeShape.leaf,
      ),
    ),
  ];
}
