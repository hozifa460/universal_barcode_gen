import '../../core/constants/barcode_format.dart';
import '../../core/constants/content_type.dart';
import '../../core/errors/either.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/service_locator.dart';
import '../entities/barcode_content.dart';
import '../entities/generation_request.dart';
import '../entities/qr_design.dart';

enum CodePurpose { general, web, website, product, inventory, contact, payment, ticket, wifi }

class UniversalConverterUseCase {
  UniversalConverterUseCase();

  ContentType detect(String input) {
    if (input.startsWith('http')) return ContentType.url;
    if (input.contains('@')) return ContentType.email;
    return ContentType.plainText;
  }

  List<BarcodeFormat> compatibleFormats(BarcodeContent content) {
    return BarcodeFormat.values.where((f) => f.maxChars >= content.encoded.length).toList();
  }

  BarcodeFormat recommendFormat(BarcodeContent content, CodePurpose purpose) {
    return BarcodeFormat.qr;
  }

  Future<Result<List<GenerationResult>>> generateAll({required BarcodeContent content, required QrDesign design}) async {
    try {
      final formats = compatibleFormats(content);
      final results = <GenerationResult>[];
      for (final f in formats) {
        final req = GenerationRequest(content: content, format: f, design: design);
        final res = await ServiceLocator.instance.generationService.generate(req);
        res.fold(
          onLeft: (_) {},
          onRight: (GenerationResult r) => results.add(r),
        );
      }
      return Either.right(results);
    } catch (e) {
      return Either.left(UnknownFailure(message: e.toString()));
    }
  }
}
