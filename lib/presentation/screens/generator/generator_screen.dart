// GeneratorScreen: main "Generate" tab.
//
// Layout (portrait):
//   ┌──────────────────────┐
//   │ AppBar               │
//   ├──────────────────────┤
//   │ Content type chips   │  ← horizontally scrollable
//   │ (plainText, URL, …)  │
//   ├──────────────────────┤
//   │ Input field          │  ← text field OR structured form
//   ├──────────────────────┤
//   │ Live preview         │  ← renders generated QR/barcode
//   ├──────────────────────┤
//   │ Action buttons:      │
//   │   Save / Share / Copy│
//   │   Export (PNG/SVG/PDF)│
//   ├──────────────────────┤
//   │ Customize (expandable)│
//   │   Colors, gradient,  │
//   │   shapes, EC, logo…  │
//   └──────────────────────┘
//
// Tablet layout uses a two-column split: left = input + chips,
// right = preview + actions + customization.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';

import '../../../core/constants/barcode_format.dart';
import '../../../core/constants/content_type.dart';
import '../../../core/constants/qr_style.dart';
import '../../../core/errors/either.dart';
import '../../../core/errors/failures.dart';
import '../../../core/extensions/build_context.dart';
import '../../../core/utils/service_locator.dart';
import '../../../domain/entities/barcode_content.dart';
import '../../../domain/entities/qr_design.dart';
import '../../../domain/usecases/clipboard_usecases.dart';
import '../../../domain/usecases/export_usecase.dart';
import '../../providers/generator_provider.dart';
import '../../widgets/content_type_chip.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/qr_preview_widget.dart';
import 'customization_panel.dart';
import 'structured_input_forms.dart';

class GeneratorScreen extends ConsumerStatefulWidget {
  const GeneratorScreen({super.key});

