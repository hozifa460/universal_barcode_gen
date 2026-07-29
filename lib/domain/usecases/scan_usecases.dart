import '../../core/errors/either.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/service_locator.dart';
import '../entities/scan_result.dart';

class GetScanHistoryUseCase {
  Future<Either<Failure, List<ScanResult>>> call() async {
    try {
      final res = await ServiceLocator.instance.scanRepository.getAll();
      return res;
    } catch (e) {
      return Either.left(UnknownFailure(message: e.toString()));
    }
  }
}
class SaveScanResultUseCase {
  Future<Either<Failure, ScanResult>> call(ScanResult result) async {
    try {
      final res = await ServiceLocator.instance.scanRepository.save(result);
      return res;
    } catch (e) {
      return Either.left(UnknownFailure(message: e.toString()));
    }
  }
}
class DeleteScanResultUseCase {
  Future<Either<Failure, bool>> call(String id) async {
    try {
      await ServiceLocator.instance.scanRepository.delete(id);
      return Either.right(true);
    } catch (e) {
      return Either.left(UnknownFailure(message: e.toString()));
    }
  }
}
class ClearScanHistoryUseCase {
  Future<Either<Failure, bool>> call() async {
    try {
      await ServiceLocator.instance.scanRepository.clearAll();
      return Either.right(true);
    } catch (e) {
      return Either.left(UnknownFailure(message: e.toString()));
    }
  }
}
