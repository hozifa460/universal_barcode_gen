// QrPreviewWidget: renders the generated QR/barcode image with smooth transitions.

import 'dart:typed_data' show Uint8List;

import 'package:flutter/material.dart';

import '../../../core/extensions/build_context.dart';
import '../../../domain/entities/generation_request.dart';

class QrPreviewWidget extends StatelessWidget {
  const QrPreviewWidget({
    super.key,
    required this.result,
    this.size = 280,
  });

  final GenerationResult? result;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: result == null
          ? _EmptyPreview(size: size)
          : _PopulatedPreview(result: result!, size: size),
    );
  }
}

class _EmptyPreview extends StatelessWidget {
  const _EmptyPreview({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_2,
              size: 72,
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.4),),
          const SizedBox(height: 12),
          Text(
            context.l10n.preview_empty,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _PopulatedPreview extends StatelessWidget {
  const _PopulatedPreview({required this.result, required this.size});
  final GenerationResult result;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Image.memory(
        Uint8List.fromList(result.imageBytes),
        fit: BoxFit.contain,
        gaplessPlayback: true,
      ),
    );
  }
}