  @override
  ConsumerState<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends ConsumerState<GeneratorScreen> {
  bool _showCustomize = false;
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(generatorStateProvider);
    final notifier = ref.read(generatorStateProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.tabGenerator),
        actions: [
          IconButton(
            tooltip: context.l10n.action_paste,
            icon: const Icon(Icons.content_paste),
            onPressed: () async {
              final r = await ReadClipboardUseCase().call();
              r.fold(
                onLeft: (_) {},
                onRight: (text) {
                  if (text != null && text.isNotEmpty) {
                    _textController.text = text;
                    notifier.setRawInput(text);
                  }
                },
              );
            },
          ),
          IconButton(
            tooltip: context.l10n.action_clear,
            icon: const Icon(Icons.clear),
            onPressed: () {
              _textController.clear();
              notifier.clearInput();
            },
          ),
        ],
      ),
      body: context.isTablet
          ? _buildTabletLayout(state, notifier)
          : _buildPhoneLayout(state, notifier),
    );
  }

  // -------------------------------------------------------------------------
  // Phone layout
  // -------------------------------------------------------------------------

  Widget _buildPhoneLayout(GeneratorState state, GeneratorNotifier notifier) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _ContentTypeChips(
            selected: state.contentType,
            onTap: notifier.setContentType,
          ),
          const SizedBox(height: 12),
          if (state.contentType.isStructured)
            StructuredInputForm(
              contentType: state.contentType,
              onChanged: (content) => _onStructuredChanged(content, notifier),
            )
          else
            TextField(
              decoration: InputDecoration(
                labelText: context.l10n.input_label,
                hintText: context.l10n.input_hint,
                border: const OutlineInputBorder(),
              ),
              maxLines: 4,
              onChanged: (v) {
                notifier.setRawInput(v);
              },
              controller: _textController,
            ),
          if (state.detectedType != null &&
              state.detectedType != ContentType.plainText &&
              state.detectedType != state.contentType) ...[
            const SizedBox(height: 8),
            Text(
              'Auto-detected: ${state.detectedType!.label}',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.primary,
              ),
            ),
          ],
          if (state.errorKey != null) ...[
            const SizedBox(height: 8),
            ErrorBanner(
              message: context.l10nLookup(state.errorKey!),
              onDismiss: () {},
            ),
          ],
          const SizedBox(height: 20),
          Center(
            child: QrPreviewWidget(
              result: state.lastResult,
              size: 280,
            ),
          ),
          const SizedBox(height: 20),
          _FormatSelector(
            selected: state.format,
            onChanged: notifier.setFormat,
          ),
          const SizedBox(height: 16),
          _ActionButtons(state: state, notifier: notifier),
          const SizedBox(height: 24),
          _CustomizeSection(
            expanded: _showCustomize,
            onToggle: () => setState(() => _showCustomize = !_showCustomize),
            design: state.design,
            onChanged: notifier.setDesign,
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Tablet layout
  // -------------------------------------------------------------------------

  Widget _buildTabletLayout(GeneratorState state, GeneratorNotifier notifier) {
    return SafeArea(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _ContentTypeChips(
                  selected: state.contentType,
                  onTap: notifier.setContentType,
                ),
                const SizedBox(height: 12),
                if (state.contentType.isStructured)
                  StructuredInputForm(
                    contentType: state.contentType,
                    onChanged: (c) => _onStructuredChanged(c, notifier),
                  )
                else
                  TextField(
                    decoration: InputDecoration(
                      labelText: context.l10n.input_label,
                      hintText: context.l10n.input_hint,
                    ),
                    maxLines: 6,
                    onChanged: (v) {
                      notifier.setRawInput(v);
                    },
                    controller: _textController,
                  ),
                if (state.errorKey != null) ...[
                  const SizedBox(height: 8),
                  ErrorBanner(message: context.l10nLookup(state.errorKey!)),
                ],
                const SizedBox(height: 16),
                _FormatSelector(
                  selected: state.format,
                  onChanged: notifier.setFormat,
                ),
                const SizedBox(height: 24),
                _CustomizeSection(
                  expanded: true,
                  onToggle: () {},
                  design: state.design,
                  onChanged: notifier.setDesign,
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            flex: 4,
            child: Column(
              children: [
                const SizedBox(height: 24),
                QrPreviewWidget(result: state.lastResult, size: 320),
                const SizedBox(height: 24),
                _ActionButtons(state: state, notifier: notifier),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  void _onStructuredChanged(
    BarcodeContent content,
    GeneratorNotifier notifier,
  ) {
    // Manually push the structured content into state via design+raw.
    notifier.setRawInput(content.raw);
  }
}

// -------------------------------------------------------------------------
// Sub-widgets
// -------------------------------------------------------------------------

class _ContentTypeChips extends StatelessWidget {
  const _ContentTypeChips({required this.selected, required this.onTap});
  final ContentType selected;
  final ValueChanged<ContentType> onTap;

  @override
  Widget build(BuildContext context) {
    final types = ContentType.values.where(
      (t) => t != ContentType.clipboard,
    ); // clipboard is a source, not a type
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: types.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final t = types.elementAt(i);
          return ContentTypeChip(
            type: t,
            selected: t == selected,
            onTap: () => onTap(t),
          );
        },
      ),
    );
  }
}

class _FormatSelector extends StatelessWidget {
  const _FormatSelector({required this.selected, required this.onChanged});
  final BarcodeFormat selected;
  final ValueChanged<BarcodeFormat> onChanged;

  @override
  Widget build(BuildContext context) {
    const formats = BarcodeFormat.values;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: formats.map((f) {
        return ChoiceChip(
          label: Text(f.label),
          selected: f == selected,
          onSelected: (_) => onChanged(f),
        );
      }).toList(),
    );
  }
}

class _ActionButtons extends ConsumerStatefulWidget {
  const _ActionButtons({required this.state, required this.notifier});
  final GeneratorState state;
  final GeneratorNotifier notifier;

  @override
  ConsumerState<_ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends ConsumerState<_ActionButtons> {
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final notifier = widget.notifier;
    final hasResult = state.lastResult != null;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        FilledButton.icon(
          onPressed: state.isGenerating
              ? null
              : () async {
                  await notifier.generate();
                },
          icon: state.isGenerating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.play_arrow),
          label: Text(context.l10n.action_generate),
        ),
        FilledButton.tonalIcon(
          onPressed: hasResult
              ? () async {
                  final ok = await notifier.save();
                  if (context.mounted) {
                    final updatedState = ref.read(generatorStateProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          ok
                              ? context.l10n.snackbar_saved
                              : (updatedState.isDuplicate
                                  ? context.l10n.history_duplicateWarning
                                  : context.l10n.error_save_failed),
                        ),
                      ),
                    );
                  }
                }
              : null,
          icon: const Icon(Icons.save_outlined),
          label: Text(context.l10n.action_save),
        ),
        FilledButton.tonalIcon(
          onPressed: hasResult
              ? () {
                  Clipboard.setData(ClipboardData(text: state.content.encoded));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.l10n.snackbar_copied),
                    ),
                  );
                }
              : null,
          icon: const Icon(Icons.copy_outlined),
          label: Text(context.l10n.action_copy),
        ),
        FilledButton.tonalIcon(
          onPressed: hasResult
              ? () async {
                  final bytes = state.lastResult!.imageBytes;
                  final tmpDir = await getTemporaryDirectory();
                  final file = File('${tmpDir.path}/qr_share.png');
                  await file.writeAsBytes(bytes);
                  await Share.shareXFiles(
                    [XFile(file.path, mimeType: 'image/png')],
                    text: state.content.encoded,
                  );
                }
              : null,
          icon: const Icon(Icons.share_outlined),
          label: Text(context.l10n.action_share),
        ),
        PopupMenuButton<ExportFormat>(
          icon: _isExporting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download_outlined),
          tooltip: context.l10n.action_export,
          enabled: !_isExporting,
          onSelected: (fmt) async {
            if (state.lastResult == null) return;
            setState(() => _isExporting = true);
            final useCase = ExportUseCase();
            try {
              switch (fmt) {
                case ExportFormat.png:
                  final r =
                      await useCase.exportPng(state.lastResult!.imageBytes);
                  if (context.mounted) _showExportResult(context, r);
                case ExportFormat.svg:
                  final svg = await ServiceLocator.instance.generationService
                      .generateSvg(state.request);
                  if (context.mounted) {
                    svg.fold(
                      onLeft: (Failure f) =>
                          _showExportError(context, f.message),
                      onRight: (String s) async {
                        final r = await useCase.exportSvg(s);
                        if (context.mounted) _showExportResult(context, r);
                      },
                    );
                  }
                case ExportFormat.pdf:
                  final r = await useCase.exportPdf(
                    images: [state.lastResult!.imageBytes],
                    labels: [state.content.displayName],
                  );
                  if (context.mounted) _showExportResult(context, r);
                case ExportFormat.highRes:
                  final r =
                      await useCase.exportHighRes(state.request, size: 8192);
                  if (context.mounted) _showExportResult(context, r);
              }
            } finally {
              if (mounted) setState(() => _isExporting = false);
            }
          },
          itemBuilder: (_) => ExportFormat.values
              .map(
                (f) => PopupMenuItem(
                  value: f,
                  child: Row(
                    children: [
                      Icon(_exportIcon(f)),
                      const SizedBox(width: 8),
                      Text(f.label),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
        IconButton(
          onPressed: hasResult
              ? () async {
                  await ExportUseCase().printImage(
                    state.lastResult!.imageBytes,
                    label: state.content.displayName,
                  );
                }
              : null,
          icon: const Icon(Icons.print_outlined),
          tooltip: context.l10n.action_print,
        ),
      ],
    );
  }

  IconData _exportIcon(ExportFormat f) {
    switch (f) {
      case ExportFormat.png:
        return Icons.image_outlined;
      case ExportFormat.svg:
        return Icons.code;
      case ExportFormat.pdf:
        return Icons.picture_as_pdf_outlined;
      case ExportFormat.highRes:
        return Icons.high_quality_outlined;
    }
  }

  void _showExportResult(BuildContext context, Either<Failure, String> r) {
    if (!context.mounted) return;
    r.fold(
      onLeft: (Failure f) => _showExportError(context, f.message),
      onRight: (String path) {
        // Show only filename, not the full internal path
        final filename = path.split('/').last.split('\\').last;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${context.l10n.snackbar_exported(filename)}'),
            action: SnackBarAction(
              label: 'Share',
              onPressed: () async {
                await Share.shareXFiles([XFile(path)]);
              },
            ),
          ),
        );
      },
    );
  }

  void _showExportError(BuildContext context, String key) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10nLookup(key)),
      ),
    );
  }
}

