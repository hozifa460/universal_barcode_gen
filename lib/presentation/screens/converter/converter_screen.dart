// ConverterScreen: Universal Code Converter.
// User pastes content → app detects type, recommends best format,
// shows ALL compatible formats with previews, lets user pick.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/build_context.dart';
import '../../../domain/entities/generation_request.dart';
import '../../providers/converter_provider.dart';
import '../../providers/generator_provider.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/qr_preview_widget.dart';

class ConverterScreen extends ConsumerStatefulWidget {
  const ConverterScreen({super.key});

  @override
  ConsumerState<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends ConsumerState<ConverterScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(converterStateProvider);
    final notifier = ref.read(converterStateProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.converter_title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            context.l10n.converter_subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: context.l10n.input_label,
              hintText: context.l10n.input_hint,
              suffixIcon: IconButton(
                icon: const Icon(Icons.content_paste),
                onPressed: () async {
                  final data = await Clipboard.getData('text/plain');
                  if (data?.text != null) {
                    _controller.text = data!.text!;
                    notifier.setRawInput(data.text!);
                  }
                },
              ),
            ),
            maxLines: 4,
            onChanged: notifier.setRawInput,
          ),
          if (state.detectedType != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.lightbulb_outline,
                    color: Theme.of(context).colorScheme.primary, size: 18,),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${context.l10n.converter_recommendation(state.recommendedFormat?.label ?? 'QR')} '
                    '• Detected: ${state.detectedType!.label}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
              ],
            ),
          ],
          if (state.errorKey != null) ...[
            const SizedBox(height: 8),
            ErrorBanner(message: state.errorKey!),
          ],
          const SizedBox(height: 16),
          if (state.compatibleFormats.isNotEmpty) ...[
            Text(
              context.l10n.converter_compareAll,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: state.compatibleFormats.map((f) {
                return Chip(
                  label: Text(f.label),
                  avatar: f == state.recommendedFormat
                      ? Icon(Icons.star, size: 16,
                          color: Theme.of(context).colorScheme.tertiary,)
                      : null,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: state.isGenerating
                  ? null
                  : () => notifier.generateAll(
                        ref.read(generatorStateProvider).design,
                      ),
              icon: state.isGenerating
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),)
                  : const Icon(Icons.compare_arrows),
              label: Text(context.l10n.converter_compareAll),
            ),
            const SizedBox(height: 24),
          ],
          if (state.results.isNotEmpty) ...[
            Text(
              'Generated Codes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: state.results.length,
              itemBuilder: (context, i) {
                final result = state.results[i];
                return _FormatCard(result: result);
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _FormatCard extends StatelessWidget {
  const _FormatCard({required this.result});
  final GenerationResult result;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: QrPreviewWidget(result: result, size: 130),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              result.request.format.label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Row(
              children: [
                Icon(
                  result.isValid ? Icons.check_circle : Icons.warning,
                  size: 14,
                  color: result.isValid
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    result.isValid
                        ? context.l10n.converter_validityOk
                        : context.l10n.converter_validityFail,
                    style: Theme.of(context).textTheme.labelSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
