import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../../../../api.dart' as rust_api;
import '../../domain/ports/message_extractor_port.dart';

class RustMessageExtractor implements MessageExtractorPort {
  RustMessageExtractor({
    void Function(String message, {Map<String, dynamic>? context})? logInfo,
    void Function(String message, {Map<String, dynamic>? context})? logWarn,
    void Function(String message, {Map<String, dynamic>? context})? logError,
  }) : _logInfo = logInfo,
       _logWarn = logWarn,
       _logError = logError;

  final void Function(String message, {Map<String, dynamic>? context})?
  _logInfo;
  final void Function(String message, {Map<String, dynamic>? context})?
  _logWarn;
  final void Function(String message, {Map<String, dynamic>? context})?
  _logError;
  static Future<bool>? _blobExtractionAvailability;

  static final Uint8List _attributedBodySmokeTestBlob = _hexBytes(
    '040B73747265616D747970656481E803840140848484124E534174747269'
    '6275746564537472696E67008484084E534F626A65637400859284848408'
    '4E53537472696E67019484012B045445535486840269490104928484840C'
    '4E5344696374696F6E617279009484016901928496961D5F5F6B494D4D65'
    '7373616765506172744174747269627574654E616D658692848484084E53'
    '4E756D626572008484074E5356616C7565009484012A84999900868686',
  );

  String get extractorPath {
    if (Platform.isMacOS) {
      final executableDir = File(Platform.resolvedExecutable).parent.path;
      final bundledPath = '$executableDir/extract_messages_limited';
      if (File(bundledPath).existsSync()) {
        return bundledPath;
      }
    }
    return 'target/release/extract_messages_limited';
  }

  void _info(String message, {Map<String, dynamic>? context}) {
    _logInfo?.call(message, context: context);
  }

  void _warn(String message, {Map<String, dynamic>? context}) {
    _logWarn?.call(message, context: context);
  }

  void _error(String message, {Map<String, dynamic>? context}) {
    _logError?.call(message, context: context);
  }

  static Uint8List _hexBytes(String hex) {
    final bytes = <int>[];
    for (var index = 0; index < hex.length; index += 2) {
      bytes.add(int.parse(hex.substring(index, index + 2), radix: 16));
    }
    return Uint8List.fromList(bytes);
  }

  @override
  Future<Map<int, String>> extractAllMessageTexts({
    int? limit,
    String? dbPath,
  }) async {
    final resolvedExtractorPath = extractorPath;
    final workingDirectory = Directory.current.path;
    _info(
      'Starting Rust message extraction',
      context: <String, dynamic>{
        'extractorPath': resolvedExtractorPath,
        'workingDirectory': workingDirectory,
        'dbPath': dbPath,
        'limit': limit,
      },
    );

    final args = <String>[];
    if (limit != null) {
      args.add(limit.toString());
    }
    if (dbPath != null) {
      args.add(dbPath);
    }
    final process = await Process.run(
      resolvedExtractorPath,
      args,
      workingDirectory: workingDirectory,
    );

    final stdoutText = process.stdout.toString();
    final stderrText = process.stderr.toString();
    if (process.exitCode != 0) {
      _error(
        'Rust extractor failed',
        context: <String, dynamic>{
          'extractorPath': resolvedExtractorPath,
          'workingDirectory': workingDirectory,
          'dbPath': dbPath,
          'limit': limit,
          'exitCode': process.exitCode,
          'stderr': stderrText,
          'stdoutPreview': stdoutText.length > 500
              ? stdoutText.substring(0, 500)
              : stdoutText,
        },
      );
      throw StateError(
        'Rust extractor failed: ${process.exitCode}\n$stderrText',
      );
    }

    _info(
      'Rust extractor completed',
      context: <String, dynamic>{
        'extractorPath': resolvedExtractorPath,
        'workingDirectory': workingDirectory,
        'dbPath': dbPath,
        'limit': limit,
        'exitCode': process.exitCode,
        'stderr': stderrText,
      },
    );

    final data = jsonDecode(stdoutText) as Map<String, dynamic>;
    final messages = data['messages'] as List<dynamic>;
    final map = <int, String>{};
    for (final m in messages) {
      final row = m as Map<String, dynamic>;
      map[row['rowid'] as int] = row['text'] as String;
    }

    _info(
      'Rust extractor decoded messages',
      context: <String, dynamic>{
        'extractorPath': resolvedExtractorPath,
        'decodedCount': map.length,
        'dbPath': dbPath,
        'limit': limit,
      },
    );

    return map;
  }

