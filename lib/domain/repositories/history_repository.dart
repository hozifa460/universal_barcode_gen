// HistoryRepository contract: CRUD operations on history entries.
// Defined in domain layer; implemented in data layer.

import '../../../core/errors/either.dart';
import '../entities/history_entry.dart';

abstract class HistoryRepository {
  Future<Result<HistoryEntry>> save(HistoryEntry entry);
  Future<Result<List<HistoryEntry>>> getAll();
  Future<Result<HistoryEntry?>> getById(String id);
  Future<Result<void>> delete(String id);
  Future<Result<void>> clearAll();
  Future<Result<List<String>>> getFavoriteIds();
  Future<Result<HistoryEntry?>> findDuplicate(HistoryEntry entry);
}
