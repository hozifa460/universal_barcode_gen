// FileDataSource: file I/O helpers for exports and imports.
// Saves PNG/SVG/PDF files to the app's documents directory.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/errors/either.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/utils/logger.dart';

class FileDataSource {
  FileDataSource._();
  static final FileDataSource instance = FileDataSource._();

  /// Returns the app's documents directory (or cache dir as fallback).
  Future<Directory> _outputDir() async {
    try {
      return await getApplicationDocumentsDirectory();
    } catch (_) {
      return await getTemporaryDirectory();
    }
  }

  /// Saves raw [bytes] as a file named [filename] in the app documents dir.
  /// Returns the absolute path.
  Future<Result<String>> saveBytes({
    required String filename,
    required List<int> bytes,
    String? subdir,
  }) async {
    try {
      if (kIsWeb) {
        final extension = p.extension(filename).replaceFirst('.', '');
        await FileSaver.instance.saveFile(
          name: p.basenameWithoutExtension(filename),
          bytes: Uint8List.fromList(bytes),
          ext: extension,
          mimeType: MimeType.custom,
          customMimeType: _mimeTypeFor(extension),
        );
        return Either.right(filename);
      }
      final base = await _outputDir();
      final dir = subdir == null ? base : Directory(p.join(base.path, subdir));
      if (!await dir.exists()) await dir.create(recursive: true);
      final path = p.join(dir.path, filename);
      final file = File(path);
      await file.writeAsBytes(bytes, flush: true);
      AppLogger.instance.debug('Saved file: $path (${bytes.length} bytes)');
      return Either.right(path);
    } catch (e, s) {
      return Either.left(ExceptionMapper.map(e, s));
    }
  }

  /// Saves a plain-text file (used for SVG export).
  Future<Result<String>> saveString({
    required String filename,
    required String content,
    String? subdir,
  }) async {
    try {
      if (kIsWeb) {
        final extension = p.extension(filename).replaceFirst('.', '');
        await FileSaver.instance.saveFile(
          name: p.basenameWithoutExtension(filename),
          bytes: Uint8List.fromList(utf8.encode(content)),
          ext: extension,
          mimeType: MimeType.custom,
          customMimeType: _mimeTypeFor(extension),
        );
        return Either.right(filename);
      }
      final base = await _outputDir();
      final dir = subdir == null ? base : Directory(p.join(base.path, subdir));
      if (!await dir.exists()) await dir.create(recursive: true);
      final path = p.join(dir.path, filename);
      final file = File(path);
      await file.writeAsString(content, flush: true);
      return Either.right(path);
    } catch (e, s) {
      return Either.left(ExceptionMapper.map(e, s));
    }
  }

  /// Reads bytes from a file path.
  Future<Result<List<int>>> readBytes(String path) async {
    try {
      final file = File(path);
      final bytes = await file.readAsBytes();
      return Either.right(bytes);
    } catch (e, s) {
      return Either.left(ExceptionMapper.map(e, s));
    }
  }

  /// Reads CSV file as String.
  Future<Result<String>> readTextFile(String path) async {
    try {
      final file = File(path);
      final content = await file.readAsString();
      return Either.right(content);
    } catch (e, s) {
      return Either.left(ExceptionMapper.map(e, s));
    }
  }

  /// Deletes a file at [path].
  Future<Result<void>> deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
      return Either.right(null);
    } catch (e, s) {
      return Either.left(ExceptionMapper.map(e, s));
    }
  }

  /// Generates a unique filename with timestamp.
  String generateFilename({
    required String prefix,
    required String extension,
    DateTime? now,
  }) {
    final t = now ?? DateTime.now();
    final stamp =
        '${t.year}${t.month.toString().padLeft(2, '0')}${t.day.toString().padLeft(2, '0')}'
        '_${t.hour.toString().padLeft(2, '0')}${t.minute.toString().padLeft(2, '0')}${t.second.toString().padLeft(2, '0')}';
    return '${prefix}_$stamp.$extension';
  }

  /// Returns true if the file exists.
  Future<bool> exists(String path) async {
    return File(path).exists();
  }

  String _mimeTypeFor(String extension) {
    switch (extension.toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'svg':
        return 'image/svg+xml';
      case 'pdf':
        return 'application/pdf';
      case 'csv':
        return 'text/csv';
      default:
        return 'application/octet-stream';
    }
  }
}
