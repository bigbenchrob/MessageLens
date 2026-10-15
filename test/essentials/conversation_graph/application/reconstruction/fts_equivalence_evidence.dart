import 'dart:convert';

/// Test evidence only. This module has no database, provider or writer imports.
enum FtsTruth { trueValue, falseValue, unknown }

enum FtsDimension {
  schemaRuntimeCompatibility,
  contentMaterialEquivalence,
  boundedRawMatchCorpusEquivalence,
  boundedProductionSearchCorpusEquivalence,
  qualifiedInternalIndexEvidence,
  exhaustiveFtsSemanticEquivalence,
}

enum FtsReason {
  equal,
  mismatch,
  unqualifiedInternalInspection,
  finiteCorpusOnly,
  unsupportedRuntime,
  incompatibleSchemaRuntime,
  unqualifiedObservation,
  bindingDrift,
  readFailure,
  rowLimit,
  byteLimit,
  requestLimit,
  resultLimit,
  handleLimit,
  diskLimit,
  cancelled,
  deadline,
  cleanupFailure,
}

final class FtsLimits {
  const FtsLimits();
  int get messages => 128;
  int get textBytes => 256 * 1024;
  int get requests => 64;
  int get resultIds => 128;
  int get diagnostics => 32;
  int get handles => 6;
  int get diskBytes => 32 * 1024 * 1024;
}

final class FtsBinding {
  const FtsBinding({
    required this.occurrence,
    required this.fingerprint,
    required this.sourceRegistry,
    required this.qualified,
  });
  final String occurrence;
  final String fingerprint;
  final String sourceRegistry;
  final bool qualified;

  bool agrees(FtsBinding other) =>
      occurrence == other.occurrence &&
      fingerprint == other.fingerprint &&
      sourceRegistry == other.sourceRegistry &&
      qualified &&
      other.qualified;
}

final class FtsRuntimeSchema {
  FtsRuntimeSchema({
    required this.version,
    required this.sourceId,
    required List<String> compileOptions,
    required this.schema,
    required this.ftsAvailable,
    required this.qualified,
  }) : compileOptions = List<String>.unmodifiable(compileOptions);
  final String version;
  final String sourceId;
  final List<String> compileOptions;
  final String schema;
  final bool ftsAvailable;
  final bool qualified;

  bool get supported =>
      qualified &&
      ftsAvailable &&
      version.isNotEmpty &&
      sourceId.isNotEmpty &&
      compileOptions.isNotEmpty &&
      schema.isNotEmpty;
  bool agrees(FtsRuntimeSchema other) =>
      version == other.version &&
      sourceId == other.sourceId &&
      schema == other.schema &&
      jsonEncode(compileOptions) == jsonEncode(other.compileOptions);
}

final class FtsContentRow {
  const FtsContentRow(this.id, this.text);
  final int id;
  final String? text;
}

final class FtsResources {
  const FtsResources({
    required this.messages,
    required this.textBytes,
    required this.openHandles,
    required this.ownedDiskBytes,
  });
  final int messages;
  final int textBytes;
  final int openHandles;
  final int ownedDiskBytes;
}

/// The caller owns SQL meaning and supplies only finite, pre-admitted requests.
/// Implementations must bound reads before returning material, not just after.
abstract interface class FtsEvidenceSource {
  Future<FtsResources> resources();
  Future<FtsBinding> binding();
  Future<FtsRuntimeSchema> runtimeSchema();
  Future<List<FtsContentRow>> content();
  Future<List<int>> rawMatch(int requestIndex);
  Future<List<int>> productionSearch(int requestIndex);
  Future<void> close();
}

final class FtsCorpus {
  FtsCorpus({
    required this.identity,
    required this.rawCount,
    required this.productionCount,
  });
  final String identity;
  final int rawCount;
  final int productionCount;
}

final class FtsDimensionEvidence {
  const FtsDimensionEvidence(this.truth, this.reason, {required this.assessed});
  final FtsTruth truth;
  final bool assessed;
  final FtsReason reason;
}

final class FtsEvidenceResult {
  FtsEvidenceResult({
    required Map<FtsDimension, FtsDimensionEvidence> dimensions,
    required this.expectedBinding,
    required this.observedBinding,
    required this.expectedRuntime,
    required this.observedRuntime,
    required this.corpusIdentity,
    required List<String> diagnostics,
    required this.diagnosticCount,
  }) : dimensions = Map<FtsDimension, FtsDimensionEvidence>.unmodifiable(
         dimensions,
       ),
       diagnostics = List<String>.unmodifiable(diagnostics);
  final Map<FtsDimension, FtsDimensionEvidence> dimensions;
  final FtsBinding? expectedBinding;
  final FtsBinding? observedBinding;
  final FtsRuntimeSchema? expectedRuntime;
  final FtsRuntimeSchema? observedRuntime;
  final String corpusIdentity;
  final List<String> diagnostics;
  final int diagnosticCount;
}

