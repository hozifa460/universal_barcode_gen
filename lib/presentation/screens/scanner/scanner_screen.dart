// ScannerScreen: real-time camera scanner + image import + scan history.
//
// Uses mobile_scanner's MobileScanner widget embedded directly.
// Supports:
//   - Start/Stop camera
//   - Flashlight toggle
//   - Continuous mode toggle
//   - Image import (single + multi-code detection)
//   - Auto-open URLs (with confirmation)
//   - Copy / Share / Save to history
//   - Scan history access (bottom sheet)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/barcode_format.dart' as app_fmt;
import '../../../core/constants/content_type.dart';
import '../../../core/errors/failures.dart';
import '../../../core/extensions/build_context.dart';
import '../../../core/utils/service_locator.dart';
import '../../../core/validators/content_detector.dart';
import '../../../domain/entities/scan_result.dart';
import '../../providers/scanner_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_banner.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen>
    with WidgetsBindingObserver {
  late MobileScannerController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
      formats: const [
        BarcodeFormat.aztec,
        BarcodeFormat.codabar,
        BarcodeFormat.code39,
        BarcodeFormat.code93,
        BarcodeFormat.code128,
        BarcodeFormat.dataMatrix,
        BarcodeFormat.ean8,
        BarcodeFormat.ean13,
        BarcodeFormat.itf,
        BarcodeFormat.pdf417,
        BarcodeFormat.qrCode,
        BarcodeFormat.upcA,
        BarcodeFormat.upcE,
      ],
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.value.isInitialized) return;
    switch (state) {
      case AppLifecycleState.resumed:
        _controller.start();
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _controller.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final scannerNotifier = ref.read(scannerStateProvider.notifier);
    final isContinuous = ref.read(scannerStateProvider).isContinuous;
    for (final bc in capture.barcodes) {
      final raw = bc.rawValue;
      if (raw == null) continue;
      final detected = ContentDetector.detect(raw);
      final format = _mapFormat(bc.format);
      final result = ScanResult(
        id: '${DateTime.now().microsecondsSinceEpoch}_${bc.format.name}',
        rawValue: raw,
        format: format,
        detectedType: detected,
        scannedAt: DateTime.now(),
      );
      scannerNotifier.saveResult(result);
      _maybeAutoOpenUrl(raw);
      if (!isContinuous) {
        _controller.stop();
        break;
      }
    }
  }

  void _maybeAutoOpenUrl(String raw) {
    final settings = ref.read(settingsProvider).valueOrNull;
    if (settings?.autoOpenUrls != true) return;
    final detected = ContentDetector.detect(raw);
    if (detected == ContentType.url) {
      ConfirmDialog.show(
        context,
        title: context.l10n.dialog_openUrlTitle,
        message: '${context.l10n.dialog_openUrlMessage}\n\n$raw',
      ).then((ok) {
        if (ok) launchUrl(Uri.parse(raw));
      });
    }
  }

  app_fmt.BarcodeFormat _mapFormat(BarcodeFormat fmt) {
    switch (fmt) {
      case BarcodeFormat.aztec:
        return app_fmt.BarcodeFormat.aztec;
      case BarcodeFormat.codabar:
        return app_fmt.BarcodeFormat.codabar;
      case BarcodeFormat.code39:
        return app_fmt.BarcodeFormat.code39;
      case BarcodeFormat.code93:
        return app_fmt.BarcodeFormat.code93;
      case BarcodeFormat.code128:
        return app_fmt.BarcodeFormat.code128;
      case BarcodeFormat.dataMatrix:
        return app_fmt.BarcodeFormat.dataMatrix;
      case BarcodeFormat.ean8:
        return app_fmt.BarcodeFormat.ean8;
      case BarcodeFormat.ean13:
        return app_fmt.BarcodeFormat.ean13;
      case BarcodeFormat.itf:
        return app_fmt.BarcodeFormat.itf;
      case BarcodeFormat.pdf417:
        return app_fmt.BarcodeFormat.pdf417;
      case BarcodeFormat.qrCode:
        return app_fmt.BarcodeFormat.qr;
      case BarcodeFormat.upcA:
        return app_fmt.BarcodeFormat.upcA;
      case BarcodeFormat.upcE:
        return app_fmt.BarcodeFormat.upcE;
      default:
        return app_fmt.BarcodeFormat.qr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scannerState = ref.watch(scannerStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.tabScanner),
        actions: [
          IconButton(
            icon: Icon(
              scannerState.isFlashOn ? Icons.flash_on : Icons.flash_off,
            ),
            onPressed: () {
              _controller.toggleTorch();
              ref.read(scannerStateProvider.notifier).toggleFlash();
            },
            tooltip: context.l10n.scanner_flashOn,
          ),
          IconButton(
            icon: Icon(
              scannerState.isContinuous ? Icons.repeat_one : Icons.repeat,
            ),
            onPressed: () =>
                ref.read(scannerStateProvider.notifier).toggleContinuous(),
            tooltip: context.l10n.scanner_continuous,
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showScanHistory(context),
            tooltip: context.l10n.scanHistory_title,
          ),
        ],
      ),
      body: Column(
        children: [
          if (scannerState.errorKey != null)
            ErrorBanner(
              message: scannerState.errorKey == 'error_camera_permission'
                  ? context.l10n.error_camera_permission
                  : scannerState.errorKey!,
              onDismiss: () {
                ref.read(scannerStateProvider.notifier).clearError();
              },
            ),
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                MobileScanner(
                  controller: _controller,
                  onDetect: _onDetect,
                  errorBuilder: (ctx, error, child) => Center(
                    child: EmptyState(
                      icon: Icons.camera_alt_outlined,
                      title: context.l10n.error_camera_permission,
                      subtitle: error.toString(),
                    ),
                  ),
                ),
                // Scan overlay.
                _ScanOverlay(),
                // Detected banner.
                if (scannerState.lastResult != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _DetectedBanner(
                      result: scannerState.lastResult!,
                      onResume: () => _controller.start(),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    context.l10n.scanner_empty,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: () async {
                          final picker = ImagePicker();
                          final xfile = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (xfile != null) {
                            final r = await ServiceLocator
                                .instance.scannerService
                                .detectFromFile(xfile.path);
                            if (!context.mounted) return;
                            r.fold(
                              onLeft: (Failure f) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(f.message)),
                                );
                              },
                              onRight: (List<ScanResult> results) {
                                if (results.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        context.l10n.scanner_noCodesFound,
                                      ),
                                    ),
                                  );
                                } else {
                                  for (final res in results) {
                                    ref
                                        .read(scannerStateProvider.notifier)
                                        .saveResult(res);
                                  }
                                }
                              },
                            );
                          }
                        },
                        icon: const Icon(Icons.photo_outlined),
                        label: Text(context.l10n.scanner_importImage),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showScanHistory(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => const _ScanHistorySheet(),
    );
  }
}

