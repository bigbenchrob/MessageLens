import 'dart:convert';
import 'dart:io';

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
      throw Exception(
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
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }
}
