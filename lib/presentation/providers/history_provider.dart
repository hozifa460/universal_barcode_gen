// History providers.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/service_locator.dart';
import '../../domain/entities/folder.dart';
import '../../domain/entities/history_entry.dart';
import '../../domain/usecases/folder_usecases.dart';
import '../../domain/usecases/history_usecases.dart';

final historyListProvider =
    FutureProvider<List<HistoryEntry>>((ref) async {
  final useCase = GetHistoryUseCase();
  final r = await useCase.call();
  return r.getOrThrow();
});

final favoriteIdsProvider = FutureProvider<List<String>>((ref) async {
  final r = await ServiceLocator.instance.historyRepository.getFavoriteIds();
  return r.getOrThrow();
});

final foldersProvider = FutureProvider<List<Folder>>((ref) async {
  final r = await GetFoldersUseCase().call();
  return r.getOrThrow();
});

final tagsProvider = FutureProvider<List<Tag>>((ref) async {
  final r = await GetTagsUseCase().call();
  return r.getOrThrow();
});

// ---------------------------------------------------------------------------
// History search/filter state
// ---------------------------------------------------------------------------

class HistoryFilter {
  const HistoryFilter({
    this.query = '',
    this.favoritesOnly = false,
    this.folderId,
    this.tag,
    this.sortOption = SortOption.dateDesc,
  });
  final String query;
  final bool favoritesOnly;
  final String? folderId;
  final String? tag;
  final SortOption sortOption;

  HistoryFilter copyWith({
    String? query,
    bool? favoritesOnly,
    String? folderId,
    String? tag,
    SortOption? sortOption,
    bool clearFolder = false,
    bool clearTag = false,
  }) {
    return HistoryFilter(
      query: query ?? this.query,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
      folderId: clearFolder ? null : (folderId ?? this.folderId),
      tag: clearTag ? null : (tag ?? this.tag),
      sortOption: sortOption ?? this.sortOption,
    );
  }
}

final historyFilterProvider =
    StateNotifierProvider<HistoryFilterNotifier, HistoryFilter>(
        (ref) => HistoryFilterNotifier(),);

class HistoryFilterNotifier extends StateNotifier<HistoryFilter> {
  HistoryFilterNotifier() : super(const HistoryFilter());
  void setQuery(String q) => state = state.copyWith(query: q);
  void toggleFavorites() =>
      state = state.copyWith(favoritesOnly: !state.favoritesOnly);
  void setFolder(String? id) =>
      state = state.copyWith(folderId: id, clearFolder: id == null);
  void setTag(String? tag) =>
      state = state.copyWith(tag: tag, clearTag: tag == null);
  void setSort(SortOption s) => state = state.copyWith(sortOption: s);
  void clear() => state = const HistoryFilter();
}

final filteredHistoryProvider =
    FutureProvider<List<HistoryEntry>>((ref) async {
  final filter = ref.watch(historyFilterProvider);
  final list = await ref.watch(historyListProvider.future);
  var filtered = list;

  if (filter.favoritesOnly) {
    filtered = filtered.where((e) => e.isFavorite).toList();
  }
  if (filter.folderId != null) {
    filtered = filtered.where((e) => e.folderId == filter.folderId).toList();
  }
  if (filter.tag != null) {
    filtered = filtered.where((e) => e.tags.contains(filter.tag)).toList();
  }
  if (filter.query.isNotEmpty) {
    final q = filter.query.toLowerCase();
    filtered = filtered.where((e) {
      return e.content.raw.toLowerCase().contains(q) ||
          e.content.displayName.toLowerCase().contains(q) ||
          e.content.type.name.toLowerCase().contains(q) ||
          e.tags.any((t) => t.toLowerCase().contains(q));
    }).toList();
  }
  // Apply sort.
  filtered = SortHistoryUseCase()(filtered, filter.sortOption);
  return filtered;
});
