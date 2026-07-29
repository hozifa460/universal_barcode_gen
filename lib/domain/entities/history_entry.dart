// HistoryEntry: persisted generated code with metadata.
// Stored in Hive box; JSON-serializable for backup/restore.

import 'package:equatable/equatable.dart';

import '../../core/constants/barcode_format.dart';
import 'barcode_content.dart';
import 'qr_design.dart';

class HistoryEntry extends Equatable {
  const HistoryEntry({
    required this.id,
    required this.content,
    required this.format,
    required this.design,
    required this.createdAt,
    required this.updatedAt,
    this.folderId,
    this.tags = const [],
    this.isFavorite = false,
    this.notes,
    this.previewPath,
  });

  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
        id: json['id'] as String,
        content: BarcodeContent.fromJson(
          json['content'] as Map<String, dynamic>,
        ),
        format: BarcodeFormat.fromString(json['format'] as String? ?? 'qr'),
        design: QrDesign.fromJson(
          json['design'] as Map<String, dynamic>? ?? const {},
        ),
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
        updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
            DateTime.now(),
        folderId: json['folderId'] as String?,
        tags: (json['tags'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
        isFavorite: json['isFavorite'] as bool? ?? false,
        notes: json['notes'] as String?,
        previewPath: json['previewPath'] as String?,
      );

  final String id;
  final BarcodeContent content;
  final BarcodeFormat format;
  final QrDesign design;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? folderId;
  final List<String> tags;
  final bool isFavorite;
  final String? notes;
  final String? previewPath; // cached PNG path

  HistoryEntry copyWith({
    String? id,
    BarcodeContent? content,
    BarcodeFormat? format,
    QrDesign? design,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? folderId,
    List<String>? tags,
    bool? isFavorite,
    String? notes,
    String? previewPath,
    bool clearFolder = false,
  }) {
    return HistoryEntry(
      id: id ?? this.id,
      content: content ?? this.content,
      format: format ?? this.format,
      design: design ?? this.design,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      folderId: clearFolder ? null : (folderId ?? this.folderId),
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      notes: notes ?? this.notes,
      previewPath: previewPath ?? this.previewPath,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content.toJson(),
        'format': format.name,
        'design': design.toJson(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'folderId': folderId,
        'tags': tags,
        'isFavorite': isFavorite,
        'notes': notes,
        'previewPath': previewPath,
      };

  /// Returns true if [other] has the same content + format (used for duplicate detection).
  bool isDuplicateOf(HistoryEntry other) {
    return content.encoded == other.content.encoded &&
        format == other.format;
  }

  @override
  List<Object?> get props => [
        id, content, format, design, createdAt, updatedAt,
        folderId, tags, isFavorite, notes, previewPath,
      ];
}
