// SettingsScreen: appearance, language, defaults, storage, about.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/build_context.dart';
import '../../../domain/usecases/settings_usecases.dart';
import '../../providers/app_providers.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/confirm_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settings_title)),
      body: settingsAsync.when(
        data: (settings) => ListView(
          children: [
            _SectionHeader(text: context.l10n.settings_appearance),
            _ThemeTile(ref: ref),
            _LocaleTile(ref: ref),
            const Divider(),
            _SectionHeader(text: context.l10n.settings_defaultEc),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 8,
                children: ErrorCorrectionLevel.values.map((e) {
                  return ChoiceChip(
                    label: Text(e.label),
                    selected: settings.defaultErrorCorrection == e,
                    onSelected: (_) =>
                        settingsNotifier.setEcLevel(e),
                  );
                }).toList(),
              ),
            ),
            const Divider(),
            const _SectionHeader(text: 'Behavior'),
            SwitchListTile(
              title: Text(context.l10n.settings_clipboardMonitor),
              subtitle: Text(context.l10n.settings_privacyNotice),
              value: settings.clipboardMonitor,
              onChanged: settingsNotifier.setClipboardMonitor,
            ),
            SwitchListTile(
              title: Text(context.l10n.settings_autoOpenUrls),
              value: settings.autoOpenUrls,
              onChanged: settingsNotifier.setAutoOpenUrls,
            ),
            SwitchListTile(
              title: const Text('Continuous scan'),
              value: settings.continuousScan,
              onChanged: settingsNotifier.setContinuousScan,
            ),
            SwitchListTile(
              title: const Text('Flashlight default on'),
              value: settings.flashlightDefault,
              onChanged: settingsNotifier.setFlashlightDefault,
            ),
            const Divider(),
            _SectionHeader(text: context.l10n.settings_storage),
            ListTile(
              leading: const Icon(Icons.upload_outlined),
              title: Text(context.l10n.settings_exportBackup),
              onTap: () => _exportBackup(context),
            ),
            ListTile(
              leading: const Icon(Icons.download_outlined),
              title: Text(context.l10n.settings_importBackup),
              onTap: () => _importBackup(context),
            ),
            ListTile(
              leading: Icon(Icons.delete_forever,
                  color: Theme.of(context).colorScheme.error,),
              title: Text(context.l10n.settings_clearData),
              textColor: Theme.of(context).colorScheme.error,
              onTap: () => _clearData(context),
            ),
            const Divider(),
            _SectionHeader(text: context.l10n.settings_about),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(context.l10n.appTitle),
              subtitle: Text('${context.l10n.settings_version}: ${AppConstants.appVersion}'),
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Privacy'),
              subtitle: Text(context.l10n.settings_privacyNotice),
            ),
            const SizedBox(height: 32),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }

  Future<void> _exportBackup(BuildContext context) async {
    final r = await ExportBackupUseCase().call();
    r.fold(
      onLeft: (f) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(f.message)),
      ),
      onRight: (data) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.snackbar_saved)),
        );
      },
    );
  }

  Future<void> _importBackup(BuildContext context) async {
    // For demo: would normally show a file picker. We just show a snackbar.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.settings_importBackup)),
    );
  }

  Future<void> _clearData(BuildContext context) async {
    final ok = await ConfirmDialog.show(
      context,
      title: context.l10n.settings_clearData,
      message: context.l10n.dialog_deleteMessage,
      isDestructive: true,
    );
    if (ok) {
      await ClearAllDataUseCase().call();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.snackbar_deleted)),
        );
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _ThemeTile extends ConsumerWidget {
  const _ThemeTile({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return ListTile(
      leading: const Icon(Icons.dark_mode_outlined),
      title: Text(context.l10n.settings_darkMode),
      trailing: SegmentedButton<ThemeMode>(
        segments: [
          ButtonSegment(
            value: ThemeMode.light,
            icon: const Icon(Icons.light_mode_outlined),
            label: Text(context.l10n.theme_light),
          ),
          ButtonSegment(
            value: ThemeMode.system,
            icon: const Icon(Icons.settings_brightness_outlined),
            label: Text(context.l10n.theme_system),
          ),
          ButtonSegment(
            value: ThemeMode.dark,
            icon: const Icon(Icons.dark_mode_outlined),
            label: Text(context.l10n.theme_dark),
          ),
        ],
        selected: {mode},
        onSelectionChanged: (s) =>
            ref.read(themeModeProvider.notifier).set(s.first),
      ),
    );
  }
}

class _LocaleTile extends ConsumerWidget {
  const _LocaleTile({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(context.l10n.settings_language),
      trailing: SegmentedButton<Locale>(
        segments: [
          ButtonSegment(
            value: const Locale('en'),
            label: Text(context.l10n.language_english),
          ),
          ButtonSegment(
            value: const Locale('ar'),
            label: Text(context.l10n.language_arabic),
          ),
        ],
        selected: {locale},
        onSelectionChanged: (s) =>
            ref.read(localeProvider.notifier).set(s.first),
      ),
    );
  }
}
