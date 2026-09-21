import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

import 'attachment_archive_location_configuration.dart';

enum AttachmentArchiveAdoptionTransactionState {
  prepared('prepared'),
  configurationPersisted('configuration_persisted'),
  activeRemediationPending('active_remediation_pending');

  const AttachmentArchiveAdoptionTransactionState(this.serializedName);

  final String serializedName;

  static AttachmentArchiveAdoptionTransactionState parse(String value) {
    return switch (value) {
      'prepared' => AttachmentArchiveAdoptionTransactionState.prepared,
      'configuration_persisted' =>
        AttachmentArchiveAdoptionTransactionState.configurationPersisted,
      'active_remediation_pending' =>
        AttachmentArchiveAdoptionTransactionState.activeRemediationPending,
      _ => throw FormatException(
        'Unsupported attachment archive adoption transaction state: $value',
      ),
    };
  }
}

enum AttachmentArchiveAdoptionTransactionKind {
  complete('complete'),
  verifiedBehind('verified_behind');

  const AttachmentArchiveAdoptionTransactionKind(this.serializedName);

  final String serializedName;

  static AttachmentArchiveAdoptionTransactionKind parse(String value) {
    return switch (value) {
      'complete' => AttachmentArchiveAdoptionTransactionKind.complete,
      'verified_behind' =>
        AttachmentArchiveAdoptionTransactionKind.verifiedBehind,
      _ => throw FormatException(
        'Unsupported attachment archive adoption transaction kind: $value',
      ),
    };
  }
}

/// One immutable historical payload obligation bound before archive switch.
@immutable
final class AttachmentArchiveRemediationPayload {
  const AttachmentArchiveRemediationPayload({
    required this.relativePath,
    required this.expectedSizeBytes,
    required this.expectedSha256,
  });

  final String relativePath;
  final int expectedSizeBytes;
  final String expectedSha256;

  Map<String, Object> toJson() {
    return <String, Object>{
      'relativePath': relativePath,
      'expectedSizeBytes': expectedSizeBytes,
      'expectedSha256': expectedSha256,
    };
  }

  factory AttachmentArchiveRemediationPayload.fromJson(
    Map<String, Object?> json,
  ) {
    return AttachmentArchiveRemediationPayload(
      relativePath: AttachmentArchiveAdoptionTransaction._requiredString(
        json,
        'relativePath',
      ),
      expectedSizeBytes: AttachmentArchiveAdoptionTransaction._requiredInt(
        json,
        'expectedSizeBytes',
      ),
      expectedSha256: AttachmentArchiveAdoptionTransaction._requiredSha256(
        json,
        'expectedSha256',
      ),
    );
  }

  void validate() {
    final normalized = path.normalize(relativePath);
    if (relativePath.isEmpty ||
        path.isAbsolute(relativePath) ||
        normalized != relativePath ||
        normalized == '.' ||
        normalized == '..' ||
        normalized.startsWith('../') ||
        expectedSizeBytes < 0 ||
        !RegExp(r'^[0-9a-f]{64}$').hasMatch(expectedSha256)) {
      throw const FormatException(
        'Attachment archive remediation payload evidence is invalid.',
      );
    }
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AttachmentArchiveRemediationPayload &&
            relativePath == other.relativePath &&
            expectedSizeBytes == other.expectedSizeBytes &&
            expectedSha256 == other.expectedSha256;
  }

  @override
  int get hashCode =>
      Object.hash(relativePath, expectedSizeBytes, expectedSha256);
}

/// The complete durable state for one narrow configuration-switch window.
///
/// This record contains no payload manifest, copy receipt, file progress,
/// staging identity, capacity evidence, or pause/resume state.
@immutable
final class AttachmentArchiveAdoptionTransaction {
  const AttachmentArchiveAdoptionTransaction({
    required this.formatVersion,
    required this.transactionId,
    required this.state,
    required this.previousConfiguration,
    required this.intendedConfiguration,
    required this.sourceCanonicalIdentity,
    required this.candidateCanonicalIdentity,
    required this.sourceLocationGeneration,
    required this.verificationContentDigest,
    required this.sourceStructuralSnapshotFingerprint,
    required this.candidateStructuralSnapshotFingerprint,
    required this.verifiedFileCount,
    required this.verifiedBytes,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    this.kind = AttachmentArchiveAdoptionTransactionKind.complete,
    this.remediationPayloads = const [],
  });

