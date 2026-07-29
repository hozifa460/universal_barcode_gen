// Settings repository contract.
import '../../../core/errors/either.dart';
import '../entities/app_settings.dart';

abstract class SettingsRepository {
  Future<Result<AppSettings>> get();
  Future<Result<AppSettings>> save(AppSettings settings);
}

abstract class BackupRepository {
  Future<Result<Map<String, dynamic>>> exportAll();
  Future<Result<void>> importAll(Map<String, dynamic> data);
  Future<Result<void>> clearAll();
}
