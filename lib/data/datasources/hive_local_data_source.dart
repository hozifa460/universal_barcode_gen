// HiveLocalDataSource: thin wrapper around Hive boxes for typed CRUD.
// Stores JSON-encoded entities (avoids Hive type adapters complexity).

import 'dart:convert';

import 'package:hive/hive.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/either.dart';
import '../../../core/errors/exceptions.dart';
import '../../../domain/entities/app_settings.dart';
import '../../../domain/entities/design_preset.dart';
import '../../../domain/entities/folder.dart';
import '../../../domain/entities/history_entry.dart';
import '../../../domain/entities/scan_result.dart';
import '../../../domain/entities/template.dart';

class HiveLocalDataSource {
  HiveLocalDataSource._();

  static final HiveLocalDataSource instance = HiveLocalDataSource._();

  Box<dynamic>? _history;
  Box<dynamic>? _folders;
  Box<dynamic>? _tags;
  Box<dynamic>? _favorites;
  Box<dynamic>? _presets;
  Box<dynamic>? _scanHistory;
  Box<dynamic>? _templates;
  Box<dynamic>? _settings;

  Future<void> _ensureBoxes() async {
    _history ??= await Hive.openBox(AppConstants.historyBox);
    _folders ??= await Hive.openBox(AppConstants.foldersBox);
    _tags ??= await Hive.openBox(AppConstants.tagsBox);
    _favorites ??= await Hive.openBox(AppConstants.favoritesBox);
    _presets ??= await Hive.openBox(AppConstants.presetsBox);
    _scanHistory ??= await Hive.openBox(AppConstants.scanHistoryBox);
    _templates ??= await Hive.openBox(AppConstants.templatesBox);
    _settings ??= await Hive.openBox(AppConstants.settingsBox);
  }

  // ---------------------------------------------------------------------------
  // History
  // ---------------------------------------------------------------------------

  Future<Result<HistoryEntry>> saveHistoryEntry(HistoryEntry entry) async {
    try {
      await _ensureBoxes();
      await _history!.put(entry.id, jsonEncode(entry.toJson()));
      if (entry.isFavorite) {
        await _favorites!.put(entry.id, true);
      } else {
        await _favorites!.delete(entry.id);
      }
      return Either.right(entry);
    } catch (e, s) {
      return Either.left(ExceptionMapper.map(e, s));
    }
  }

  Future<Result<List<HistoryEntry>>> getAllHistory() async {
    try {
      await _ensureBoxes();
      final entries = <HistoryEntry>[];
      for (final key in _history!.keys) {
        final raw = _history!.get(key) as String?;
        if (raw == null) continue;
        final json = jsonDecode(raw) as Map<String, dynamic>;
        entries.add(HistoryEntry.fromJson(json));
      }
      entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return Either.right(entries);
    } catch (e, s) {
      return Either.left(ExceptionMapper.map(e, s));
    }
  }

  Future<Result<HistoryEntry?>> getHistoryEntry(String id) async {
    try {
      await _ensureBoxes();
      final raw = _history!.get(id) as String?;
      if (raw == null) return Either.right(null);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return Either.right(HistoryEntry.fromJson(json));
    } catch (e, s) {
      return Either.left(ExceptionMapper.map(e, s));
    }
  }

  Future<Result<void>> deleteHistoryEntry(String id) async {
    try {
      await _ensureBoxes();
      await _history!.delete(id);
      await _favorites!.delete(id);
      return Either.right(null);
    } catch (e, s) {
      return Either.left(ExceptionMapper.map(e, s));
    }
  }

  Future<Result<void>> clearAllHistory() async {
    try {
      await _ensureBoxes();
      await _history!.clear();
      await _favorites!.clear();
      return Either.right(null);
    } catch (e, s) {
      return Either.left(ExceptionMapper.map(e, s));
    }
  }

  Future<Result<bool>> isFavorite(String id) async {
    try {
      await _ensureBoxes();
      return Either.right(_favorites!.get(id) as bool? ?? false);
    } catch (e, s) {
      return Either.left(ExceptionMapper.map(e, s));
    }
  }