class _ScanOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        Colors.black.withValues(alpha: 0.4),
        BlendMode.srcOut,
      ),
      child: Stack(
        children: [
          Center(
            child: Container(
              height: 250,
              width: 250,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetectedBanner extends StatelessWidget {
  const _DetectedBanner({required this.result, required this.onResume});
  final ScanResult result;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  result.rawValue,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${result.format.label} • ${result.detectedType.label}',
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimaryContainer
                        .withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: result.rawValue));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.l10n.snackbar_copied)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            onPressed: () => Share.share(result.rawValue),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            tooltip: 'Scan again',
            onPressed: onResume,
          ),
        ],
      ),
    );
  }
}

class _ScanHistorySheet extends ConsumerWidget {
  const _ScanHistorySheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncHistory = ref.watch(scanHistoryProvider);
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            AppBar(
              title: Text(context.l10n.scanHistory_title),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined),
                  onPressed: () async {
                    final ok = await ConfirmDialog.show(
                      context,
                      title: context.l10n.dialog_clearHistoryTitle,
                      message: context.l10n.dialog_deleteMessage,
                      isDestructive: true,
                    );
                    if (ok) {
                      await ref.read(scannerStateProvider.notifier).clearAll();
                    }
                  },
                ),
              ],
            ),
            Expanded(
              child: asyncHistory.when(
                data: (items) {
                  if (items.isEmpty) {
                    return EmptyState(
                      icon: Icons.history,
                      title: context.l10n.scanHistory_empty,
                    );
                  }
                  return ListView.separated(
                    controller: scrollController,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final r = items[i];
                      return ListTile(
                        leading: Icon(_typeIcon(r.detectedType)),
                        title: Text(
                          r.rawValue,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle:
                            Text('${r.format.label} • ${_time(r.scannedAt)}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => ref
                              .read(scannerStateProvider.notifier)
                              .deleteResult(r.id),
                        ),
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: r.rawValue));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(context.l10n.snackbar_copied)),
                          );
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text(e.toString())),
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _typeIcon(ContentType t) {
    switch (t) {
      case ContentType.url:
        return Icons.language;
      case ContentType.email:
        return Icons.email;
      case ContentType.phone:
        return Icons.phone;
      case ContentType.wifi:
        return Icons.wifi;
      case ContentType.vcard:
        return Icons.contact_page;
      default:
        return Icons.qr_code_2;
    }
  }

  String _time(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
