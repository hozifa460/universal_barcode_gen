// Preset + Template repository implementations.
import '../../../core/errors/either.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/design_preset.dart';
import '../../../domain/entities/template.dart';
import '../../../domain/repositories/preset_repository.dart';
import '../datasources/hive_local_data_source.dart';

class PresetRepositoryImpl implements PresetRepository {
  PresetRepositoryImpl(this._ds);
  final HiveLocalDataSource _ds;

  @override
  Future<Either<Failure, DesignPreset>> save(DesignPreset preset) =>
      _ds.savePreset(preset);

  @override
  Future<Either<Failure, List<DesignPreset>>> getAll() => _ds.getAllPresets();

  @override
  Future<Either<Failure, void>> delete(String id) => _ds.deletePreset(id);

  @override
  Future<Either<Failure, void>> seedBuiltins() async {
    for (final p in BuiltInPresets.all) {
      final r = await _ds.savePreset(p);
      if (r.isLeft) return r;
    }
    return Either.right(null);
  }
}

class TemplateRepositoryImpl implements TemplateRepository {
  TemplateRepositoryImpl(this._ds);
  final HiveLocalDataSource _ds;

  @override
  Future<Result<Template>> save(Template template) =>
      _ds.saveTemplate(template);

  @override
  Future<Result<List<Template>>> getAll() => _ds.getAllTemplates();

  @override
  Future<Either<Failure, void>> delete(String id) => _ds.deleteTemplate(id);

  @override
  Future<Either<Failure, void>> seedBuiltins() async {
    for (final t in BuiltInTemplates.all) {
      final r = await _ds.saveTemplate(t);
      if (r.isLeft) return r;
    }
    return Either.right(null);
  }
}