  static const int currentFormatVersion = 2;
  static const int maximumRemediationPayloadCount = 256;
  static const int maximumRemediationBytes = 1024 * 1024 * 1024;

  final int formatVersion;
  final String transactionId;
  final AttachmentArchiveAdoptionTransactionState state;
  final AttachmentArchiveLocationConfiguration previousConfiguration;
  final AttachmentArchiveLocationConfiguration intendedConfiguration;
  final String sourceCanonicalIdentity;
  final String candidateCanonicalIdentity;
  final int sourceLocationGeneration;
  final String verificationContentDigest;
  final String sourceStructuralSnapshotFingerprint;
  final String candidateStructuralSnapshotFingerprint;
  final int verifiedFileCount;
  final int verifiedBytes;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
  final AttachmentArchiveAdoptionTransactionKind kind;
  final List<AttachmentArchiveRemediationPayload> remediationPayloads;

  int get remediationBytes => remediationPayloads.fold<int>(
    0,
    (total, payload) => total + payload.expectedSizeBytes,
  );

  bool get hasCrossedActiveAuthorityBoundary {
    return state ==
        AttachmentArchiveAdoptionTransactionState.activeRemediationPending;
  }

  AttachmentArchiveAdoptionTransaction withState(
    AttachmentArchiveAdoptionTransactionState value, {
    required DateTime updatedAtUtc,
  }) {
    return AttachmentArchiveAdoptionTransaction(
      formatVersion: formatVersion,
      transactionId: transactionId,
      state: value,
      previousConfiguration: previousConfiguration,
      intendedConfiguration: intendedConfiguration,
      sourceCanonicalIdentity: sourceCanonicalIdentity,
      candidateCanonicalIdentity: candidateCanonicalIdentity,
      sourceLocationGeneration: sourceLocationGeneration,
      verificationContentDigest: verificationContentDigest,
      sourceStructuralSnapshotFingerprint: sourceStructuralSnapshotFingerprint,
      candidateStructuralSnapshotFingerprint:
          candidateStructuralSnapshotFingerprint,
      verifiedFileCount: verifiedFileCount,
      verifiedBytes: verifiedBytes,
      createdAtUtc: createdAtUtc,
      updatedAtUtc: updatedAtUtc.toUtc(),
      kind: kind,
      remediationPayloads: remediationPayloads,
    );
  }

  Map<String, Object> toJson() {
    final json = <String, Object>{
      'formatVersion': formatVersion,
      'transactionId': transactionId,
      'state': state.serializedName,
      'previousConfiguration': previousConfiguration.toJson(),
      'intendedConfiguration': intendedConfiguration.toJson(),
      'sourceCanonicalIdentity': sourceCanonicalIdentity,
      'candidateCanonicalIdentity': candidateCanonicalIdentity,
      'sourceLocationGeneration': sourceLocationGeneration,
      'verificationContentDigest': verificationContentDigest,
      'sourceStructuralSnapshotFingerprint':
          sourceStructuralSnapshotFingerprint,
      'candidateStructuralSnapshotFingerprint':
          candidateStructuralSnapshotFingerprint,
      'verifiedFileCount': verifiedFileCount,
      'verifiedBytes': verifiedBytes,
      'createdAtUtc': createdAtUtc.toUtc().toIso8601String(),
      'updatedAtUtc': updatedAtUtc.toUtc().toIso8601String(),
    };
    if (formatVersion >= 2) {
      json['kind'] = kind.serializedName;
      json['remediationPayloads'] = remediationPayloads
          .map((payload) => payload.toJson())
          .toList(growable: false);
    }
    return json;
  }

