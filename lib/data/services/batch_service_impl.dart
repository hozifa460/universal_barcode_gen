// BatchServiceImpl: CSV/Excel reading + bulk generation.

import 'dart:io' show File;

import 'package:csv/csv.dart';
import 'package:excel/excel.dart';

import '../../core/errors/either.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/service_locator.dart';
import '../../domain/services/scanner_service.dart';

class BatchServiceImpl implements BatchService {
  BatchServiceImpl._();
  static final BatchServiceImpl instance = BatchServiceImpl._();

  @override
  Future<Result<List<GenerationResult>>> generateAll(
    List<GenerationRequest> requests,
  ) async {
    try {
      final results = <GenerationResult>[];
      for (final req in requests) {
        final r =
            await ServiceLocator.instance.generationService.generate(req);
        r.fold(
          onLeft: (Failure f) => AppLogger.instance
              .warning('Batch item failed: ${f.message}'),
          onRight: (GenerationResult res) => results.add(res),
        );
      }
      return Either.right(results);
    } catch (e, s) {
      return Either.left(ExceptionMapper.map(e, s));
    }
  }

  @override
  Future<Result<List<List<String>>>> readCsv(String path) async {
    try {
      final file = File(path);
      final raw = await file.readAsString();
      final rows = const CsvToListConverter(
        shouldParseNumbers: false,
        allowInvalid: true,
      ).convert(raw);
      final result = rows
          .map((r) => r.map((e) => e.toString()).toList())
          .toList();
      return Either.right(result);
    } catch (e, s) {
      AppLogger.instance.error('readCsv', e, s);
      return Either.left(
        const FileImportFailure(message: 'error_file_import_failed', code: 'csv'),
      );
    }
  }

  @override
  Future<Result<List<List<String>>>> readExcel(String path) async {
    try {
      final bytes = await File(path).readAsBytes();
      final excel = Excel.decodeBytes(bytes);
      final result = <List<String>>[];
      for (final table in excel.tables.keys) {
        final sheet = excel.tables[table];
        if (sheet == null) continue;
        for (final row in sheet.rows) {
          final cells = row
              .map((cell) => cell?.value?.toString() ?? '')
              .toList();
          if (cells.any((c) => c.isNotEmpty)) {
            result.add(cells);
          }
        }
        break; // only first sheet
      }
      return Either.right(result);
    } catch (e, s) {
      AppLogger.instance.error('readExcel', e, s);
      return Either.left(
        const FileImportFailure(message: 'error_file_import_failed', code: 'excel'),
      );
    }
  }
}
