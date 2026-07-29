// Preset + Template repository contracts.
import '../../../core/errors/either.dart';
import '../entities/design_preset.dart';
import '../entities/template.dart';

abstract class PresetRepository {
  Future<Result<DesignPreset>> save(DesignPreset preset);
  Future<Result<List<DesignPreset>>> getAll();
  Future<Result<void>> delete(String id);
  Future<Result<void>> seedBuiltins();
}

abstract class TemplateRepository {
  Future<Result<Template>> save(Template template);
  Future<Result<List<Template>>> getAll();
  Future<Result<void>> delete(String id);
  Future<Result<void>> seedBuiltins();
}