class _CustomizeSection extends StatelessWidget {
  const _CustomizeSection({
    required this.expanded,
    required this.onToggle,
    required this.design,
    required this.onChanged,
  });

  final bool expanded;
  final VoidCallback onToggle;
  final QrDesign design;
  final ValueChanged<QrDesign> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        initiallyExpanded: expanded,
        onExpansionChanged: (_) => onToggle(),
        leading: const Icon(Icons.palette_outlined),
        title: Text(context.l10n.customization_title),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: CustomizationPanel(design: design, onChanged: onChanged),
          ),
        ],
      ),
    );
  }
}

// Extension for l10n lookup by key (graceful fallback to the key itself).
extension on BuildContext {
  String l10nLookup(String key) {
    try {
      final l = l10n;
      // Call the matching getter via a switch — fallback to the key.
      switch (key) {
        case 'error_empty_input':
          return l.error_empty_input;
        case 'error_invalid_url':
          return l.error_invalid_url;
        case 'error_invalid_email':
          return l.error_invalid_email;
        case 'error_invalid_phone':
          return l.error_invalid_phone;
        case 'error_invalid_product':
          return l.error_invalid_product;
        case 'error_invalid_isbn':
          return l.error_invalid_isbn;
        case 'error_invalid_upc':
          return l.error_invalid_upc;
        case 'error_invalid_ean':
          return l.error_invalid_ean;
        case 'error_invalid_codabar':
          return l.error_invalid_codabar;
        case 'error_invalid_itf':
          return l.error_invalid_itf;
        case 'error_too_long':
          return l.error_too_long;
        case 'error_itf_odd_length':
          return l.error_itf_odd_length;
        case 'error_generation_failed':
          return l.error_generation_failed;
        case 'error_export_failed':
          return l.error_export_failed;
        case 'error_save_failed':
          return l.error_save_failed;
        case 'error_unknown':
          return l.error_unknown;
        default:
          return key;
      }
    } catch (_) {
      return key;
    }
  }
}
