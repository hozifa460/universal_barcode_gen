// ScanResult: persisted scan record.
import 'package:equatable/equatable.dart';

import '../../core/constants/barcode_format.dart';
import '../../core/constants/content_type.dart';

class ScanResult extends Equatable {
  const ScanResult({
    required this.id,
    required this.rawValue,
    required this.format,
    required this.detectedType,
    required this.scannedAt,
    this.imagePath,
    this.notes,
    this.isFavorite = false,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) => ScanResult(
        id: json['id'] as String,
        rawValue: json['rawValue'] as String,
        format: BarcodeFormat.fromString(json['format'] as String? ?? 'qr'),
        detectedType:
            ContentType.fromString(json['detectedType'] as String? ?? 'plainText'),
        scannedAt:
            DateTime.tryParse(json['scannedAt'] as String? ?? '') ??
                DateTime.now(),
        imagePath: json['imagePath'] as String?,
        notes: json['notes'] as String?,
        isFavorite: json['isFavorite'] as bool? ?? false,
      );

  final String id;
  final String rawValue;
  final BarcodeFormat format;
  final ContentType detectedType;
  final DateTime scannedAt;
  final String? imagePath;
  final String? notes;
  final bool isFavorite;

  ScanResult copyWith({
    String? id,
    String? rawValue,
    BarcodeFormat? format,
    ContentType? detectedType,
    DateTime? scannedAt,
    String? imagePath,
    String? notes,
    bool? isFavorite,
  }) {
    return ScanResult(
      id: id ?? this.id,
      rawValue: rawValue ?? this.rawValue,
      format: format ?? this.format,
      detectedType: detectedType ?? this.detectedType,
      scannedAt: scannedAt ?? this.scannedAt,
      imagePath: imagePath ?? this.imagePath,
      notes: notes ?? this.notes,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'rawValue': rawValue,
        'format': format.name,
        'detectedType': detectedType.name,
        'scannedAt': scannedAt.toIso8601String(),
        'imagePath': imagePath,
        'notes': notes,
        'isFavorite': isFavorite,
      };

  @override
  List<Object?> get props =>
      [id, rawValue, format, detectedType, scannedAt, imagePath, notes, isFavorite];
}
