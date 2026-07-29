// ErrorBanner: displays an error message inline at the top of a screen.

import 'package:flutter/material.dart';

import '../../core/extensions/build_context.dart';

class ErrorBanner extends StatelessWidget {
  const ErrorBanner({
    super.key,
    required this.message,
    this.onDismiss,
  });

  final String message;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.errorContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.error_outline,
                color: context.colors.onErrorContainer, size: 20,),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onErrorContainer,
                ),
              ),
            ),
            if (onDismiss != null)
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: onDismiss,
                color: context.colors.onErrorContainer,
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
      ),
    );
  }
}
