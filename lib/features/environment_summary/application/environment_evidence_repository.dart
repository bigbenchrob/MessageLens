import 'package:path/path.dart' as path;

import '../../../essentials/db/application/read_only_sql_guard.dart';
import '../domain/entities/environment_summary.dart';

final class EnvironmentRootEvidence {
  const EnvironmentRootEvidence({
    required this.availability,
    required this.displayVolumeName,
    this.issue,
  });

  final EnvironmentAvailability availability;
  final String displayVolumeName;
  final String? issue;
}

final class EnvironmentMessageEvidence {
  EnvironmentMessageEvidence({
    required this.projectedMessageCount,
    required this.conversationCount,
    required this.attachmentReferenceCount,
    required Iterable<EnvironmentMessageSourceEvidence> sources,
  }) : sources = List<EnvironmentMessageSourceEvidence>.unmodifiable(sources);

  final int projectedMessageCount;
  final int conversationCount;
  final int attachmentReferenceCount;
  final List<EnvironmentMessageSourceEvidence> sources;
}

final class EnvironmentMessageSourceEvidence {
  const EnvironmentMessageSourceEvidence({
    required this.sourceId,
    required this.sourceKey,
    required this.kind,
    required this.displayLabel,
    required this.projectedMessageCount,
    this.registryLabel,
    this.canonicalSourcePath,
  });

  final int sourceId;
  final String sourceKey;
  final EnvironmentMessageSourceKind kind;
  final String displayLabel;
  final String? registryLabel;
  final String? canonicalSourcePath;
  final int projectedMessageCount;
}

final class EnvironmentMessageDateRangeEvidence {
  const EnvironmentMessageDateRangeEvidence({
    required this.sourceId,
    this.earliestMessageUtc,
    this.latestMessageUtc,
  });

  final int sourceId;
  final DateTime? earliestMessageUtc;
  final DateTime? latestMessageUtc;
}

final class EnvironmentContactsEvidence {
  const EnvironmentContactsEvidence({
    required this.projectedContactCount,
    required this.linkedHandleCount,
    required this.importedChannelCount,
  });

  final int projectedContactCount;
  final int linkedHandleCount;
  final int importedChannelCount;
}

final class EnvironmentFtsEvidence {
  const EnvironmentFtsEvidence({
    required this.isAvailable,
    required this.rowCount,
  });

  final bool isAvailable;
  final int? rowCount;
}

abstract interface class EnvironmentEvidenceRepository {
  Future<EnvironmentRootEvidence> inspectDataRoot(String canonicalRootPath);

  Future<List<EnvironmentDatabaseSummary>> inspectDatabases(
    String canonicalRootPath,
  );

  Future<EnvironmentMessageEvidence> readMessageEvidence(
    String canonicalRootPath,
  );

  Future<List<EnvironmentMessageDateRangeEvidence>> readMessageDateRanges(
    String canonicalRootPath,
    Iterable<int> sourceIds,
  );

  Future<EnvironmentContactsEvidence> readContactsEvidence(
    String canonicalRootPath,
  );

  Future<EnvironmentFtsEvidence> readFtsEvidence(String canonicalRootPath);
}

final class EnvironmentEvidenceUnavailableException implements Exception {
  const EnvironmentEvidenceUnavailableException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Strict SQL allow-list for the Environment read-only repository.
///
/// The shared guard rejects mutation statements. This narrower boundary also
/// rejects every PRAGMA except the connection-local read protections and the
/// read-only schema-version query used by this feature.
void assertEnvironmentSummaryReadOnlySql(String sql) {
  assertReadOnlySql(sql, boundary: 'Environment summary evidence repository');
  final normalized = sql
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceFirst(RegExp(r';$'), '');
  if (!normalized.startsWith('pragma ')) {
    return;
  }
  const allowedPragmas = <String>{
    'pragma query_only = on',
    'pragma busy_timeout = 3000',
    'pragma user_version',
  };
  if (!allowedPragmas.contains(normalized)) {
    throw StateError(
      'Environment summary evidence repository rejects mutating PRAGMAs',
    );
  }
}

String environmentDisplayVolumeName(String canonicalPath) {
  final segments = path
      .split(path.normalize(canonicalPath))
      .where((segment) => segment != path.separator)
      .toList(growable: false);
  if (segments.length >= 2 && segments.first == 'Volumes') {
    return segments[1];
  }
  return 'This Mac';
}

bool environmentPathUsesExternalVolume(String canonicalPath) {
  return path.isWithin('/Volumes', path.normalize(canonicalPath));
}
