import 'dart:async';
import 'dart:convert';
import 'dart:io';

const int _defaultCandidateCount = 150000;
const int _defaultBlobBytes = 256;
const String _workerTest =
    'test/qualification/archive_import_memory_worker_test.dart';

Future<void> main(List<String> arguments) async {
  final candidateCount = _intArgument(
    arguments,
    '--candidate-count',
    _defaultCandidateCount,
  );
  final blobBytes = _intArgument(arguments, '--blob-bytes', _defaultBlobBytes);
  if (candidateCount <= 0) {
    throw ArgumentError.value(candidateCount, 'candidateCount', 'must be > 0');
  }
  if (blobBytes <= 0) {
    throw ArgumentError.value(blobBytes, 'blobBytes', 'must be > 0');
  }

  final tempDirectory = await Directory.systemTemp.createTemp(
    'messagelens_archive_memory_',
  );
  final databasePath = '${tempDirectory.path}/synthetic_import.db';
  try {
    final commonEnvironment = <String, String>{
      ...Platform.environment,
      'ML_MEMORY_DB_PATH': databasePath,
      'ML_MEMORY_CANDIDATE_COUNT': '$candidateCount',
      'ML_MEMORY_BLOB_BYTES': '$blobBytes',
    };
    final preparation = await Process.run(
      'flutter',
      <String>['test', _workerTest, '--reporter', 'compact'],
      workingDirectory: Directory.current.path,
      environment: <String, String>{
        ...commonEnvironment,
        'ML_MEMORY_MODE': 'prepare',
      },
    );
    if (preparation.exitCode != 0) {
      stderr.write(preparation.stdout);
      stderr.write(preparation.stderr);
      exitCode = preparation.exitCode;
      return;
    }

    final measurement = await _measureWorker(<String, String>{
      ...commonEnvironment,
      'ML_MEMORY_MODE': 'enrich',
    });
    stdout.writeln(
      jsonEncode(<String, Object?>{
        'candidateCount': candidateCount,
        'baseBlobBytes': blobBytes,
        'peakRssKiB': measurement.peakRssKiB,
        'rssSamplesKiB': measurement.bucketedRssKiB,
        'workerExitCode': measurement.exitCode,
        'workerOutputTail': measurement.workerOutputTail,
      }),
    );
    if (measurement.exitCode != 0) {
      exitCode = measurement.exitCode;
    }
  } finally {
    await tempDirectory.delete(recursive: true);
  }
}

Future<_WorkerMeasurement> _measureWorker(
  Map<String, String> environment,
) async {
  final process = await Process.start(
    'flutter',
    <String>['test', _workerTest, '--reporter', 'compact'],
    workingDirectory: Directory.current.path,
    environment: environment,
  );
  final outputTail = <String>[];
  void retainOutputLine(String line) {
    outputTail.add(line);
    if (outputTail.length > 20) {
      outputTail.removeAt(0);
    }
  }

  final stdoutSubscription = process.stdout
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .listen(retainOutputLine);
  final stderrSubscription = process.stderr
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .listen((line) => retainOutputLine('stderr: $line'));
  final rssSamplesKiB = <int>[];
  var sampleInFlight = false;
  final timer = Timer.periodic(const Duration(milliseconds: 50), (_) async {
    if (sampleInFlight) {
      return;
    }
    sampleInFlight = true;
    try {
      final sample = await _flutterTesterRssKiB(process.pid);
      if (sample != null) {
        rssSamplesKiB.add(sample);
      }
    } finally {
      sampleInFlight = false;
    }
  });

  final workerExitCode = await process.exitCode;
  timer.cancel();
  await stdoutSubscription.cancel();
  await stderrSubscription.cancel();

  final peakRssKiB = rssSamplesKiB.fold<int>(0, (peak, sample) {
    return sample > peak ? sample : peak;
  });
  return _WorkerMeasurement(
    exitCode: workerExitCode,
    peakRssKiB: peakRssKiB,
    bucketedRssKiB: _bucketMaxima(rssSamplesKiB, bucketCount: 10),
    workerOutputTail: outputTail,
  );
}

Future<int?> _flutterTesterRssKiB(int flutterToolPid) async {
  final processSnapshot = await Process.run('/bin/ps', <String>[
    '-axo',
    'pid=,ppid=,rss=,command=',
  ]);
  if (processSnapshot.exitCode != 0) {
    return null;
  }

  final processes = <int, _ProcessSnapshot>{};
  for (final line in const LineSplitter().convert(
    '${processSnapshot.stdout}',
  )) {
    final match = RegExp(r'^\s*(\d+)\s+(\d+)\s+(\d+)\s+(.*)$').firstMatch(line);
    if (match == null) {
      continue;
    }
    final pid = int.parse(match.group(1)!);
    processes[pid] = _ProcessSnapshot(
      parentPid: int.parse(match.group(2)!),
      rssKiB: int.parse(match.group(3)!),
      command: match.group(4)!,
    );
  }

  for (final entry in processes.entries) {
    if (!entry.value.command.contains('flutter_tester')) {
      continue;
    }
    var candidatePid = entry.key;
    final visited = <int>{};
    while (visited.add(candidatePid)) {
      if (candidatePid == flutterToolPid) {
        return entry.value.rssKiB;
      }
      final candidate = processes[candidatePid];
      if (candidate == null || candidate.parentPid <= 1) {
        break;
      }
      candidatePid = candidate.parentPid;
    }
  }
  return null;
}

List<int> _bucketMaxima(List<int> samples, {required int bucketCount}) {
  if (samples.isEmpty) {
    return const <int>[];
  }
  final effectiveBucketCount = samples.length < bucketCount
      ? samples.length
      : bucketCount;
  return <int>[
    for (var bucket = 0; bucket < effectiveBucketCount; bucket += 1)
      samples
          .sublist(
            (samples.length * bucket) ~/ effectiveBucketCount,
            (samples.length * (bucket + 1)) ~/ effectiveBucketCount,
          )
          .fold<int>(0, (peak, sample) => sample > peak ? sample : peak),
  ];
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
  final value = _stringArgument(arguments, name);
  if (value == null) {
    return fallback;
  }
  return int.parse(value);
}

final class _WorkerMeasurement {
  const _WorkerMeasurement({
    required this.exitCode,
    required this.peakRssKiB,
    required this.bucketedRssKiB,
    required this.workerOutputTail,
  });

  final int exitCode;
  final int peakRssKiB;
  final List<int> bucketedRssKiB;
  final List<String> workerOutputTail;
}

final class _ProcessSnapshot {
  const _ProcessSnapshot({
    required this.parentPid,
    required this.rssKiB,
    required this.command,
  });

  final int parentPid;
  final int rssKiB;
  final String command;
}
