// AppSettings: persisted user preferences.
import 'package:equatable/equatable.dart';

import '../../core/constants/qr_style.dart';

class AppSettings extends Equatable {
  const AppSettings({
    this.defaultErrorCorrection = ErrorCorrectionLevel.medium,
    this.clipboardMonitor = false,
    this.autoOpenUrls = false,
    this.defaultExportSize = 1024,
    this.defaultExportFormat = ExportFormat.png,
    this.hapticFeedback = true,
    this.continuousScan = false,
    this.flashlightDefault = false,
    this.showTips = true,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        defaultErrorCorrection: ErrorCorrectionLevel.fromCode(
          json['defaultErrorCorrection'] as String? ?? 'M',
        ),
        clipboardMonitor: json['clipboardMonitor'] as bool? ?? false,
        autoOpenUrls: json['autoOpenUrls'] as bool? ?? false,
        defaultExportSize: json['defaultExportSize'] as int? ?? 1024,
        defaultExportFormat: ExportFormat.values.firstWhere(
          (e) => e.name == (json['defaultExportFormat'] as String?),
          orElse: () => ExportFormat.png,
        ),
        hapticFeedback: json['hapticFeedback'] as bool? ?? true,
        continuousScan: json['continuousScan'] as bool? ?? false,
        flashlightDefault: json['flashlightDefault'] as bool? ?? false,
        showTips: json['showTips'] as bool? ?? true,
      );

  final ErrorCorrectionLevel defaultErrorCorrection;
  final bool clipboardMonitor;
  final bool autoOpenUrls;
  final int defaultExportSize;
  final ExportFormat defaultExportFormat;
  final bool hapticFeedback;
  final bool continuousScan;
  final bool flashlightDefault;
  final bool showTips;

  AppSettings copyWith({
    ErrorCorrectionLevel? defaultErrorCorrection,
    bool? clipboardMonitor,
    bool? autoOpenUrls,
    int? defaultExportSize,
    ExportFormat? defaultExportFormat,
    bool? hapticFeedback,
    bool? continuousScan,
    bool? flashlightDefault,
    bool? showTips,
  }) {
    return AppSettings(
      defaultErrorCorrection: defaultErrorCorrection ?? this.defaultErrorCorrection,
      clipboardMonitor: clipboardMonitor ?? this.clipboardMonitor,
      autoOpenUrls: autoOpenUrls ?? this.autoOpenUrls,
      defaultExportSize: defaultExportSize ?? this.defaultExportSize,
      defaultExportFormat: defaultExportFormat ?? this.defaultExportFormat,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      continuousScan: continuousScan ?? this.continuousScan,
      flashlightDefault: flashlightDefault ?? this.flashlightDefault,
      showTips: showTips ?? this.showTips,
    );
  }

  Map<String, dynamic> toJson() => {
        'defaultErrorCorrection': defaultErrorCorrection.code,
        'clipboardMonitor': clipboardMonitor,
        'autoOpenUrls': autoOpenUrls,
        'defaultExportSize': defaultExportSize,
        'defaultExportFormat': defaultExportFormat.name,
        'hapticFeedback': hapticFeedback,
        'continuousScan': continuousScan,
        'flashlightDefault': flashlightDefault,
        'showTips': showTips,
      };

  @override
  List<Object?> get props => [
        defaultErrorCorrection, clipboardMonitor, autoOpenUrls,
        defaultExportSize, defaultExportFormat, hapticFeedback,
        continuousScan, flashlightDefault, showTips,
      ];
}
