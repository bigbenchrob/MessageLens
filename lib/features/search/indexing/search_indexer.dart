import '../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';

class SearchIndexerRunRecord {
  const SearchIndexerRunRecord({
    this.lastRebuildStartedAt,
    this.lastRebuildFinishedAt,
    this.status = SearchIndexerRunStatus.idle,
    this.lastRebuildMessageCount,
    this.lastMessage,
  });

  final DateTime? lastRebuildStartedAt;
  final DateTime? lastRebuildFinishedAt;
  final SearchIndexerRunStatus status;
  final int? lastRebuildMessageCount;
  final String? lastMessage;

  SearchIndexerRunRecord copyWith({
    DateTime? lastRebuildStartedAt,
    DateTime? lastRebuildFinishedAt,
    SearchIndexerRunStatus? status,
    int? lastRebuildMessageCount,
    String? lastMessage,
  }) {
    return SearchIndexerRunRecord(
      lastRebuildStartedAt: lastRebuildStartedAt ?? this.lastRebuildStartedAt,
      lastRebuildFinishedAt:
          lastRebuildFinishedAt ?? this.lastRebuildFinishedAt,
      status: status ?? this.status,
      lastRebuildMessageCount:
          lastRebuildMessageCount ?? this.lastRebuildMessageCount,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastRebuildStartedAt': lastRebuildStartedAt?.toIso8601String(),
      'lastRebuildFinishedAt': lastRebuildFinishedAt?.toIso8601String(),
      'status': status.name,
      'lastRebuildMessageCount': lastRebuildMessageCount,
      'lastMessage': lastMessage,
    };
  }

  factory SearchIndexerRunRecord.fromJson(Map<String, dynamic> json) {
    return SearchIndexerRunRecord(
      lastRebuildStartedAt: _parseDate(json['lastRebuildStartedAt'] as String?),
      lastRebuildFinishedAt: _parseDate(
        json['lastRebuildFinishedAt'] as String?,
      ),
      status: SearchIndexerRunStatus.values.firstWhere(
        (value) => value.name == json['status'],
        orElse: () => SearchIndexerRunStatus.idle,
      ),
      lastRebuildMessageCount: json['lastRebuildMessageCount'] as int?,
      lastMessage: json['lastMessage'] as String?,
    );
  }
}

DateTime? _parseDate(String? value) {
  if (value == null) {
    return null;
  }
  return DateTime.tryParse(value);
}

enum SearchIndexerRunStatus { idle, succeeded, failed }

typedef _LogCallback =
    void Function(String message, {Map<String, dynamic> context});

class SearchIndexContext {
  SearchIndexContext({
    required this.db,
    _LogCallback? infoLogger,
    _LogCallback? errorLogger,
    DateTime Function()? now,
  }) : _logInfo = infoLogger,
       _logError = errorLogger,
       _now = now ?? DateTime.now;

  final WorkingDatabase db;
  final _LogCallback? _logInfo;
  final _LogCallback? _logError;
  final DateTime Function() _now;

  DateTime get currentTime => _now();

  void info(String message, {Map<String, dynamic> context = const {}}) {
    _logInfo?.call(message, context: context);
  }

  void error(String message, {Map<String, dynamic> context = const {}}) {
    _logError?.call(message, context: context);
  }
}

abstract class SearchIndexer {
  String get id;

  String get description => id;

  bool get supportsPartialRebuild => false;

  Future<void> rebuildAll(SearchIndexContext context);

  Future<void> rebuildForMessages(
    SearchIndexContext context,
    Iterable<int> messageIds,
  ) async {
    return;
  }

  Future<void> validate(SearchIndexContext context);
}
