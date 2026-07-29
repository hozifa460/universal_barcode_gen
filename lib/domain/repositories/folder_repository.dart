// Folder + Tag repository contracts.
import '../../../core/errors/either.dart';
import '../entities/folder.dart';

abstract class FolderRepository {
  Future<Result<Folder>> save(Folder folder);
  Future<Result<List<Folder>>> getAll();
  Future<Result<void>> delete(String id);
}

abstract class TagRepository {
  Future<Result<Tag>> save(Tag tag);
  Future<Result<List<Tag>>> getAll();
  Future<Result<void>> delete(String id);
}
