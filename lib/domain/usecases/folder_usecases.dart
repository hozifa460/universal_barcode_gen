import '../../core/errors/either.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/service_locator.dart';
import '../entities/folder.dart';

class GetFoldersUseCase {
  Future<Either<Failure, List<Folder>>> call() async {
    try {
      final res = await ServiceLocator.instance.folderRepository.getAll();
      return res;
    } catch (e) {
      return Either.left(UnknownFailure(message: e.toString()));
    }
  }
}
class GetTagsUseCase {
  Future<Either<Failure, List<Tag>>> call() async {
    try {
      final res = await ServiceLocator.instance.tagRepository.getAll();
      return res;
    } catch (e) {
      return Either.left(UnknownFailure(message: e.toString()));
    }
  }
}

class SaveFolderUseCase {
  Future<Either<Failure, Folder>> call(Folder folder) async {
    try {
      final res = await ServiceLocator.instance.folderRepository.save(folder);
      return res;
    } catch (e) {
      return Either.left(UnknownFailure(message: e.toString()));
    }
  }
}
class DeleteFolderUseCase {
  Future<Either<Failure, bool>> call(String id) async {
    try {
      await ServiceLocator.instance.folderRepository.delete(id);
      return Either.right(true);
    } catch (e) {
      return Either.left(UnknownFailure(message: e.toString()));
    }
  }
}
class SaveTagUseCase {
  Future<Either<Failure, Tag>> call(Tag tag) async {
    try {
      final res = await ServiceLocator.instance.tagRepository.save(tag);
      return res;
    } catch (e) {
      return Either.left(UnknownFailure(message: e.toString()));
    }
  }
}
class DeleteTagUseCase {
  Future<Either<Failure, bool>> call(String id) async {
    try {
      await ServiceLocator.instance.tagRepository.delete(id);
      return Either.right(true);
    } catch (e) {
      return Either.left(UnknownFailure(message: e.toString()));
    }
  }
}
