import '../../core/errors/either.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/service_locator.dart';
import '../entities/app_settings.dart';

class GetSettingsUseCase {
  Future<Either<Failure, AppSettings>> call() async {
    try {
      return await ServiceLocator.instance.settingsRepository.get();
    } catch (e) {
      return Either.left(UnknownFailure(message: e.toString()));
    }
  }
}
class SaveSettingsUseCase {
  Future<Either<Failure, AppSettings>> call(AppSettings settings) async {
    try {
      await ServiceLocator.instance.settingsRepository.save(settings);
      return Either.right(settings);
    } catch (e) {
      return Either.left(UnknownFailure(message: e.toString()));
    }
  }
}
class ExportBackupUseCase {
  Future<Either<Failure, String>> call() async {
    try {
      final result = await ServiceLocator.instance.backupRepository.exportAll();
      return result.fold(
        onLeft: Either.left,
        onRight: (data) => Either.right(data.toString()),
      );
    } catch (e) {
      return Either.left(UnknownFailure(message: e.toString()));
    }
  }
}
class ClearAllDataUseCase {
  Future<Either<Failure, bool>> call() async {
    try {
      await ServiceLocator.instance.backupRepository.clearAll();
      return Either.right(true);
    } catch (e) {
      return Either.left(UnknownFailure(message: e.toString()));
    }
  }
}
