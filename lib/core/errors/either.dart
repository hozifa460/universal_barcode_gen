// Either: simplified union of Left (failure) | Right (success).
// We don't pull in dartz to keep the dependency footprint minimal.

import 'package:equatable/equatable.dart';

import '../errors/failures.dart';

class Either<L, R> extends Equatable {

  const Either._left(this._left)
      : _right = null,
        _isLeft = true;
  const Either._right(this._right)
      : _left = null,
        _isLeft = false;

  factory Either.left(L value) => Either._left(value);
  factory Either.right(R value) => Either._right(value);
  final L? _left;
  final R? _right;
  final bool _isLeft;

  bool get isLeft => _isLeft;
  bool get isRight => !_isLeft;

  L? get left => _left;
  R? get right => _right;

  /// Fold: branches on either side and returns a single value of T.
  T fold<T>({
    required T Function(L) onLeft,
    required T Function(R) onRight,
  }) {
    return _isLeft ? onLeft(_left as L) : onRight(_right as R);
  }

  /// Map the right side; left is propagated untouched.
  Either<L, T> map<T>(T Function(R) fn) {
    if (_isLeft) return Either.left(_left as L);
    return Either.right(fn(_right as R));
  }

  /// Flat-map the right side.
  Either<L, T> flatMap<T>(Either<L, T> Function(R) fn) {
    if (_isLeft) return Either.left(_left as L);
    return fn(_right as R);
  }

  /// Convenience: get the success value or throw.
  R getOrThrow() {
    if (_isLeft) {
      final l = _left;
      if (l is Failure) {
        throw StateError('Either is Left: ${l.message}');
      }
      throw StateError('Either is Left: $l');
    }
    return _right as R;
  }

  /// Convenience: get the success value or a fallback.
  R getOrElse(R Function() orElse) {
    return _isLeft ? orElse() : _right as R;
  }

  @override
  List<Object?> get props => [_left, _right, _isLeft];
}

typedef Result<T> = Either<Failure, T>;
