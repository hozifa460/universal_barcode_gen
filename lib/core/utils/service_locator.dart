// Dependency injection container.
// Wires datasource singletons to repository implementations.
// Riverpod providers in Batch 5 will read from here.

import '../../data/datasources/clipboard_data_source.dart';
import '../../data/datasources/file_data_source.dart';
import '../../data/datasources/hive_local_data_source.dart';
import '../../data/repositories/folder_repository_impl.dart';
import '../../data/repositories/history_repository_impl.dart';
import '../../data/repositories/preset_repository_impl.dart';
import '../../data/repositories/scan_repository_impl.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../data/services/batch_service_impl.dart';
import '../../data/services/export_service_impl.dart';
import '../../data/services/generation_service_impl.dart';
import '../../data/services/print_service_impl.dart';
import '../../data/services/scanner_service_impl.dart';
import '../../domain/repositories/folder_repository.dart';
import '../../domain/repositories/history_repository.dart';
import '../../domain/repositories/preset_repository.dart';
import '../../domain/repositories/scan_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/services/generation_service.dart';
import '../../domain/services/scanner_service.dart';

class ServiceLocator {
  ServiceLocator._();
  static final ServiceLocator instance = ServiceLocator._();

  // Datasources
  final HiveLocalDataSource hiveDataSource = HiveLocalDataSource.instance;
  final FileDataSource fileDataSource = FileDataSource.instance;
  final ClipboardDataSource clipboardDataSource = ClipboardDataSource.instance;

  // Repositories
  HistoryRepository get historyRepository =>
      HistoryRepositoryImpl(hiveDataSource);
  FolderRepository get folderRepository =>
      FolderRepositoryImpl(hiveDataSource);
  TagRepository get tagRepository => TagRepositoryImpl(hiveDataSource);
  ScanRepository get scanRepository =>
      ScanRepositoryImpl(hiveDataSource);
  PresetRepository get presetRepository =>
      PresetRepositoryImpl(hiveDataSource);
  TemplateRepository get templateRepository =>
      TemplateRepositoryImpl(hiveDataSource);
  SettingsRepository get settingsRepository =>
      SettingsRepositoryImpl(hiveDataSource);
  BackupRepository get backupRepository =>
      BackupRepositoryImpl(hiveDataSource);

  // Services (implemented in Batch 6 / 7)
  GenerationService get generationService => GenerationServiceImpl.instance;
  ExportServiceImpl get exportService => ExportServiceImpl.instance;
  BatchServiceImpl get batchService => BatchServiceImpl.instance;
  ScannerService get scannerService => ScannerServiceImpl.instance;
  PrintServiceImpl get printService => PrintServiceImpl.instance;
}
