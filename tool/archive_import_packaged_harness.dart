import 'dart:async';
import 'dart:convert';
import 'dart:io';

const int _defaultInterruptionCandidateCount = 2501;
const int _defaultMemoryCandidateCount = 150000;
const int _defaultBlobBytes = 256;
const String _qualificationToken = 'synthetic-disposable-archive';

Future<void> main(List<String> arguments) async {
  final executable = _stringArgument(arguments, '--executable');
  if (executable == null || !File(executable).existsSync()) {
    throw ArgumentError('--executable must name the packaged app executable.');
  }
  final memoryCandidateCount = _intArgument(
    arguments,
    '--memory-candidate-count',
    _defaultMemoryCandidateCount,
  );
  final interruptionCandidateCount = _intArgument(
    arguments,
    '--interruption-candidate-count',
    _defaultInterruptionCandidateCount,
  );

  final interruptionResults = <Map<String, Object?>>[];
  for (final expectation in <_SourceInterruptionExpectation>[
    const _SourceInterruptionExpectation(
      boundary: 'beforeFirstSourcePageCommit',
      committedMessageCount: 0,
      committedRelationshipCount: 0,
    ),
    const _SourceInterruptionExpectation(
      boundary: 'afterMultipleSourcePageCommits',
      committedMessageCount: 1000,
      committedRelationshipCount: 0,
    ),
    _SourceInterruptionExpectation(
      boundary: 'beforeRelationshipImport',
      committedMessageCount: interruptionCandidateCount,
      committedRelationshipCount: 0,
    ),
    _SourceInterruptionExpectation(
      boundary: 'beforeGraphProjectionCommit',
      committedMessageCount: interruptionCandidateCount,
      committedRelationshipCount: 1,
    ),
  ]) {
    interruptionResults.add(
      await _runSourceInterruptionCase(
        executable,
        expectation: expectation,
        candidateCount: interruptionCandidateCount,
      ),
    );
  }
  for (final expectation in const <_InterruptionExpectation>[
    _InterruptionExpectation('duringDecoder', 500),
    _InterruptionExpectation('afterDecoderBeforePersistence', 500),
    _InterruptionExpectation('afterRichTextPersistence', 1000),
  ]) {
    interruptionResults.add(
      await _runInterruptionCase(
        executable,
        expectation: expectation,
        candidateCount: interruptionCandidateCount,
      ),
    );
  }

  final memoryResult = await _runMemoryCase(
    executable,
    candidateCount: memoryCandidateCount,
  );
  stdout.writeln(
    jsonEncode(<String, Object?>{
      'packagedExecutable': executable,
      'interruptionCases': interruptionResults,
      'memoryQualification': memoryResult,
    }),
  );
}

