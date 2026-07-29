import '../../core/errors/either.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/service_locator.dart';

class ReadClipboardUseCase {
  Future<Either<Failure, String>> call() async {
    try {
      final res = await ServiceLocator.instance.clipboardDataSource.getText();
      return res.fold(
        onLeft: (f) => Either.left(f),
        onRight: (text) => text == null
            ? Either.left(const UnknownFailure(message: 'empty'))
            : Either.right(text),
      );
    } catch (e) {
      return Either.left(UnknownFailure(message: e.toString()));
    }
  }
}
class WriteClipboardUseCase {
  Future<Either<Failure, bool>> call(String text) async {
    try {
      await ServiceLocator.instance.clipboardDataSource.setText(text);
      return Either.right(true);
    } catch (e) {
      return Either.left(UnknownFailure(message: e.toString()));
    }
  }
}
