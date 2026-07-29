// ClipboardDataSource: typed wrapper over platform clipboard.
import 'package:flutter/services.dart';

import '../../../core/errors/either.dart';
import '../../../core/errors/exceptions.dart';

class ClipboardDataSource {
  ClipboardDataSource._();
  static final ClipboardDataSource instance = ClipboardDataSource._();

  Future<Result<String?>> getText() async {
    try {
      final data = await Clipboard.getData('text/plain');
      return Either.right(data?.text);
    } catch (e, s) {
      return Either.left(ExceptionMapper.map(e, s));
    }
  }

  Future<Result<void>> setText(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      return Either.right(null);
    } catch (e, s) {
      return Either.left(ExceptionMapper.map(e, s));
    }
  }
}