  factory AttachmentArchiveAdoptionTransaction.fromJson(
    Map<String, Object?> json,
  ) {
    final formatVersion = _requiredInt(json, 'formatVersion');
    if (formatVersion != 1 && formatVersion != currentFormatVersion) {
      throw FormatException(
        'Unsupported attachment archive adoption transaction format: '
        '$formatVersion',
      );
    }
    final transaction = AttachmentArchiveAdoptionTransaction(
      formatVersion: formatVersion,
      transactionId: _requiredString(json, 'transactionId'),
      state: AttachmentArchiveAdoptionTransactionState.parse(
        _requiredString(json, 'state'),
      ),
      previousConfiguration: AttachmentArchiveLocationConfiguration.fromJson(
        _requiredMap(json, 'previousConfiguration'),
      ),
      intendedConfiguration: AttachmentArchiveLocationConfiguration.fromJson(
        _requiredMap(json, 'intendedConfiguration'),
      ),
      sourceCanonicalIdentity: _requiredString(json, 'sourceCanonicalIdentity'),
      candidateCanonicalIdentity: _requiredString(
        json,
        'candidateCanonicalIdentity',
      ),
      sourceLocationGeneration: _requiredInt(json, 'sourceLocationGeneration'),
      verificationContentDigest: _requiredSha256(
        json,
        'verificationContentDigest',
      ),
      sourceStructuralSnapshotFingerprint: _requiredSha256(
        json,
        'sourceStructuralSnapshotFingerprint',
      ),
      candidateStructuralSnapshotFingerprint: _requiredSha256(
        json,
        'candidateStructuralSnapshotFingerprint',
      ),
      verifiedFileCount: _requiredInt(json, 'verifiedFileCount'),
      verifiedBytes: _requiredInt(json, 'verifiedBytes'),
      createdAtUtc: _requiredUtcDateTime(json, 'createdAtUtc'),
      updatedAtUtc: _requiredUtcDateTime(json, 'updatedAtUtc'),
      kind: formatVersion == 1
          ? AttachmentArchiveAdoptionTransactionKind.complete
          : AttachmentArchiveAdoptionTransactionKind.parse(
              _requiredString(json, 'kind'),
            ),
      remediationPayloads: formatVersion == 1
          ? const <AttachmentArchiveRemediationPayload>[]
          : _requiredList(json, 'remediationPayloads')
                .map(
                  (value) => AttachmentArchiveRemediationPayload.fromJson(
                    _requiredObject(value, 'remediationPayloads item'),
                  ),
                )
                .toList(growable: false),
    );
    transaction.validate();
    return transaction;
  }

  void validate() {
    if (!RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    ).hasMatch(transactionId)) {
      throw const FormatException(
        'Attachment archive adoption transaction identity is invalid.',
      );
    }
    if (previousConfiguration == intendedConfiguration) {
      throw const FormatException(
        'Attachment archive adoption configurations must differ.',
      );
    }
    if (intendedConfiguration.mode !=
            AttachmentArchiveLocationMode.customExternal ||
        intendedConfiguration.customWritePolicy !=
            AttachmentArchiveCustomWritePolicy.activeArchive) {
      throw const FormatException(
        'Attachment archive adoption intended configuration is not active.',
      );
    }
    if (sourceCanonicalIdentity.trim().isEmpty ||
        candidateCanonicalIdentity.trim().isEmpty ||
        sourceCanonicalIdentity == candidateCanonicalIdentity ||
        sourceLocationGeneration < 0 ||
        verifiedFileCount < 0 ||
        verifiedBytes < 0 ||
        updatedAtUtc.isBefore(createdAtUtc)) {
      throw const FormatException(
        'Attachment archive adoption transaction evidence is invalid.',
      );
    }
    for (final digest in <String>[
      verificationContentDigest,
      sourceStructuralSnapshotFingerprint,
      candidateStructuralSnapshotFingerprint,
    ]) {
      if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(digest)) {
        throw const FormatException(
          'Attachment archive adoption transaction digest is invalid.',
        );
      }
    }
    final seenPaths = <String>{};
    for (final payload in remediationPayloads) {
      payload.validate();
      if (!seenPaths.add(payload.relativePath)) {
        throw const FormatException(
          'Attachment archive remediation paths must be unique.',
        );
      }
    }
    if (kind == AttachmentArchiveAdoptionTransactionKind.complete &&
        (remediationPayloads.isNotEmpty ||
            state ==
                AttachmentArchiveAdoptionTransactionState
                    .activeRemediationPending)) {
      throw const FormatException(
        'Complete archive adoption cannot contain remediation state.',
      );
    }
    if (kind == AttachmentArchiveAdoptionTransactionKind.verifiedBehind &&
        (remediationPayloads.isEmpty ||
            remediationPayloads.length > maximumRemediationPayloadCount ||
            remediationBytes > maximumRemediationBytes)) {
      throw const FormatException(
        'Verified-behind remediation exceeds the bounded adoption policy.',
      );
    }
  }

  static String _requiredString(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Adoption transaction $key must be a string.');
    }
    return value;
  }

  static int _requiredInt(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is! int) {
      throw FormatException('Adoption transaction $key must be an integer.');
    }
    return value;
  }

  static String _requiredSha256(Map<String, Object?> json, String key) {
    final value = _requiredString(json, key);
    if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(value)) {
      throw FormatException('Adoption transaction $key must be SHA-256.');
    }
    return value;
  }

  static DateTime _requiredUtcDateTime(Map<String, Object?> json, String key) {
    final value = DateTime.tryParse(_requiredString(json, key));
    if (value == null || !value.isUtc) {
      throw FormatException('Adoption transaction $key must be UTC.');
    }
    return value;
  }

  static Map<String, Object?> _requiredMap(
    Map<String, Object?> json,
    String key,
  ) {
    final value = json[key];
    if (value is! Map) {
      throw FormatException('Adoption transaction $key must be an object.');
    }
    return Map<String, Object?>.from(value);
  }

  static List<Object?> _requiredList(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is! List) {
      throw FormatException('Adoption transaction $key must be an array.');
    }
    return List<Object?>.from(value);
  }

  static Map<String, Object?> _requiredObject(Object? value, String label) {
    if (value is! Map) {
      throw FormatException('Adoption transaction $label must be an object.');
    }
    return Map<String, Object?>.from(value);
  }
}

