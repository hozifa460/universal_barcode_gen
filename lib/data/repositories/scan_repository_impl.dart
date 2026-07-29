// Scan history repository implementation.
import '../../../core/errors/either.dart';
import '../../../domain/entities/scan_result.dart';
import '../../../domain/repositories/scan_repository.dart';
import '../datasources/hive_local_data_source.dart';

class ScanRepositoryImpl implements ScanRepository {
  ScanRepositoryImpl(this._ds);
  final HiveLocalDataSource _ds;

  @override
  Future<Result<ScanResult>> save(ScanResult result) =>
      _ds.saveScanResult(result);

  @override
  Future<Result<List<ScanResult>>> getAll() => _ds.getAllScanResults();

  @override
  Future<Result<void>> delete(String id) => _ds.deleteScanResult(id);

  @override
  Future<Result<void>> clearAll() => _ds.clearScanHistory();
}