  Future<Result<List<String>>> getAllFavoriteIds() async {
    try {
      await _ensureBoxes();
      final ids = _favorites!.keys.cast<String>().toList();
      return Either.right(ids);
    } catch (e, s) {
      return Either.left(ExceptionMapper.map(e, s));
    }
  }

  // ---------------------------------------------------------------------------
  // Folders
  // ---------------------------------------------------------------------------

  Future<Result<Folder>> saveFolder(Folder folder) async {
    try {
      await _ensureBoxes();
      await _folders!.put(folder.id, jsonEncode(folder.toJson()));
      return Either.right(folder);
    } catch (e, s) {
      return Either.left(ExceptionMapper.map(e, s));
    }
  }

  Future<Result<List<Folder>>> getAllFolders() async {
    try {
      await _ensureBoxes();
      final items = <Folder>[];
      for (final key in _folders!.keys) {
        final raw = _folders!.get(key) as String?;
        if (raw == null) continue;
        items.add(Folder.fromJson(jsonDecode(raw) as Map<String, dynamic>));
      }
      items.sort((a, b) => a.name.compareTo(b.name));
      return Either.right(items);
    } catch (e, s) {
      return Either.left(ExceptionMapper.map(e, s));
    }
  }

  Future<Result<void>> deleteFolder(String id) async {
    try {
      await _ensureBoxes();
      await _folders!.delete(id);
      return Either.right(null);
    } catch (e, s) {
      return Either.left(ExceptionMapper.map(e, s));
    }
  }

  // ---------------------------------------------------------------------------
  // Tags
  // ---------------------------------------------------------------------------

  Future<Result<Tag>> saveTag(Tag tag) async {
    try {
      await _ensureBoxes();
      await _tags!.put(tag.id, jsonEncode(tag.toJson()));
      return Either.right(tag);
    } catch (e, s) {
      return Either.left(ExceptionMapper.map(e, s));
    }
  }

  Future<Result<List<Tag>>> getAllTags() async {
    try {
      await _ensureBoxes();
      final items = <Tag>[];
      for (final key in _tags!.keys) {
        final raw = _tags!.get(key) as String?;
        if (raw == null) continue;
        items.add(Tag.fromJson(jsonDecode(raw) as Map<String, dynamic>));
      }
      items.sort((a, b) => a.name.compareTo(b.name));
      return Either.right(items);
    } catch (e, s) {
      return Either.left(ExceptionMapper.map(e, s));
    }
  }

  Future<Result<void>> deleteTag(String id) async {
    try {
      await _ensureBoxes();
      await _tags!.delete(id);
      return Either.right(null);
    } catch (e, s) {
      return Either.left(ExceptionMapper.map(e, s));
    }
  }

  // ---------------------------------------------------------------------------
  // Scan History
  // ---------------------------------------------------------------------------

  Future<Result<ScanResult>> saveScanResult(ScanResult result) async {
    try {
      await _ensureBoxes();
      await _scanHistory!.put(result.id, jsonEncode(result.toJson()));
      return Either.right(result);
    } catch (e, s) {
      return Either.left(ExceptionMapper.map(e, s));
    }
  }

  Future<Result<List<ScanResult>>> getAllScanResults() async {
    try {
      await _ensureBoxes();
      final items = <ScanResult>[];
      for (final key in _scanHistory!.keys) {
        final raw = _scanHistory!.get(key) as String?;
        if (raw == null) continue;
        items.add(ScanResult.fromJson(jsonDecode(raw) as Map<String, dynamic>));
      }
      items.sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
      return Either.right(items);
    } catch (e, s) {
      return Either.left(ExceptionMapper.map(e, s));
    }
  }

  Future<Result<void>> deleteScanResult(String id) async {
    try {
      await _ensureBoxes();
      await _scanHistory!.delete(id);
      return Either.right(null);
    } catch (e, s) {
      return Either.left(ExceptionMapper.map(e, s));
    }
  }

