import 'package:meta/meta.dart';

import 'attachment_archive_location_configuration.dart';

enum AttachmentArchiveAdoptionTransactionState {
  prepared('prepared'),
  configurationPersisted('configuration_persisted');

  const AttachmentArchiveAdoptionTransactionState(this.serializedName);

  final String serializedName;

  static AttachmentArchiveAdoptionTransactionState parse(String value) {
    return switch (value) {
      'prepared' => AttachmentArchiveAdoptionTransactionState.prepared,
      'configuration_persisted' =>
        AttachmentArchiveAdoptionTransactionState.configurationPersisted,
      _ => throw FormatException(
        'Unsupported attachment archive adoption transaction state: $value',
      ),
    };
  }
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
  });

  static const int currentFormatVersion = 1;

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
    );
  }

  Map<String, Object> toJson() {
    return <String, Object>{
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
  }

  factory AttachmentArchiveAdoptionTransaction.fromJson(
    Map<String, Object?> json,
  ) {
    final formatVersion = _requiredInt(json, 'formatVersion');
    if (formatVersion != currentFormatVersion) {
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

  bool get requiresRecovery {
    return outcome ==
            AttachmentArchiveAdoptionOutcome
                .rollbackPendingPreviousUnavailable ||
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
}
