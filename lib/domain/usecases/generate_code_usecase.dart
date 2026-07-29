import '../../core/errors/either.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/service_locator.dart';
import '../entities/generation_request.dart';
import '../entities/history_entry.dart';
import 'package:uuid/uuid.dart';

class GenerateCodeUseCase {
  Future<Result<GenerationResult>> call(GenerationRequest request) async {
    try {
      final res =
          await ServiceLocator.instance.generationService.generate(request);
      return res;
    } catch (e) {
      return Either.left(UnknownFailure(message: e.toString()));
    }
  }

  Future<Result<HistoryEntry>> generateAndSave(
      GenerationRequest request) async {
    final res = await call(request);
    return res.fold(
      onLeft: Either.left,
      onRight: (_) async {
        final now = DateTime.now();
        final entry = HistoryEntry(
          id: const Uuid().v4(),
          content: request.content,
          format: request.format,
          design: request.design,
          createdAt: now,
          updatedAt: now,
          isFavorite: false,
        );
        return ServiceLocator.instance.historyRepository.save(entry);
      },
    );
  }
}