enum AttachmentArchiveAdoptionOutcome {
  adopted,
  noPendingRecovery,
  preparedTransactionAbandoned,
  sourceChangedCheckAgain,
  candidateChangedCheckAgain,
  sourceUnavailable,
  candidateUnavailable,
  candidateNoLongerWritable,
  verificationEvidenceInvalid,
  rollbackRestoredPrevious,
  rollbackPendingPreviousUnavailable,
  configurationConflict,
  failed,
  remediationPending,
  remediationComplete,
}

@immutable
final class AttachmentArchiveAdoptionResult {
  const AttachmentArchiveAdoptionResult({
    required this.outcome,
    this.transactionId,
    this.issue,
  });

  final AttachmentArchiveAdoptionOutcome outcome;
  final String? transactionId;
  final String? issue;

  bool get isAdopted => outcome == AttachmentArchiveAdoptionOutcome.adopted;

  bool get isActiveWithPendingRemediation {
    return outcome == AttachmentArchiveAdoptionOutcome.remediationPending;
  }

  bool get requiresRecovery {
    return outcome ==
            AttachmentArchiveAdoptionOutcome
                .rollbackPendingPreviousUnavailable ||
        outcome == AttachmentArchiveAdoptionOutcome.remediationPending ||
        outcome == AttachmentArchiveAdoptionOutcome.configurationConflict ||
        (outcome == AttachmentArchiveAdoptionOutcome.failed &&
            transactionId != null);
  }
}

enum AttachmentArchiveAdoptionFailurePoint {
  beforePreparedTransactionWrite,
  afterPreparedTransactionWrite,
  beforeConfigurationPersistence,
  afterConfigurationPersistence,
  afterConfigurationPersistedWrite,
  beforeNewLocationResolution,
  beforePostSwitchCandidateFingerprint,
  beforeWritableRootAdmission,
  beforeWritableRootValidation,
  beforeRollbackConfigurationPersistence,
  beforePreviousSourceValidation,
  afterActiveRemediationBoundary,
  duringRemediation,
}

@immutable
final class AttachmentArchiveRemediationProgress {
  const AttachmentArchiveRemediationProgress({
    required this.filesCompleted,
    required this.totalFiles,
    required this.bytesCompleted,
    required this.totalBytes,
  });

  final int filesCompleted;
  final int totalFiles;
  final int bytesCompleted;
  final int totalBytes;

  double get fractionComplete {
    if (totalBytes > 0) {
      return (bytesCompleted / totalBytes).clamp(0, 1);
    }
    if (totalFiles > 0) {
      return (filesCompleted / totalFiles).clamp(0, 1);
    }
    return 1;
  }
}

typedef AttachmentArchiveRemediationProgressCallback =
    void Function(AttachmentArchiveRemediationProgress progress);
