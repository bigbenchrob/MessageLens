import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/app_czar_models.dart';
import 'app_czar_evaluator.dart';
import 'app_czar_observation_reader.dart';

part 'app_czar_assessment_provider.g.dart';

@Riverpod(keepAlive: true)
AppCzarObservationReader appCzarObservationReader(Ref ref) {
  throw StateError(
    'AppCzarObservationReader must be supplied by the admitted composition root.',
  );
}

@Riverpod(keepAlive: true)
class AppCzarAssessmentController extends _$AppCzarAssessmentController {
  var _generation = 0;

  @override
  AppCzarAssessmentState build() {
    final initial = AppCzarAssessmentState.initial(_generation);
    Future<void>.microtask(() => _runAssessment(_generation));
    return initial;
  }

  Future<void> runAgain() async {
    _generation += 1;
    state = AppCzarAssessmentState.initial(_generation);
    await _runAssessment(_generation);
  }

  Future<void> _runAssessment(int generation) async {
    final reader = ref.read(appCzarObservationReaderProvider);
    await Future.wait<void>([
      _captureRoot(reader, generation),
      _captureSource(reader, generation),
      _captureImport(reader, generation),
      _captureGraph(reader, generation),
      _captureOverlay(reader, generation),
      _captureArchive(reader, generation),
    ]);
    if (generation != _generation) {
      return;
    }
    final observations = state.requireObservationSet();
    final assessment = const AppCzarEvaluator().evaluate(observations);
    state = state.copyWith(assessment: assessment);
  }

  Future<void> _captureRoot(
    AppCzarObservationReader reader,
    int generation,
  ) async {
    AppCzarRootObservation observation;
    try {
      observation = await reader.readRoot();
    } on Object catch (error) {
      observation = AppCzarRootObservation(
        admitted: false,
        path: 'Root inspection failed: $error',
      );
    }
    if (generation == _generation) {
      state = state.copyWith(root: observation);
    }
  }

  Future<void> _captureSource(
    AppCzarObservationReader reader,
    int generation,
  ) async {
    AppCzarSourceObservation observation;
    try {
      observation = await reader.readSource();
    } on Object catch (error) {
      observation = AppCzarSourceObservation.unknown(
        'Messages source inspection failed: $error',
      );
    }
    if (generation == _generation) {
      state = state.copyWith(source: observation);
    }
  }

  Future<void> _captureImport(
    AppCzarObservationReader reader,
    int generation,
  ) async {
    final observation = await _readDatabase(
      reader.readImportStore,
      'Import-store inspection failed',
    );
    if (generation == _generation) {
      state = state.copyWith(importStore: observation);
    }
  }

  Future<void> _captureGraph(
    AppCzarObservationReader reader,
    int generation,
  ) async {
    final observation = await _readDatabase(
      reader.readGraphStore,
      'Graph-store inspection failed',
    );
    if (generation == _generation) {
      state = state.copyWith(graphStore: observation);
    }
  }

  Future<void> _captureOverlay(
    AppCzarObservationReader reader,
    int generation,
  ) async {
    final observation = await _readDatabase(
      reader.readOverlay,
      'Overlay inspection failed',
    );
    if (generation == _generation) {
      state = state.copyWith(overlay: observation);
    }
  }

  Future<void> _captureArchive(
    AppCzarObservationReader reader,
    int generation,
  ) async {
    AppCzarArchiveObservation observation;
    try {
      observation = await reader.readAttachmentArchive();
    } on Object catch (error) {
      observation = AppCzarArchiveObservation.unknown(
        'Attachment archive inspection failed: $error',
      );
    }
    if (generation == _generation) {
      state = state.copyWith(attachmentArchive: observation);
    }
  }

  Future<AppCzarDatabaseObservation> _readDatabase(
    Future<AppCzarDatabaseObservation> Function() read,
    String failurePrefix,
  ) async {
    try {
      return await read();
    } on Object catch (error) {
      return AppCzarDatabaseObservation.unknown('$failurePrefix: $error');
    }
  }
}
