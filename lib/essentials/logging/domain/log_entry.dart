import 'dart:convert';

/// Log severity levels ordered from least to most severe.
enum LogLevel { debug, info, warn, error }

/// A single structured log entry.
///
/// Designed for JSONL serialization — one entry per line, independently
/// parseable. Field names are kept short (`ts`, `lvl`, `src`, `msg`, `ctx`)
/// so the file stays compact while remaining human-readable.
class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String? source;
  final String message;
  final Map<String, dynamic> context;

  const LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.source,
    this.context = const {},
  });

  /// Serialize to a compact JSON string (one JSONL line).
  String toJsonLine() {
    final map = <String, dynamic>{
      'ts': timestamp.toUtc().toIso8601String(),
      'lvl': level.name,
      if (source != null) 'src': source,
      'msg': message,
      if (context.isNotEmpty) 'ctx': context,
    };
    return jsonEncode(map);
  }

  /// Deserialize from a single JSONL line.
  factory LogEntry.fromJsonLine(String line) {
    final map = jsonDecode(line) as Map<String, dynamic>;
    return LogEntry(
      timestamp: DateTime.parse(map['ts'] as String),
      level: LogLevel.values.byName(map['lvl'] as String),
      message: map['msg'] as String,
      source: map['src'] as String?,
      context: map['ctx'] != null
          ? Map<String, dynamic>.from(map['ctx'] as Map)
          : const {},
    );
  }
}