Future<Map<String, Object?>> _runSourceInterruptionCase(
  String executable, {
  required _SourceInterruptionExpectation expectation,
  required int candidateCount,
}) async {
  final directory = await Directory.systemTemp.createTemp(
    'messagelens_packaged_source_interrupt_',
  );
  try {
    final paths = _QualificationPaths(directory);
    const overlaySentinelBytes = <int>[1, 3, 5, 7];
    const attachmentSentinelBytes = <int>[2, 4, 6, 8];
    await paths.overlaySentinel.writeAsBytes(overlaySentinelBytes);
    await paths.attachmentDirectory.create();
    await paths.attachmentSentinel.writeAsBytes(attachmentSentinelBytes);
    await _runToCompletion(
      executable,
      paths.environment(mode: 'prepareSource', candidateCount: candidateCount),
    );

    final interruptedProcess = await Process.start(
      executable,
      const <String>[],
      environment: paths.environment(
        mode: 'sourcePipeline',
        candidateCount: candidateCount,
        pauseBoundary: expectation.boundary,
      ),
    );
    final output = _ProcessOutputCapture(interruptedProcess);
    await _waitForMarker(paths.marker);
    final killed = interruptedProcess.kill(ProcessSignal.sigkill);
    final killedExitCode = await interruptedProcess.exitCode;
    await output.finish();
    if (!killed) {
      throw StateError('Could not terminate packaged source process.');
    }

    await _runToCompletion(
      executable,
      paths.environment(
        mode: 'inspectSourcePipeline',
        candidateCount: candidateCount,
      ),
    );
    final afterKill = await _readResult(paths.result);
    if (afterKill['importedMessageCount'] !=
            expectation.committedMessageCount ||
        afterKill['importedRelationshipCount'] !=
            expectation.committedRelationshipCount ||
        afterKill['graphMessageCount'] != 0) {
      throw StateError(
        '${expectation.boundary} retained unexpected source pipeline state: '
        '$afterKill',
      );
    }

    await _runToCompletion(
      executable,
      paths.environment(mode: 'sourcePipeline', candidateCount: candidateCount),
    );
    final relaunch = await _readResult(paths.result);
    final expectedInsertedAfterRelaunch =
        candidateCount - expectation.committedMessageCount;
    if (relaunch['inputMessageCount'] != expectedInsertedAfterRelaunch) {
      throw StateError('${expectation.boundary} replay exceeded its boundary.');
    }
    await _runToCompletion(
      executable,
      paths.environment(
        mode: 'inspectSourcePipeline',
        candidateCount: candidateCount,
      ),
    );
    final finalInspection = await _readResult(paths.result);
    if (finalInspection['importedMessageCount'] != candidateCount ||
        finalInspection['importedRelationshipCount'] != 1 ||
        finalInspection['graphMessageCount'] != candidateCount) {
      throw StateError(
        '${expectation.boundary} did not converge after relaunch.',
      );
    }
    if (!_sameBytes(
          await paths.overlaySentinel.readAsBytes(),
          overlaySentinelBytes,
        ) ||
        !_sameBytes(
          await paths.attachmentSentinel.readAsBytes(),
          attachmentSentinelBytes,
        )) {
      throw StateError(
        '${expectation.boundary} mutated preservation sentinels.',
      );
    }

    return <String, Object?>{
      'boundary': expectation.boundary,
      'processExitCode': killedExitCode,
      'committedMessagesAfterKill': expectation.committedMessageCount,
      'committedRelationshipsAfterKill': expectation.committedRelationshipCount,
      'messagesProcessedAfterRelaunch': expectedInsertedAfterRelaunch,
      'finalMessageCount': candidateCount,
      'finalRelationshipCount': 1,
      'finalGraphMessageCount': candidateCount,
      'overlayUnchanged': true,
      'attachmentArchiveUnchanged': true,
    };
  } finally {
    await directory.delete(recursive: true);
  }
}

Future<Map<String, Object?>> _runInterruptionCase(
  String executable, {
  required _InterruptionExpectation expectation,
  required int candidateCount,
}) async {
  final directory = await Directory.systemTemp.createTemp(
    'messagelens_packaged_interrupt_',
  );
  try {
    final paths = _QualificationPaths(directory);
    const overlaySentinelBytes = <int>[1, 3, 5, 7];
    const attachmentSentinelBytes = <int>[2, 4, 6, 8];
    await paths.overlaySentinel.writeAsBytes(overlaySentinelBytes);
    await paths.attachmentDirectory.create();
    await paths.attachmentSentinel.writeAsBytes(attachmentSentinelBytes);
    await _runToCompletion(
      executable,
      paths.environment(mode: 'prepare', candidateCount: candidateCount),
    );

    final interruptedProcess = await Process.start(
      executable,
      const <String>[],
      environment: paths.environment(
        mode: 'enrich',
        candidateCount: candidateCount,
        pauseBoundary: expectation.boundary,
      ),
    );
    final output = _ProcessOutputCapture(interruptedProcess);
    await _waitForMarker(paths.marker);
    final killed = interruptedProcess.kill(ProcessSignal.sigkill);
    final killedExitCode = await interruptedProcess.exitCode;
    await output.finish();
    if (!killed) {
      throw StateError('Could not terminate packaged qualification process.');
    }

    await _runToCompletion(
      executable,
      paths.environment(mode: 'inspect', candidateCount: candidateCount),
    );
    final afterKill = await _readResult(paths.result);
    if (afterKill['enrichedMessageCount'] != expectation.committedCount) {
      throw StateError(
        '${expectation.boundary} retained '
        '${afterKill['enrichedMessageCount']} rows; expected '
        '${expectation.committedCount}.',
      );
    }

    await _runToCompletion(
      executable,
      paths.environment(mode: 'enrich', candidateCount: candidateCount),
    );
    final relaunch = await _readResult(paths.result);
    final expectedRemaining = candidateCount - expectation.committedCount;
    if (relaunch['inputCandidateCount'] != expectedRemaining ||
        relaunch['enrichedMessageCount'] != expectedRemaining) {
      throw StateError('${expectation.boundary} replay exceeded its boundary.');
    }
    await _runToCompletion(
      executable,
      paths.environment(mode: 'inspect', candidateCount: candidateCount),
    );
    final finalInspection = await _readResult(paths.result);
    if (finalInspection['totalMessageCount'] != candidateCount ||
        finalInspection['enrichedMessageCount'] != candidateCount ||
        finalInspection['remainingCandidateCount'] != 0) {
      throw StateError(
        '${expectation.boundary} did not converge after relaunch.',
      );
    }
    if (!_sameBytes(
          await paths.overlaySentinel.readAsBytes(),
          overlaySentinelBytes,
        ) ||
        !_sameBytes(
          await paths.attachmentSentinel.readAsBytes(),
          attachmentSentinelBytes,
        )) {
      throw StateError(
        '${expectation.boundary} mutated preservation sentinels.',
      );
    }

    return <String, Object?>{
      'boundary': expectation.boundary,
      'processExitCode': killedExitCode,
      'committedRowsAfterKill': expectation.committedCount,
      'rowsProcessedAfterRelaunch': expectedRemaining,
      'finalMessageCount': candidateCount,
      'finalRemainingCandidateCount': 0,
      'overlayUnchanged': true,
      'attachmentArchiveUnchanged': true,
    };
  } finally {
    await directory.delete(recursive: true);
  }
}

