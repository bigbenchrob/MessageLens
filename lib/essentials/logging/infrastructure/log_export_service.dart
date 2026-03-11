import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../infrastructure/log_file_writer.dart';

/// Collects log files, prepends a system info header, and presents the
/// exported log to the user via email (mailto:) and Finder reveal.
class LogExportService {
  final LogFileWriter _writer;

  LogExportService(this._writer);

  /// Export logs, open email client, and reveal file in Finder.
  ///
  /// Returns the path of the exported file, or `null` if export failed.
  Future<String?> exportAndPresent() async {
    try {
      // Flush in-memory buffer to disk before reading.
      await _writer.flush();

      final logDir = _writer.logDir;
      if (!logDir.existsSync()) {
        return null;
      }

      final now = DateTime.now();
      final stamp =
          '${now.year}-${_pad(now.month)}-${_pad(now.day)}_${_pad(now.hour)}${_pad(now.minute)}${_pad(now.second)}';
      final exportFile = File('${logDir.path}/diagnostic_$stamp.log');

      // Build the header.
      final header = _buildHeader(now);

      // Concatenate current + previous log files.
      final sink = exportFile.openWrite();
      sink.write(header);

      final currentLog = _writer.logFile;
      if (currentLog.existsSync()) {
        sink.write(await currentLog.readAsString());
      }

      final prevLog = _writer.prevLogFile;
      if (prevLog.existsSync()) {
        sink.write('\n--- Previous session log ---\n');
        sink.write(await prevLog.readAsString());
      }

      await sink.flush();
      await sink.close();

      // Open email client.
      final subject = Uri.encodeComponent(
        'MessageLens Diagnostic Log — $stamp',
      );
      final body = Uri.encodeComponent(
        'Please attach the log file that was just opened in Finder.\n\n'
        'Describe the issue here:\n',
      );
      final mailto = Uri.parse(
        'mailto:support@messagelens.app?subject=$subject&body=$body',
      );
      await launchUrl(mailto);

      // Reveal the exported file in Finder.
      await Process.run('open', ['-R', exportFile.path]);

      return exportFile.path;
    } catch (e) {
      debugPrint('LogExportService: export failed: $e');
      return null;
    }
  }

  String _buildHeader(DateTime now) {
    final macosVersion = Platform.operatingSystemVersion;
    final buf = StringBuffer()
      ..writeln('=== MessageLens — Diagnostic Log ===')
      ..writeln('macOS: $macosVersion')
      ..writeln('Exported: ${now.toUtc().toIso8601String()}')
      ..writeln('====================================')
      ..writeln();
    return buf.toString();
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}