  Future<Result<void>> clearScanHistory() async {
    try {
      await _ensureBoxes();
      await _scanHistory!.clear();
      return Either.right(null);
    } catch (e, s) {
      return Either.left(ExceptionMapper.map(e, s));
    }
  }

  // ---------------------------------------------------------------------------
  // Presets
  // ---------------------------------------------------------------------------

  Future<Result<DesignPreset>> savePreset(DesignPreset preset) async {
    try {
      await _ensureBoxes();
      await _presets!.put(preset.id, jsonEncode(preset.toJson()));
      return Either.right(preset);
    } catch (e, s) {
      return Either.left(ExceptionMapper.map(e, s));
    }
  }

  Future<Result<List<DesignPreset>>> getAllPresets() async {
    try {
      await _ensureBoxes();
      final items = <DesignPreset>[];
      for (final key in _presets!.keys) {
        final raw = _presets!.get(key) as String?;
        if (raw == null) continue;
        items
            .add(DesignPreset.fromJson(jsonDecode(raw) as Map<String, dynamic>));
      }
      return Either.right(items);
    } catch (e, s) {
      return Either.left(ExceptionMapper.map(e, s));
    }
  }

  Future<Result<void>> deletePreset(String id) async {
    try {
      await _ensureBoxes();
      await _presets!.delete(id);
      return Either.right(null);
    } catch (e, s) {
      return Either.left(ExceptionMapper.map(e, s));
    }
  }

  // ---------------------------------------------------------------------------
  // Templates
  // ---------------------------------------------------------------------------

  Future<Result<Template>> saveTemplate(Template template) async {
    try {
      await _ensureBoxes();
      await _templates!.put(template.id, jsonEncode(template.toJson()));
      return Either.right(template);
    } catch (e, s) {
      return Either.left(ExceptionMapper.map(e, s));
    }
  }

  Future<Result<List<Template>>> getAllTemplates() async {
    try {
      await _ensureBoxes();
      final items = <Template>[];
      for (final key in _templates!.keys) {
        final raw = _templates!.get(key) as String?;
        if (raw == null) continue;
        items.add(Template.fromJson(jsonDecode(raw) as Map<String, dynamic>));
      }
      items.sort((a, b) =>
          (b.lastUsed ?? DateTime(2000)).compareTo(a.lastUsed ?? DateTime(2000)),);
      return Either.right(items);
    } catch (e, s) {
      return Either.left(ExceptionMapper.map(e, s));
    }
  }

  Future<Result<void>> deleteTemplate(String id) async {
    try {
      await _ensureBoxes();
      await _templates!.delete(id);
      return Either.right(null);
    } catch (e, s) {
      return Either.left(ExceptionMapper.map(e, s));
    }
  }

  // ---------------------------------------------------------------------------
  // Settings
  // ---------------------------------------------------------------------------

