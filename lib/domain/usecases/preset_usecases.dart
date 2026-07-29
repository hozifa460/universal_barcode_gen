import '../../core/errors/either.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/service_locator.dart';
import '../entities/design_preset.dart';
import '../entities/template.dart';

class GetPresetsUseCase {
  Future<Either<Failure, List<DesignPreset>>> call() async {
    try {
      final res = await ServiceLocator.instance.presetRepository.getAll();
      return res;
    } catch (e) {
      return Either.left(UnknownFailure(message: e.toString()));
    }
  }
}
class SavePresetUseCase {
  Future<Either<Failure, DesignPreset>> call(DesignPreset preset) async {
    try {
      final res = await ServiceLocator.instance.presetRepository.save(preset);
      return res;
    } catch (e) {
      return Either.left(UnknownFailure(message: e.toString()));
    }
  }
}
class DeletePresetUseCase {
  Future<Either<Failure, bool>> call(String id) async {
    try {
      await ServiceLocator.instance.presetRepository.delete(id);
      return Either.right(true);
    } catch (e) {
      return Either.left(UnknownFailure(message: e.toString()));
    }
  }
}
class GetTemplatesUseCase {
  Future<Either<Failure, List<Template>>> call() async {
    try {
      final res = await ServiceLocator.instance.templateRepository.getAll();
      return res;
    } catch (e) {
      return Either.left(UnknownFailure(message: e.toString()));
    }
  }
}