  @override
  Future<Map<int, String>> extractMessageTextsFromBlobs(
    Map<int, Uint8List> attributedBodyBlobsByWorkId, {
    MessageExtractionProgressObserver? onProgress,
  }) async {
    final map = <int, String>{};
    var completedWorkCount = 0;
    final totalWorkCount = attributedBodyBlobsByWorkId.length;

    for (final entry in attributedBodyBlobsByWorkId.entries) {
      try {
        final decoded = rust_api
            .decodeTypedstreamBlob(blob: entry.value)
            .trim();
        if (decoded.isNotEmpty) {
          map[entry.key] = decoded;
        }
      } catch (error) {
        _warn(
          'Rust blob extractor failed for attributed body work item',
          context: <String, dynamic>{'workId': entry.key, 'error': '$error'},
        );
      }
      completedWorkCount += 1;
      if (completedWorkCount == totalWorkCount ||
          completedWorkCount % 1000 == 0) {
        onProgress?.call(
          completedWorkCount: completedWorkCount,
          totalWorkCount: totalWorkCount,
          lastCompletedWorkId: entry.key,
        );
        await Future<void>.delayed(Duration.zero);
      }
    }

    return map;
  }

  @override
  Future<bool> isBlobExtractionAvailable() async {
    final cachedAvailability = _blobExtractionAvailability;
    if (cachedAvailability != null) {
      return cachedAvailability;
    }

    final availability = _checkBlobExtractionAvailability();
    _blobExtractionAvailability = availability;
    return availability;
  }

  Future<bool> _checkBlobExtractionAvailability() async {
    try {
      final decoded = rust_api.decodeTypedstreamBlob(
        blob: _attributedBodySmokeTestBlob,
      );
      final available = decoded == 'TEST';
      if (!available) {
        _warn(
          'Rust blob extractor smoke test returned unexpected text',
          context: <String, dynamic>{'decoded': decoded},
        );
      }
      return available;
    } catch (error) {
      _warn(
        'Rust blob extractor unavailable',
        context: <String, dynamic>{'error': '$error'},
      );
      return false;
    }
  }

  @override
  Future<bool> isAvailable() async {
    try {
      final path = extractorPath;
      final file = File(path);
      final exists = file.existsSync();
      if (!exists) {
        _warn(
          'Rust extractor not found',
          context: <String, dynamic>{
            'extractorPath': path,
            'workingDirectory': Directory.current.path,
          },
        );
        return false;
      }
      try {
        final stat = file.statSync();
        _info(
          'Rust extractor available',
          context: <String, dynamic>{
            'extractorPath': path,
            'workingDirectory': Directory.current.path,
            'sizeBytes': stat.size,
            'modifiedAt': stat.modified.toUtc().toIso8601String(),
          },
        );
        return true;
      } catch (error) {
        _warn(
          'Rust extractor stat failed',
          context: <String, dynamic>{
            'extractorPath': path,
            'workingDirectory': Directory.current.path,
            'error': '$error',
          },
        );
        return false;
      }
    } catch (error) {
      _error(
        'Rust extractor availability check threw',
        context: <String, dynamic>{
          'workingDirectory': Directory.current.path,
          'error': '$error',
        },
      );
      return false;
    }
  }

  Future<bool> buildExtractor() async {
    try {
      final result = await Process.run('cargo', [
        'build',
        '--release',
        '--bin',
        'extract_messages_limited',
      ]);
      final succeeded = result.exitCode == 0;
      if (!succeeded) {
        _warn(
          'Rust extractor build failed',
          context: <String, dynamic>{
            'exitCode': result.exitCode,
            'stdout': '${result.stdout}',
            'stderr': '${result.stderr}',
          },
        );
      }
      return succeeded;
    } catch (error) {
      _error(
        'Rust extractor build threw',
        context: <String, dynamic>{'error': '$error'},
      );
      return false;
    }
  }
}
