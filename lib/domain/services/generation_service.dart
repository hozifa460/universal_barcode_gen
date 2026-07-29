// GenerationService contract: produces image bytes from a GenerationRequest.
// Implemented in Batch 6 (data/services/generation_service_impl.dart).

import '../../core/errors/either.dart';
import '../entities/generation_request.dart';

abstract class GenerationService {
  Future<Result<GenerationResult>> generate(GenerationRequest request);

  /// Generates an SVG string. Only valid for QR / DataMatrix / Aztec / PDF417.
  Future<Result<String>> generateSvg(GenerationRequest request);
}
