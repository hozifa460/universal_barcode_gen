import '../../core/errors/either.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/service_locator.dart';
import '../entities/generation_request.dart';

class ExportUseCase {
  Future<Either<Failure, String>> exportPng(List<int> bytes, {String? filename}) async {
    try {
      final res = await ServiceLocator.instance.exportService.exportPng(bytes: bytes);
      return res;
    } catch (e) {
      return Either.left(UnknownFailure(message: e.toString()));
    }
  }
  Future<Either<Failure, String>> exportSvg(String svg) async {
    try {
      final res = await ServiceLocator.instance.exportService.exportSvg(svg: svg);
      return res;
    } catch (e) {
      return Either.left(UnknownFailure(message: e.toString()));
    }
  }
  Future<Either<Failure, String>> exportPdf({required List<List<int>> images, required List<String> labels}) async {
    try {
      final res = await ServiceLocator.instance.exportService.exportPdf(images: images, labels: labels);
      return res;
    } catch (e) {
      return Either.left(UnknownFailure(message: e.toString()));
    }
  }
  Future<Either<Failure, String>> exportHighRes(GenerationRequest request, {required int size}) async {
    try {
      final res = await ServiceLocator.instance.exportService.exportHighRes(request: request, size: size);
      return res;
    } catch (e) {
      return Either.left(UnknownFailure(message: e.toString()));
    }
  }
  Future<void> printImage(List<int> bytes, {required String label}) async {
    await ServiceLocator.instance.printService.printImage(bytes, label: label);
  }
}
