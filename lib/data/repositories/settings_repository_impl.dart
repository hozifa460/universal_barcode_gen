// Settings + Backup repository implementations.
import '../../../core/errors/either.dart';
import '../../../domain/entities/app_settings.dart';
import '../../../domain/repositories/settings_repository.dart';
import '../datasources/hive_local_data_source.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._ds);
  final HiveLocalDataSource _ds;

  @override
  Future<Result<AppSettings>> get() => _ds.getSettings();

  @override
  Future<Result<AppSettings>> save(AppSettings settings) =>
      _ds.saveSettings(settings);
}

class BackupRepositoryImpl implements BackupRepository {
  BackupRepositoryImpl(this._ds);
  final HiveLocalDataSource _ds;

  @override
  Future<Result<Map<String, dynamic>>> exportAll() => _ds.exportBackup();

  @override
  Future<Result<void>> importAll(Map<String, dynamic> data) =>
      _ds.importBackup(data);

  @override
  Future<Result<void>> clearAll() => _ds.clearAllData();
}
