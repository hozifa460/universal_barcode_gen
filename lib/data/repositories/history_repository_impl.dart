// HistoryRepositoryImpl: Hive-backed implementation.
import '../../../core/errors/either.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/history_entry.dart';
import '../../../domain/repositories/history_repository.dart';
import '../datasources/hive_local_data_source.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  HistoryRepositoryImpl(this._ds);
  final HiveLocalDataSource _ds;

  @override
  Future<Result<HistoryEntry>> save(HistoryEntry entry) =>
      _ds.saveHistoryEntry(entry);

  @override
  Future<Either<Failure, List<HistoryEntry>>> getAll() => _ds.getAllHistory();

  @override
  Future<Result<HistoryEntry?>> getById(String id) => _ds.getHistoryEntry(id);

  @override
  Future<Either<Failure, void>> delete(String id) => _ds.deleteHistoryEntry(id);

  @override
  Future<Either<Failure, void>> clearAll() => _ds.clearAllHistory();

  @override
  Future<Result<List<String>>> getFavoriteIds() => _ds.getAllFavoriteIds();

  @override
  Future<Result<HistoryEntry?>> findDuplicate(HistoryEntry entry) async {
    final all = await getAll();
    return all.fold(
      onLeft: (f) => Either.left(f),
      onRight: (entries) {
        for (final e in entries) {
          if (e.id != entry.id && e.isDuplicateOf(entry)) {
            return Either.right(e);
          }
        }
        return Either.right(null);
      },
    );
  }
}
