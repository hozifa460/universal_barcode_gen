// Failure: base class for all error results.
// Sealed so callers can exhaustively switch on concrete subtypes.
//
// Pattern follows Clean Architecture: use cases return Either<Failure, T>.

import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {

  const Failure({required this.message, this.code});
  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];
}

class ValidationFailure extends Failure {
  const ValidationFailure({
    required this.field,
    required super.message,
    super.code,
  });
  final String field;

  @override
  List<Object?> get props => [field, message, code];
}

class StorageFailure extends Failure {
  const StorageFailure({required super.message, super.code});
}

class GenerationFailure extends Failure {
  const GenerationFailure({required super.message, super.code});
}

class ExportFailure extends Failure {
  const ExportFailure({required super.message, super.code});
}

class ScannerFailure extends Failure {
  const ScannerFailure({required super.message, super.code});
}

class FileImportFailure extends Failure {
  const FileImportFailure({required super.message, super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code});
}

class PermissionFailure extends Failure {
  const PermissionFailure({required super.message, super.code});
}

class UnknownFailure extends Failure {
  const UnknownFailure({required super.message, super.code});
}
