// Scan history repository contract.
import '../../../core/errors/either.dart';
import '../entities/scan_result.dart';

abstract class ScanRepository {
  Future<Result<ScanResult>> save(ScanResult result);
  Future<Result<List<ScanResult>>> getAll();
  Future<Result<void>> delete(String id);
  Future<Result<void>> clearAll();
}
