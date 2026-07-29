import '../../core/errors/either.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/service_locator.dart';
import '../entities/history_entry.dart';

enum SortOption { dateDesc, dateAsc, nameAsc, nameDesc, typeAsc }

class GetHistoryUseCase {
  Future<Either<Failure, List<HistoryEntry>>> call() async {
    try {
      final res = await ServiceLocator.instance.historyRepository.getAll();
      return res;
    } catch (e) {
      return Either.left(UnknownFailure(message: e.toString()));
    }
  }
}
class SortHistoryUseCase {
  List<HistoryEntry> call(List<HistoryEntry> entries, SortOption option) {
    final copy = List<HistoryEntry>.from(entries);
    switch (option) {
      case SortOption.dateDesc: copy.sort((a,b) => b.createdAt.compareTo(a.createdAt)); break;
      case SortOption.dateAsc: copy.sort((a,b) => a.createdAt.compareTo(b.createdAt)); break;
      case SortOption.nameAsc: copy.sort((a,b) => a.content.displayName.compareTo(b.content.displayName)); break;
      case SortOption.nameDesc: copy.sort((a,b) => b.content.displayName.compareTo(a.content.displayName)); break;
      case SortOption.typeAsc: copy.sort((a,b) => a.format.name.compareTo(b.format.name)); break;
    }
    return copy;
  }
}
