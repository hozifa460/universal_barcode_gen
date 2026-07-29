// BatchItem: one row of a batch generation request.
import 'package:equatable/equatable.dart';

import '../../core/constants/barcode_format.dart';
import '../../core/constants/content_type.dart';

class BatchItem extends Equatable {
  const BatchItem({
    required this.id,
    required this.input,
    this.contentType,
    this.format = BarcodeFormat.qr,
    this.label,
    this.status = BatchItemStatus.pending,
    this.error,
  });

  final String id;
  final String input;
  final ContentType? contentType;
  final BarcodeFormat format;
  final String? label;
  final BatchItemStatus status;
  final String? error;

  BatchItem copyWith({
    String? id,
    String? input,
    ContentType? contentType,
    BarcodeFormat? format,
    String? label,
    BatchItemStatus? status,
    String? error,
    bool clearError = false,
  }) {
    return BatchItem(
      id: id ?? this.id,
      input: input ?? this.input,
      contentType: contentType ?? this.contentType,
      format: format ?? this.format,
      label: label ?? this.label,
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [id, input, contentType, format, label, status, error];
}

enum BatchItemStatus { pending, generated, failed }
