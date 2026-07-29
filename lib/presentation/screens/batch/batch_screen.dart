// BatchScreen: bulk generation from CSV/Excel/text input.
//
// Flow:
//   1. Import CSV / Excel / paste text
//   2. Preview list of items (one per line/row)
//   3. Pick format + design
//   4. Generate all
//   5. Export: PNG zip / PDF / batch image save
//
// File picker uses image_picker's XFile companion for non-image files
// (delegates to file_selector or a simple platform channel).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/barcode_format.dart';
import '../../../core/constants/content_type.dart';
import '../../../core/errors/failures.dart';
import '../../../core/extensions/build_context.dart';
import '../../../core/utils/service_locator.dart';
import '../../../domain/entities/barcode_content.dart';
import '../../../domain/entities/batch_item.dart';
import '../../../domain/entities/generation_request.dart';
import '../../../domain/entities/qr_design.dart';
import '../../../domain/usecases/export_usecase.dart';
import '../../providers/batch_provider.dart';
import '../../providers/generator_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/loading_overlay.dart';
import '../generator/customization_panel.dart';

class BatchScreen extends ConsumerStatefulWidget {
  const BatchScreen({super.key});

  @override
  ConsumerState<BatchScreen> createState() => _BatchScreenState();
}

class _BatchScreenState extends ConsumerState<BatchScreen> {
  final _textController = TextEditingController();
  final bool _showDesign = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(batchStateProvider);
    final notifier = ref.read(batchStateProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.tabBatch),
        actions: [
          if (state.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: notifier.clear,
              tooltip: context.l10n.batch_clear,
            ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: state.isProcessing,
        message: '${context.l10n.batch_title}…',
        child: state.items.isEmpty
            ? _EmptyState(
                textController: _textController,
                onImportCsv: () => _importCsv(context, notifier),
                onImportExcel: () => _importExcel(context, notifier),
                onAddText: () {
                  if (_textController.text.isNotEmpty) {
                    notifier.addFromText(_textController.text);
                    _textController.clear();
                  }
                },
              )
            : _BatchList(state: state, notifier: notifier),
      ),
      floatingActionButton: state.items.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _generateAll(context, notifier),
              icon: const Icon(Icons.play_arrow),
              label: Text(context.l10n.action_generate),
            )
          : null,
    );
  }

  Future<void> _importCsv(
    BuildContext context,
    BatchNotifier notifier,
  ) async {
    // Use a simple text input dialog as a fallback when no platform file picker.
    final path = await _showPathInputDialog(context, 'CSV');
    if (path != null) {
      await notifier.importCsv(path);
      if (mounted && ref.read(batchStateProvider).errorKey != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.error_file_import_failed)),
        );
      }
    }
  }

  Future<void> _importExcel(
    BuildContext context,
    BatchNotifier notifier,
  ) async {
    final path = await _showPathInputDialog(context, 'Excel');
    if (path != null) {
      await notifier.importExcel(path);
    }
  }

  Future<String?> _showPathInputDialog(
    BuildContext context,
    String label,
  ) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Import $label'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'File path',
            hintText: '/path/to/file',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.action_cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: Text(context.l10n.action_import),
          ),
        ],
      ),
    );
  }

  Future<void> _generateAll(
      BuildContext context, BatchNotifier notifier) async {
    final design = ref.read(generatorStateProvider).design;
    await notifier.generateAll(design);
    if (!mounted) return;
    final state = ref.read(batchStateProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.l10n.batch_generated(state.generatedCount),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------------
// Empty state with import options
// -------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.textController,
    required this.onImportCsv,
    required this.onImportExcel,
    required this.onAddText,
  });

  final TextEditingController textController;
  final VoidCallback onImportCsv;
  final VoidCallback onImportExcel;
  final VoidCallback onAddText;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EmptyState(
            icon: Icons.layers_outlined,
            title: context.l10n.batch_empty,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: onImportCsv,
                  icon: const Icon(Icons.table_chart_outlined),
                  label: Text(context.l10n.batch_importCsv),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: onImportExcel,
                  icon: const Icon(Icons.file_present_outlined),
                  label: Text(context.l10n.batch_importExcel),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            context.l10n.input_label,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: textController,
            maxLines: 8,
            decoration: InputDecoration(
              hintText: context.l10n.batch_empty,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: FilledButton.icon(
              onPressed: onAddText,
              icon: const Icon(Icons.add),
              label: Text(context.l10n.action_addFolder),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------------------
// Batch list
// -------------------------------------------------------------------------

class _BatchList extends ConsumerStatefulWidget {
  const _BatchList({required this.state, required this.notifier});
  final BatchState state;
  final BatchNotifier notifier;

  @override
  ConsumerState<_BatchList> createState() => _BatchListState();
}

class _BatchListState extends ConsumerState<_BatchList> {
  bool _showDesign = false;

  @override
  Widget build(BuildContext context) {
    final items = widget.state.items;
    return Column(
      children: [
        // Summary bar.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          child: Row(
            children: [
              Text(
                context.l10n.batch_generated(widget.state.generatedCount),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              if (widget.state.failedCount > 0)
                Text(
                  '${widget.state.failedCount} failed',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.palette_outlined),
                onPressed: () => setState(() => _showDesign = !_showDesign),
                tooltip: context.l10n.customization_title,
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.download_outlined),
                onSelected: (action) => _handleExport(context, action),
                itemBuilder: (_) => [
                  PopupMenuItem(
                      value: 'png', child: Text(context.l10n.batch_exportPng)),
                  PopupMenuItem(
                      value: 'pdf', child: Text(context.l10n.batch_exportPdf)),
                ],
              ),
            ],
          ),
        ),
        if (_showDesign)
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            child: CustomizationPanel(
              design: ref.watch(generatorStateProvider).design,
              onChanged: (d) =>
                  ref.read(generatorStateProvider.notifier).setDesign(d),
            ),
          ),
        if (widget.state.errorKey != null)
          ErrorBanner(message: widget.state.errorKey!),
        Expanded(
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final item = items[i];
              return ListTile(
                leading: _StatusIcon(status: item.status),
                title: Text(
                  item.input,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  item.label ?? item.format.label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButton<BarcodeFormat>(
                      value: item.format,
                      underline: const SizedBox.shrink(),
                      items: BarcodeFormat.values
                          .map(
                            (f) => DropdownMenuItem(
                              value: f,
                              child: Text(f.label),
                            ),
                          )
                          .toList(),
                      onChanged: (f) {
                        if (f == null) return;
                        widget.notifier.updateFormat(item.id, f);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => widget.notifier.removeItem(item.id),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _handleExport(BuildContext context, String action) async {
    final state = widget.state;
    final design = ref.read(generatorStateProvider).design;
    final generatedItems = state.items
        .where((i) => i.status == BatchItemStatus.generated)
        .toList();
    if (generatedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.error_export_failed)),
      );
      return;
    }
    final exportUseCase = ExportUseCase();
    final images = <List<int>>[];
    final labels = <String>[];
    for (final item in generatedItems) {
      final req = await ServiceLocator.instance.generationService.generate(
        // Build a GenerationRequest from the batch item.
        // We use the same design for all items.
        _buildRequest(item, design),
      );
      req.fold(
        onLeft: (Failure f) {},
        onRight: (GenerationResult r) {
          images.add(r.imageBytes);
          labels.add(item.label ?? item.input);
        },
      );
    }
    if (images.isEmpty) return;
    if (action == 'pdf') {
      final r = await exportUseCase.exportPdf(images: images, labels: labels);
      r.fold(
        onLeft: (Failure f) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(f.message)),
        ),
        onRight: (String path) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.snackbar_exported(path))),
        ),
      );
    } else {
      // PNG batch export — save each.
      for (var i = 0; i < images.length; i++) {
        await exportUseCase.exportPng(
          images[i],
          filename:
              'batch_${i.toString().padLeft(3, '0')}_${labels[i].replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}.png',
        );
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${images.length} PNGs exported')),
        );
      }
    }
  }

  GenerationRequest _buildRequest(BatchItem item, QrDesign design) {
    // Local import to avoid circular dep.
    return GenerationRequest(
      content: BarcodeContent(
        type: item.contentType ?? ContentType.plainText,
        raw: item.input,
      ),
      format: item.format,
      design: design,
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status});
  final BatchItemStatus status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case BatchItemStatus.pending:
        return const Icon(Icons.hourglass_empty, color: Colors.grey);
      case BatchItemStatus.generated:
        return Icon(Icons.check_circle,
            color: Theme.of(context).colorScheme.primary);
      case BatchItemStatus.failed:
        return Icon(Icons.error, color: Theme.of(context).colorScheme.error);
    }
  }
}
