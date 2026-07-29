// Folders + Tags notifiers (for create / delete operations).
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/folder.dart';
import '../../domain/usecases/folder_usecases.dart';
import 'history_provider.dart';

class FolderEditNotifier extends StateNotifier<List<Folder>> {
  FolderEditNotifier(this._ref) : super(const []);

  final Ref _ref;

  Future<void> create(String name, {int color = 0xFF0E7C6B}) async {
    final folder = Folder(
      id: 'folder_${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      color: color,
    );
    await SaveFolderUseCase().call(folder);
    _ref.invalidate(foldersProvider);
    state = [...state, folder];
  }

  Future<void> rename(String id, String newName) async {
    final r = await GetFoldersUseCase().call();
    r.fold(onLeft: (_) {}, onRight: (folders) async {
      final f = folders.firstWhere((x) => x.id == id);
      await SaveFolderUseCase().call(f.copyWith(name: newName));
      _ref.invalidate(foldersProvider);
    },);
  }

  Future<void> remove(String id) async {
    await DeleteFolderUseCase().call(id);
    _ref.invalidate(foldersProvider);
    state = state.where((f) => f.id != id).toList();
  }
}

final folderEditProvider =
    StateNotifierProvider<FolderEditNotifier, List<Folder>>(
        (ref) => FolderEditNotifier(ref),);

class TagEditNotifier extends StateNotifier<List<Tag>> {
  TagEditNotifier(this._ref) : super(const []);

  final Ref _ref;

  Future<void> create(String name, {int color = 0xFF888888}) async {
    final tag = Tag(
      id: 'tag_${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      color: color,
    );
    await SaveTagUseCase().call(tag);
    _ref.invalidate(tagsProvider);
    state = [...state, tag];
  }

  Future<void> remove(String id) async {
    await DeleteTagUseCase().call(id);
    _ref.invalidate(tagsProvider);
    state = state.where((t) => t.id != id).toList();
  }
}

final tagEditProvider =
    StateNotifierProvider<TagEditNotifier, List<Tag>>(
        (ref) => TagEditNotifier(ref),);
