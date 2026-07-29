// Exceptions: wraps platform/external errors into domain Failures.

import 'package:flutter/services.dart';

import 'failures.dart';

class ExceptionMapper {
  ExceptionMapper._();

  /// Map any exception to a domain Failure.
  static Failure map(Object? error, [StackTrace? stack]) {
    if (error is Failure) return error;

    if (error is PlatformException) {
      final code = error.code;
      if (code.contains('permission') || code.contains('PERMISSION')) {
        return PermissionFailure(message: error.message ?? 'Permission denied', code: code);
      }
      if (code.contains('storage') || code.contains('file')) {
        return StorageFailure(message: error.message ?? 'Storage error', code: code);
      }
      return UnknownFailure(message: error.message ?? 'Platform error', code: code);
    }

    if (error is FormatException) {
      return ValidationFailure(field: '', message: error.message, code: 'format');
    }

    if (error is ArgumentError) {
      return ValidationFailure(
        field: error.name ?? '',
        message: error.message.toString(),
        code: 'argument',
      );
    }

    if (error is StateError) {
      return UnknownFailure(message: error.message, code: 'state');
    }

    return UnknownFailure(
      message: error?.toString() ?? 'Unknown error',
      code: 'unknown',
    );
  }
}
