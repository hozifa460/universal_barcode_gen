// Preset + Template providers.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/design_preset.dart';
import '../../domain/entities/template.dart';
import '../../domain/usecases/preset_usecases.dart';

final presetsProvider = FutureProvider<List<DesignPreset>>((ref) async {
  final r = await GetPresetsUseCase().call();
  return r.getOrThrow();
});

final templatesProvider = FutureProvider<List<Template>>((ref) async {
  final r = await GetTemplatesUseCase().call();
  return r.getOrThrow();
});

final recentTemplatesProvider = FutureProvider<List<Template>>((ref) async {
  final all = await ref.watch(templatesProvider.future);
  final withDates = all.where((t) => t.lastUsed != null).toList();
  withDates.sort((a, b) => b.lastUsed!.compareTo(a.lastUsed!));
  return withDates.take(5).toList();
});