Future<Map<String, Object?>> _runMemoryCase(
  String executable, {
  required int candidateCount,
}) async {
  final directory = await Directory.systemTemp.createTemp(
    'messagelens_packaged_memory_',
  );
  try {
    final paths = _QualificationPaths(directory);
    await _runToCompletion(
      executable,
      paths.environment(mode: 'prepare', candidateCount: candidateCount),
    );
    final process = await Process.start(
      executable,
      const <String>[],
      environment: paths.environment(
        mode: 'enrich',
        candidateCount: candidateCount,
      ),
    );
    final output = _ProcessOutputCapture(process);
    final samples = <int>[];
    var sampleInFlight = false;
    final timer = Timer.periodic(const Duration(milliseconds: 50), (_) async {
      if (sampleInFlight) {
        return;
      }
      sampleInFlight = true;
      try {
        final sample = await _rssKiB(process.pid);
        if (sample != null) {
          samples.add(sample);
        }
      } finally {
        sampleInFlight = false;
      }
    });
    final exitCode = await process.exitCode;
    timer.cancel();
    final captured = await output.finish();
    if (exitCode != 0) {
      throw StateError('Packaged memory worker failed: $captured');
    }
    final workerResult = await _readResult(paths.result);
    if (workerResult['inputCandidateCount'] != candidateCount ||
        workerResult['enrichedMessageCount'] != candidateCount) {
      throw StateError('Packaged memory workload did not process all rows.');
    }
    final peakRssKiB = samples.fold<int>(0, (peak, sample) {
      return sample > peak ? sample : peak;
    });
    return <String, Object?>{
      'candidateCount': candidateCount,
      'peakRssKiB': peakRssKiB,
      'rssBucketMaximaKiB': _bucketMaxima(samples, bucketCount: 10),
      'sampleCount': samples.length,
      'elapsedMilliseconds': workerResult['elapsedMilliseconds'],
      'decoderPageCount': workerResult['decoderPageCount'],
      'workerExitCode': exitCode,
    };
  } finally {
    await directory.delete(recursive: true);
  }
}

Future<void> _runToCompletion(
  String executable,
  Map<String, String> environment,
) async {
  final process = await Process.run(
    executable,
    const <String>[],
    environment: environment,
  );
  if (process.exitCode != 0) {
    throw StateError(
      'Packaged worker failed (${process.exitCode}): '
      '${process.stdout}\n${process.stderr}',
    );
  }
}

