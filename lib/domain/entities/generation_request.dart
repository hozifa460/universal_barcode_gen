// GenerationRequest: input bundle to the generator use case.
import 'package:equatable/equatable.dart';

import '../../core/constants/barcode_format.dart';
import 'barcode_content.dart';
import 'qr_design.dart';

class GenerationRequest extends Equatable {
  const GenerationRequest({
    required this.content,
    required this.format,
    required this.design,
  });

  final BarcodeContent content;
  final BarcodeFormat format;
  final QrDesign design;

  @override
  List<Object?> get props => [content, format, design];
}

/// Result of a generation operation.
///
/// Holds the rendered image bytes + metadata for export / preview.
class GenerationResult extends Equatable {
  const GenerationResult({
    required this.request,
    required this.imageBytes,
    required this.width,
    required this.height,
    this.svgString,
    this.isValid = true,
    this.validationMessage,
  });

  final GenerationRequest request;
  final List<int> imageBytes; // PNG bytes
  final int width;
  final int height;
  final String? svgString;
  final bool isValid;
  final String? validationMessage;

  @override
  List<Object?> get props => [
        request, imageBytes, width, height,
        svgString, isValid, validationMessage,
      ];
}