final class FtsObservationFailure implements Exception {
  const FtsObservationFailure(this.reason);
  final FtsReason reason;
}

final class _RequestResult {
  const _RequestResult(this.ids, this.failure);
  final List<int>? ids;
  final FtsReason? failure;
}

final class _WorldEvidence {
  FtsBinding? binding;
  FtsRuntimeSchema? runtime;
  List<FtsContentRow>? content;
  FtsReason? contentFailure;
  final raw = <_RequestResult>[];
  final production = <_RequestResult>[];
  FtsReason? fatal;
}

/// One attempt only. All started reads are awaited before close; deadline
/// checks do not pretend to preempt native SQLite work.
final class FtsEvidenceComparison {
  FtsEvidenceComparison({
    required this.now,
    required this.cancelled,
    required this.deadline,
    this.limits = const FtsLimits(),
  });
  final int Function() now;
  final bool Function() cancelled;
  final int deadline;
  final FtsLimits limits;

  void _check() {
    if (cancelled()) {
      throw const FtsObservationFailure(FtsReason.cancelled);
    }
    if (now() >= deadline) {
      throw const FtsObservationFailure(FtsReason.deadline);
    }
  }

  Future<T> _read<T>(Future<T> Function() read) async {
    _check();
    final value = await read();
    _check();
    return value;
  }

  void _resources(FtsResources value) {
    if (value.messages < 0 || value.messages > limits.messages) {
      throw const FtsObservationFailure(FtsReason.rowLimit);
    }
    if (value.textBytes < 0 || value.textBytes > limits.textBytes) {
      throw const FtsObservationFailure(FtsReason.byteLimit);
    }
    if (value.openHandles < 0 || value.openHandles > limits.handles) {
      throw const FtsObservationFailure(FtsReason.handleLimit);
    }
    if (value.ownedDiskBytes < 0 || value.ownedDiskBytes > limits.diskBytes) {
      throw const FtsObservationFailure(FtsReason.diskLimit);
    }
  }

  Future<_RequestResult> _request(Future<List<int>> Function() read) async {
    try {
      final ids = await _read(read);
      if (ids.length > limits.resultIds) {
        return const _RequestResult(null, FtsReason.resultLimit);
      }
      return _RequestResult(List<int>.unmodifiable(ids), null);
    } on FtsObservationFailure {
      rethrow;
    } on Object {
      return const _RequestResult(null, FtsReason.readFailure);
    }
  }

  Future<_WorldEvidence> _observe(
    FtsEvidenceSource source,
    FtsCorpus corpus,
  ) async {
    final result = _WorldEvidence();
    try {
      if (corpus.identity.isEmpty ||
          corpus.rawCount <= 0 ||
          corpus.productionCount <= 0 ||
          corpus.rawCount + corpus.productionCount > limits.requests) {
        throw const FtsObservationFailure(FtsReason.requestLimit);
      }
      _resources(await _read(source.resources));
      result.binding = await _read(source.binding);
      if (result.binding?.qualified != true) {
        throw const FtsObservationFailure(FtsReason.unqualifiedObservation);
      }
      result.runtime = await _read(source.runtimeSchema);
      if (result.runtime?.supported != true) {
        throw const FtsObservationFailure(FtsReason.unsupportedRuntime);
      }
      try {
        final rows = await _read(source.content);
        if (rows.length > limits.messages) {
          throw const FtsObservationFailure(FtsReason.rowLimit);
        }
        final bytes = rows.fold<int>(
          0,
          (sum, row) => sum + utf8.encode(row.text ?? '').length,
        );
        if (bytes > limits.textBytes) {
          throw const FtsObservationFailure(FtsReason.byteLimit);
        }
        if (rows.map((row) => row.id).toSet().length != rows.length) {
          throw const FtsObservationFailure(FtsReason.unqualifiedObservation);
        }
        result.content = List<FtsContentRow>.unmodifiable(rows);
      } on FtsObservationFailure {
        rethrow;
      } on Object {
        result.contentFailure = FtsReason.readFailure;
      }
      for (var i = 0; i < corpus.rawCount; i++) {
        result.raw.add(await _request(() => source.rawMatch(i)));
      }
      for (var i = 0; i < corpus.productionCount; i++) {
        result.production.add(await _request(() => source.productionSearch(i)));
      }
      final end = await _read(source.binding);
      if (result.binding?.agrees(end) != true) {
        throw const FtsObservationFailure(FtsReason.bindingDrift);
      }
      _resources(await _read(source.resources));
    } on FtsObservationFailure catch (failure) {
      result.fatal = failure.reason;
    } on Object {
      result.fatal = FtsReason.readFailure;
    } finally {
      // Cleanup always runs, even after cancellation. Never time out a close.
      try {
        await source.close();
        _check();
      } on FtsObservationFailure catch (failure) {
        result.fatal = failure.reason;
      } on Object {
        result.fatal = FtsReason.cleanupFailure;
      }
    }
    return result;
  }