Future<void> _waitForMarker(File marker) async {
  final stopwatch = Stopwatch()..start();
  while (!marker.existsSync()) {
    if (stopwatch.elapsed > const Duration(seconds: 30)) {
      throw StateError('Timed out waiting for packaged interruption marker.');
    }
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
}

Future<int?> _rssKiB(int pid) async {
  final result = await Process.run('/bin/ps', <String>[
    '-o',
    'rss=',
    '-p',
    '$pid',
  ]);
  if (result.exitCode != 0) {
    return null;
  }
  return int.tryParse('${result.stdout}'.trim());
}

Future<Map<String, Object?>> _readResult(File result) async {
  return Map<String, Object?>.from(
    jsonDecode(await result.readAsString()) as Map,
  );
}

List<int> _bucketMaxima(List<int> samples, {required int bucketCount}) {
  if (samples.isEmpty) {
    return const <int>[];
  }
  final count = samples.length < bucketCount ? samples.length : bucketCount;
  return <int>[
    for (var bucket = 0; bucket < count; bucket += 1)
      samples
          .sublist(
            (samples.length * bucket) ~/ count,
            (samples.length * (bucket + 1)) ~/ count,
          )
          .fold<int>(0, (peak, sample) => sample > peak ? sample : peak),
  ];
}

bool _sameBytes(List<int> left, List<int> right) {
  if (left.length != right.length) {
    return false;
  }
  for (var index = 0; index < left.length; index += 1) {
    if (left[index] != right[index]) {
      return false;
    }
  }
  return true;
}

String? _stringArgument(List<String> arguments, String name) {
  final prefix = '$name=';
  for (final argument in arguments) {
    if (argument.startsWith(prefix)) {
      return argument.substring(prefix.length);
    }
  }
  return null;
}

int _intArgument(List<String> arguments, String name, int fallback) {
  final raw = _stringArgument(arguments, name);
  return raw == null ? fallback : int.parse(raw);
}

final class _InterruptionExpectation {
  const _InterruptionExpectation(this.boundary, this.committedCount);

  final String boundary;
  final int committedCount;
}

final class _SourceInterruptionExpectation {
  const _SourceInterruptionExpectation({
    required this.boundary,
    required this.committedMessageCount,
    required this.committedRelationshipCount,
  });

  final String boundary;
  final int committedMessageCount;
  final int committedRelationshipCount;
}

final class _QualificationPaths {
  const _QualificationPaths(this.root);

  final Directory root;

  File get database => File('${root.path}/synthetic_import.db');
  File get sourceDatabase => File('${root.path}/synthetic_chat.db');
  File get graphDatabase => File('${root.path}/synthetic_graph.db');
  File get result => File('${root.path}/result.json');
  File get marker => File('${root.path}/pause.marker');
  File get metrics => File('${root.path}/page_metrics.jsonl');
  File get overlaySentinel => File('${root.path}/overlay-sentinel.bin');
  Directory get attachmentDirectory =>
      Directory('${root.path}/attachment_archive');
  File get attachmentSentinel =>
      File('${attachmentDirectory.path}/preserved.bin');

  Map<String, String> environment({
    required String mode,
    required int candidateCount,
    String? pauseBoundary,
  }) {
    return <String, String>{
      ...Platform.environment,
      'ML_PACKAGED_QUALIFICATION_TOKEN': _qualificationToken,
      'ML_PACKAGED_MODE': mode,
      'ML_PACKAGED_DB_PATH': database.path,
      'ML_PACKAGED_SOURCE_DB_PATH': sourceDatabase.path,
      'ML_PACKAGED_GRAPH_DB_PATH': graphDatabase.path,
      'ML_PACKAGED_RESULT_PATH': result.path,
      'ML_PACKAGED_METRICS_PATH': metrics.path,
      'ML_PACKAGED_CANDIDATE_COUNT': '$candidateCount',
      'ML_PACKAGED_BLOB_BYTES': '$_defaultBlobBytes',
      if (pauseBoundary != null) 'ML_PACKAGED_PAUSE_BOUNDARY': pauseBoundary,
      if (pauseBoundary != null) 'ML_PACKAGED_PAUSE_PAGE_ORDINAL': '2',
      if (pauseBoundary != null) 'ML_PACKAGED_MARKER_PATH': marker.path,
    };
  }
}

final class _ProcessOutputCapture {
  _ProcessOutputCapture(Process process)
    : _stdout = process.stdout.transform(utf8.decoder).join(),
      _stderr = process.stderr.transform(utf8.decoder).join();

  final Future<String> _stdout;
  final Future<String> _stderr;

  Future<String> finish() async {
    return '${await _stdout}\n${await _stderr}';
  }
}
