// Folder + Tag repository implementations.
import '../../../core/errors/either.dart';
import '../../../domain/entities/folder.dart';
import '../../../domain/repositories/folder_repository.dart';
import '../datasources/hive_local_data_source.dart';

class FolderRepositoryImpl implements FolderRepository {
  FolderRepositoryImpl(this._ds);
  final HiveLocalDataSource _ds;

  @override
  Future<Result<Folder>> save(Folder folder) => _ds.saveFolder(folder);

  @override
  Future<Result<List<Folder>>> getAll() => _ds.getAllFolders();

  @override
  Future<Result<void>> delete(String id) => _ds.deleteFolder(id);
}

class TagRepositoryImpl implements TagRepository {
  TagRepositoryImpl(this._ds);
  final HiveLocalDataSource _ds;

  @override
  Future<Result<Tag>> save(Tag tag) => _ds.saveTag(tag);

  @override
  Future<Result<List<Tag>>> getAll() => _ds.getAllTags();

  @override
  Future<Result<void>> delete(String id) => _ds.deleteTag(id);
}