  Future<Result<AppSettings>> getSettings() async {
    try {
      await _ensureBoxes();
      final raw = _settings!.get('app_settings') as String?;
      if (raw == null) {
        const def = AppSettings();
        await saveSettings(def);
        return Either.right(def);
      }
      return Either.right(
        AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>),
      );
    } catch (e, s) {
      return Either.left(ExceptionMapper.map(e, s));
    }
  }

  Future<Result<AppSettings>> saveSettings(AppSettings settings) async {
    try {
      await _ensureBoxes();
      await _settings!.put('app_settings', jsonEncode(settings.toJson()));
      return Either.right(settings);
    } catch (e, s) {
      return Either.left(ExceptionMapper.map(e, s));
    }
  }

  // ---------------------------------------------------------------------------
  // Backup / Restore
  // ---------------------------------------------------------------------------

  Future<Result<Map<String, dynamic>>> exportBackup() async {
    try {
      await _ensureBoxes();
      final history = <Map<String, dynamic>>[];
      for (final k in _history!.keys) {
        final raw = _history!.get(k) as String?;
        if (raw != null) history.add(jsonDecode(raw) as Map<String, dynamic>);
      }
      final folders = <Map<String, dynamic>>[];
      for (final k in _folders!.keys) {
        final raw = _folders!.get(k) as String?;
        if (raw != null) folders.add(jsonDecode(raw) as Map<String, dynamic>);
      }
      final tags = <Map<String, dynamic>>[];
      for (final k in _tags!.keys) {
        final raw = _tags!.get(k) as String?;
        if (raw != null) tags.add(jsonDecode(raw) as Map<String, dynamic>);
      }
      final presets = <Map<String, dynamic>>[];
      for (final k in _presets!.keys) {
        final raw = _presets!.get(k) as String?;
        if (raw != null) presets.add(jsonDecode(raw) as Map<String, dynamic>);
      }
      final scanHistory = <Map<String, dynamic>>[];
      for (final k in _scanHistory!.keys) {
        final raw = _scanHistory!.get(k) as String?;
        if (raw != null) scanHistory.add(jsonDecode(raw) as Map<String, dynamic>);
      }
      final templates = <Map<String, dynamic>>[];
      for (final k in _templates!.keys) {
        final raw = _templates!.get(k) as String?;
        if (raw != null) templates.add(jsonDecode(raw) as Map<String, dynamic>);
      }
      final settingsRaw = _settings!.get('app_settings') as String?;

      return Either.right({
        'version': AppConstants.appVersion,
        'exportedAt': DateTime.now().toIso8601String(),
        'history': history,
        'folders': folders,
        'tags': tags,
        'presets': presets,
        'scanHistory': scanHistory,
        'templates': templates,
        'settings': settingsRaw != null
            ? jsonDecode(settingsRaw) as Map<String, dynamic>
            : const AppSettings().toJson(),
      });
    } catch (e, s) {
      return Either.left(ExceptionMapper.map(e, s));
    }
  }

  Future<Result<void>> importBackup(Map<String, dynamic> data) async {
    try {
      if (!data.containsKey('version')) {
        throw const FormatException('Invalid backup format: Missing version key');
      }

      await _ensureBoxes();
      await _history!.clear();
      await _folders!.clear();
      await _tags!.clear();
      await _presets!.clear();
      await _scanHistory!.clear();
      await _templates!.clear();
      await _settings!.clear();

      for (final h in (data['history'] as List? ?? [])) {
        final map = h as Map<String, dynamic>;
        await _history!.put(map['id'], jsonEncode(map));
      }
      for (final f in (data['folders'] as List? ?? [])) {
        final map = f as Map<String, dynamic>;
        await _folders!.put(map['id'], jsonEncode(map));
      }
      for (final t in (data['tags'] as List? ?? [])) {
        final map = t as Map<String, dynamic>;
        await _tags!.put(map['id'], jsonEncode(map));
      }
      for (final p in (data['presets'] as List? ?? [])) {
        final map = p as Map<String, dynamic>;
        await _presets!.put(map['id'], jsonEncode(map));
      }
      for (final s in (data['scanHistory'] as List? ?? [])) {
        final map = s as Map<String, dynamic>;
        await _scanHistory!.put(map['id'], jsonEncode(map));
      }
      for (final t in (data['templates'] as List? ?? [])) {
        final map = t as Map<String, dynamic>;
        await _templates!.put(map['id'], jsonEncode(map));
      }
      if (data['settings'] != null) {
        await _settings!
            .put('app_settings', jsonEncode(data['settings']));
      }
      return Either.right(null);
    } catch (e, s) {
      return Either.left(ExceptionMapper.map(e, s));
    }
  }

  Future<Result<void>> clearAllData() async {
    try {
      await _ensureBoxes();
      await _history!.clear();
      await _folders!.clear();
      await _tags!.clear();
      await _presets!.clear();
      await _scanHistory!.clear();
      await _templates!.clear();
      await _settings!.clear();
      return Either.right(null);
    } catch (e, s) {
      return Either.left(ExceptionMapper.map(e, s));
    }
  }
}