  Future<FtsEvidenceResult> compare({
    required FtsEvidenceSource expected,
    required FtsEvidenceSource observed,
    required FtsCorpus corpus,
  }) async {
    final a = await _observe(expected, corpus);
    final b = await _observe(observed, corpus);
    final diagnostics = <String>[];
    var diagnosticCount = 0;
    void report(String category) {
      diagnosticCount++;
      if (diagnostics.length < limits.diagnostics) {
        diagnostics.add(category);
      }
    }

    FtsDimensionEvidence unknown(FtsReason reason) =>
        FtsDimensionEvidence(FtsTruth.unknown, reason, assessed: false);
    final dimensions = <FtsDimension, FtsDimensionEvidence>{
      for (final dimension in FtsDimension.values)
        dimension: unknown(FtsReason.unqualifiedObservation),
    };
    dimensions[FtsDimension.qualifiedInternalIndexEvidence] = unknown(
      FtsReason.unqualifiedInternalInspection,
    );
    dimensions[FtsDimension.exhaustiveFtsSemanticEquivalence] = unknown(
      FtsReason.finiteCorpusOnly,
    );
    final fatal = a.fatal ?? b.fatal;
    if (fatal != null) {
      for (final dimension in FtsDimension.values.take(4)) {
        dimensions[dimension] = unknown(fatal);
      }
      report('observation.${fatal.name}');
    } else if (a.binding?.sourceRegistry != b.binding?.sourceRegistry) {
      for (final dimension in FtsDimension.values.take(4)) {
        dimensions[dimension] = unknown(FtsReason.unqualifiedObservation);
      }
      report('binding.sourceRegistry');
    } else if (a.runtime?.agrees(b.runtime!) != true) {
      dimensions[FtsDimension.schemaRuntimeCompatibility] =
          const FtsDimensionEvidence(
            FtsTruth.falseValue,
            FtsReason.incompatibleSchemaRuntime,
            assessed: true,
          );
      for (final dimension in FtsDimension.values.skip(1).take(3)) {
        dimensions[dimension] = unknown(FtsReason.incompatibleSchemaRuntime);
      }
      report('compatibility.mismatch');
    } else {
      dimensions[FtsDimension.schemaRuntimeCompatibility] =
          const FtsDimensionEvidence(
            FtsTruth.trueValue,
            FtsReason.equal,
            assessed: true,
          );
      final left = a.content;
      final right = b.content;
      if (left == null || right == null) {
        dimensions[FtsDimension.contentMaterialEquivalence] = unknown(
          FtsReason.readFailure,
        );
        report('content.readFailure');
      } else {
        final leftMap = <int, String?>{
          for (final row in left) row.id: row.text,
        };
        final rightMap = <int, String?>{
          for (final row in right) row.id: row.text,
        };
        var same = true;
        for (final id in <int>{
          ...leftMap.keys,
          ...rightMap.keys,
        }.toList()..sort()) {
          if (!leftMap.containsKey(id) ||
              !rightMap.containsKey(id) ||
              leftMap[id] != rightMap[id]) {
            same = false;
            report('content.mismatch');
          }
        }
        dimensions[FtsDimension.contentMaterialEquivalence] =
            FtsDimensionEvidence(
              same ? FtsTruth.trueValue : FtsTruth.falseValue,
              same ? FtsReason.equal : FtsReason.mismatch,
              assessed: true,
            );
      }
      for (final entry
          in <FtsDimension, (List<_RequestResult>, List<_RequestResult>)>{
            FtsDimension.boundedRawMatchCorpusEquivalence: (a.raw, b.raw),
            FtsDimension.boundedProductionSearchCorpusEquivalence: (
              a.production,
              b.production,
            ),
          }.entries) {
        var mismatch = false;
        FtsReason? failure;
        for (var i = 0; i < entry.value.$1.length; i++) {
          final l = entry.value.$1[i];
          final r = entry.value.$2[i];
          final error = l.failure ?? r.failure;
          if (error != null) {
            failure ??= error;
            report('${entry.key.name}.request.$i.${error.name}');
          } else if (jsonEncode(l.ids) != jsonEncode(r.ids)) {
            mismatch = true;
            report('${entry.key.name}.request.$i.mismatch');
          }
        }
        dimensions[entry.key] = mismatch
            ? const FtsDimensionEvidence(
                FtsTruth.falseValue,
                FtsReason.mismatch,
                assessed: true,
              )
            : failure != null
            ? unknown(failure)
            : const FtsDimensionEvidence(
                FtsTruth.trueValue,
                FtsReason.equal,
                assessed: true,
              );
      }
    }
    return FtsEvidenceResult(
      dimensions: dimensions,
      expectedBinding: a.binding,
      observedBinding: b.binding,
      expectedRuntime: a.runtime,
      observedRuntime: b.runtime,
      corpusIdentity: corpus.identity,
      diagnostics: diagnostics,
      diagnosticCount: diagnosticCount,
    );
  }
}
