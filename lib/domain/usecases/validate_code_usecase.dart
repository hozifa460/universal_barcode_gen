import '../../core/validators/input_validator.dart';
import '../../core/constants/content_type.dart';

class ValidateCodeUseCase {
  String? call(ContentType type, String rawInput) {
    return InputValidator.validate(type, rawInput);
  }
}
