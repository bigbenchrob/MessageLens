import 'package:meta/meta.dart';

import 'attachment_archive_location_configuration.dart';

enum AttachmentArchiveRelocationStage {
  selected,
  preflighting,
  preflighted,
  inventorying,
  inventoryComplete,
  copying,
  verifying,
  destinationFinalizing,
  destinationFinalized,
  configurationSwitching,
  activated,
  rollbackRestoredOldConfiguration,
  sourceRetained,
  paused,
  cancelled,
  failed;

  bool get isTerminal {
    return switch (this) {
      sourceRetained ||
      rollbackRestoredOldConfiguration ||
      cancelled ||
      failed => true,
      _ => false,
    };
  }
}

enum AttachmentArchiveRelocationEntryKind {
  metadataKnown,
  unreferencedPreservationPayload,
}

enum AttachmentArchiveRelocationDeferredReason {
  sourceUnavailable,
  destinationUnavailable,
  insufficientCapacity,
  mutationUnavailable,
  userPaused,
}

@immutable
final class AttachmentArchiveRelocationManifestEntry {
  const AttachmentArchiveRelocationManifestEntry({
    required this.relativePath,
    required this.sizeBytes,
    required this.kind,
    required this.knownSha256,
    required this.metadataRowCount,
  });

  factory AttachmentArchiveRelocationManifestEntry.fromJson(
    Map<String, Object?> json,
  ) {
    return AttachmentArchiveRelocationManifestEntry(
      relativePath: _requiredString(json, 'relativePath'),
      sizeBytes: _requiredNonNegativeInt(json, 'sizeBytes'),
      kind: AttachmentArchiveRelocationEntryKind.values.byName(
        _requiredString(json, 'kind'),
      ),
      knownSha256: _optionalString(json, 'knownSha256'),
      metadataRowCount: _requiredNonNegativeInt(json, 'metadataRowCount'),
    );
  }

  final String relativePath;
  final int sizeBytes;
  final AttachmentArchiveRelocationEntryKind kind;
  final String? knownSha256;
  final int metadataRowCount;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'relativePath': relativePath,
      'sizeBytes': sizeBytes,
      'kind': kind.name,
      'knownSha256': knownSha256,
      'metadataRowCount': metadataRowCount,
    };
  }
}

@immutable
final class AttachmentArchiveRelocationCopyReceipt {
  const AttachmentArchiveRelocationCopyReceipt({
    required this.index,
    required this.relativePath,
    required this.sizeBytes,
    required this.sha256,
  });

  factory AttachmentArchiveRelocationCopyReceipt.fromJson(
    Map<String, Object?> json,
  ) {
    return AttachmentArchiveRelocationCopyReceipt(
      index: _requiredNonNegativeInt(json, 'index'),
      relativePath: _requiredString(json, 'relativePath'),
      sizeBytes: _requiredNonNegativeInt(json, 'sizeBytes'),
      sha256: _requiredString(json, 'sha256'),
    );
  }

  final int index;
  final String relativePath;
  final int sizeBytes;
  final String sha256;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'index': index,
      'relativePath': relativePath,
      'sizeBytes': sizeBytes,
      'sha256': sha256,
    };
  }
}

@immutable
final class AttachmentArchiveRelocationJournal {
  const AttachmentArchiveRelocationJournal({
    required this.formatVersion,
    required this.operationId,
    required this.stage,
    required this.archiveInstanceId,
    required this.sourceRootPath,
    required this.sourceConfiguration,
    required this.sourceLocationGeneration,
    required this.destinationParentBookmarkDataBase64,
    required this.destinationParentLastKnownPath,
    required this.destinationVolumeName,
    required this.stagingDirectoryName,
    required this.finalDirectoryName,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    required this.inventoryCompletedAtUtc,
    required this.manifestSha256,
    required this.expectedFileCount,
    required this.expectedByteCount,
    required this.metadataRowCount,
    required this.unreferencedFileCount,
    required this.operationalDebrisCount,
    required this.copiedFileCount,
    required this.copiedByteCount,
    required this.verifiedFileCount,
    required this.verifiedByteCount,
    required this.availableCapacityBytes,
    required this.requiredCapacityBytes,
    required this.previousConfiguration,
    required this.intendedConfiguration,
    required this.activationOccurred,
    required this.sourceRetained,
    required this.deferredReason,
    required this.failure,
    required this.resumeStage,
  });

  factory AttachmentArchiveRelocationJournal.selected({
    required String operationId,
    required String archiveInstanceId,
    required String sourceRootPath,
    required AttachmentArchiveLocationConfiguration sourceConfiguration,
    required int sourceLocationGeneration,
    required String destinationParentBookmarkDataBase64,
    required String destinationParentLastKnownPath,
    required String? destinationVolumeName,
    required DateTime nowUtc,
  }) {
    return AttachmentArchiveRelocationJournal(
      formatVersion: currentFormatVersion,
      operationId: operationId,
      stage: AttachmentArchiveRelocationStage.selected,
      archiveInstanceId: archiveInstanceId,
      sourceRootPath: sourceRootPath,
      sourceConfiguration: sourceConfiguration,
      sourceLocationGeneration: sourceLocationGeneration,
      destinationParentBookmarkDataBase64: destinationParentBookmarkDataBase64,
      destinationParentLastKnownPath: destinationParentLastKnownPath,
      destinationVolumeName: destinationVolumeName,
      stagingDirectoryName: '.messagelens-attachment-relocation-$operationId',
      finalDirectoryName: 'MessageLens Attachment Archive $operationId',
      createdAtUtc: nowUtc,
      updatedAtUtc: nowUtc,
      inventoryCompletedAtUtc: null,
      manifestSha256: null,
      expectedFileCount: 0,
      expectedByteCount: 0,
      metadataRowCount: 0,
      unreferencedFileCount: 0,
      operationalDebrisCount: 0,
      copiedFileCount: 0,
      copiedByteCount: 0,
      verifiedFileCount: 0,
      verifiedByteCount: 0,
      availableCapacityBytes: null,
      requiredCapacityBytes: null,
      previousConfiguration: sourceConfiguration,
      intendedConfiguration: null,
      activationOccurred: false,
      sourceRetained: false,
      deferredReason: null,
      failure: null,
      resumeStage: null,
    );
  }

  static const int currentFormatVersion = 1;

  final int formatVersion;
  final String operationId;
  final AttachmentArchiveRelocationStage stage;
  final String archiveInstanceId;
  final String sourceRootPath;
  final AttachmentArchiveLocationConfiguration sourceConfiguration;
  final int sourceLocationGeneration;
  final String destinationParentBookmarkDataBase64;
  final String destinationParentLastKnownPath;
  final String? destinationVolumeName;
  final String stagingDirectoryName;
  final String finalDirectoryName;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
  final DateTime? inventoryCompletedAtUtc;
  final String? manifestSha256;
  final int expectedFileCount;
  final int expectedByteCount;
  final int metadataRowCount;
  final int unreferencedFileCount;
  final int operationalDebrisCount;
  final int copiedFileCount;
  final int copiedByteCount;
  final int verifiedFileCount;
  final int verifiedByteCount;
  final int? availableCapacityBytes;
  final int? requiredCapacityBytes;
  final AttachmentArchiveLocationConfiguration previousConfiguration;
  final AttachmentArchiveLocationConfiguration? intendedConfiguration;
  final bool activationOccurred;
  final bool sourceRetained;
  final AttachmentArchiveRelocationDeferredReason? deferredReason;
  final String? failure;
  final AttachmentArchiveRelocationStage? resumeStage;

  AttachmentArchiveRelocationJournal copyWith({
    AttachmentArchiveRelocationStage? stage,
    String? destinationParentBookmarkDataBase64,
    String? destinationParentLastKnownPath,
    String? destinationVolumeName,
    DateTime? updatedAtUtc,
    DateTime? inventoryCompletedAtUtc,
    String? manifestSha256,
    int? expectedFileCount,
    int? expectedByteCount,
    int? metadataRowCount,
    int? unreferencedFileCount,
    int? operationalDebrisCount,
    int? copiedFileCount,
    int? copiedByteCount,
    int? verifiedFileCount,
    int? verifiedByteCount,
    int? availableCapacityBytes,
    int? requiredCapacityBytes,
    AttachmentArchiveLocationConfiguration? intendedConfiguration,
    bool? activationOccurred,
    bool? sourceRetained,
    AttachmentArchiveRelocationDeferredReason? deferredReason,
    bool clearDeferredReason = false,
    String? failure,
    bool clearFailure = false,
    AttachmentArchiveRelocationStage? resumeStage,
    bool clearResumeStage = false,
  }) {
    return AttachmentArchiveRelocationJournal(
      formatVersion: formatVersion,
      operationId: operationId,
      stage: stage ?? this.stage,
      archiveInstanceId: archiveInstanceId,
      sourceRootPath: sourceRootPath,
      sourceConfiguration: sourceConfiguration,
      sourceLocationGeneration: sourceLocationGeneration,
      destinationParentBookmarkDataBase64:
          destinationParentBookmarkDataBase64 ??
          this.destinationParentBookmarkDataBase64,
      destinationParentLastKnownPath:
          destinationParentLastKnownPath ?? this.destinationParentLastKnownPath,
      destinationVolumeName:
          destinationVolumeName ?? this.destinationVolumeName,
      stagingDirectoryName: stagingDirectoryName,
      finalDirectoryName: finalDirectoryName,
      createdAtUtc: createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      inventoryCompletedAtUtc:
          inventoryCompletedAtUtc ?? this.inventoryCompletedAtUtc,
      manifestSha256: manifestSha256 ?? this.manifestSha256,
      expectedFileCount: expectedFileCount ?? this.expectedFileCount,
      expectedByteCount: expectedByteCount ?? this.expectedByteCount,
      metadataRowCount: metadataRowCount ?? this.metadataRowCount,
      unreferencedFileCount:
          unreferencedFileCount ?? this.unreferencedFileCount,
      operationalDebrisCount:
          operationalDebrisCount ?? this.operationalDebrisCount,
      copiedFileCount: copiedFileCount ?? this.copiedFileCount,
      copiedByteCount: copiedByteCount ?? this.copiedByteCount,
      verifiedFileCount: verifiedFileCount ?? this.verifiedFileCount,
      verifiedByteCount: verifiedByteCount ?? this.verifiedByteCount,
      availableCapacityBytes:
          availableCapacityBytes ?? this.availableCapacityBytes,
      requiredCapacityBytes:
          requiredCapacityBytes ?? this.requiredCapacityBytes,
      previousConfiguration: previousConfiguration,
      intendedConfiguration:
          intendedConfiguration ?? this.intendedConfiguration,
      activationOccurred: activationOccurred ?? this.activationOccurred,
      sourceRetained: sourceRetained ?? this.sourceRetained,
      deferredReason: clearDeferredReason
          ? null
          : deferredReason ?? this.deferredReason,
      failure: clearFailure ? null : failure ?? this.failure,
      resumeStage: clearResumeStage ? null : resumeStage ?? this.resumeStage,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'formatVersion': formatVersion,
      'operationId': operationId,
      'stage': stage.name,
      'archiveInstanceId': archiveInstanceId,
      'sourceRootPath': sourceRootPath,
      'sourceConfiguration': sourceConfiguration.toJson(),
      'sourceLocationGeneration': sourceLocationGeneration,
      'destinationParentBookmarkDataBase64':
          destinationParentBookmarkDataBase64,
      'destinationParentLastKnownPath': destinationParentLastKnownPath,
      'destinationVolumeName': destinationVolumeName,
      'stagingDirectoryName': stagingDirectoryName,
      'finalDirectoryName': finalDirectoryName,
      'createdAtUtc': createdAtUtc.toIso8601String(),
      'updatedAtUtc': updatedAtUtc.toIso8601String(),
      'inventoryCompletedAtUtc': inventoryCompletedAtUtc?.toIso8601String(),
      'manifestSha256': manifestSha256,
      'expectedFileCount': expectedFileCount,
      'expectedByteCount': expectedByteCount,
      'metadataRowCount': metadataRowCount,
      'unreferencedFileCount': unreferencedFileCount,
      'operationalDebrisCount': operationalDebrisCount,
      'copiedFileCount': copiedFileCount,
      'copiedByteCount': copiedByteCount,
      'verifiedFileCount': verifiedFileCount,
      'verifiedByteCount': verifiedByteCount,
      'availableCapacityBytes': availableCapacityBytes,
      'requiredCapacityBytes': requiredCapacityBytes,
      'previousConfiguration': previousConfiguration.toJson(),
      'intendedConfiguration': intendedConfiguration?.toJson(),
      'activationOccurred': activationOccurred,
      'sourceRetained': sourceRetained,
      'deferredReason': deferredReason?.name,
      'failure': failure,
      'resumeStage': resumeStage?.name,
    };
  }

  factory AttachmentArchiveRelocationJournal.fromJson(
    Map<String, Object?> json,
  ) {
    final formatVersion = _requiredNonNegativeInt(json, 'formatVersion');
    if (formatVersion != currentFormatVersion) {
      throw FormatException(
        'Unsupported attachment relocation journal version: $formatVersion',
      );
    }
    return AttachmentArchiveRelocationJournal(
      formatVersion: formatVersion,
      operationId: _requiredString(json, 'operationId'),
      stage: AttachmentArchiveRelocationStage.values.byName(
        _requiredString(json, 'stage'),
      ),
      archiveInstanceId: _requiredString(json, 'archiveInstanceId'),
      sourceRootPath: _requiredString(json, 'sourceRootPath'),
      sourceConfiguration: AttachmentArchiveLocationConfiguration.fromJson(
        _requiredMap(json, 'sourceConfiguration'),
      ),
      sourceLocationGeneration: _requiredNonNegativeInt(
        json,
        'sourceLocationGeneration',
      ),
      destinationParentBookmarkDataBase64: _requiredString(
        json,
        'destinationParentBookmarkDataBase64',
      ),
      destinationParentLastKnownPath: _requiredString(
        json,
        'destinationParentLastKnownPath',
      ),
      destinationVolumeName: _optionalString(json, 'destinationVolumeName'),
      stagingDirectoryName: _requiredString(json, 'stagingDirectoryName'),
      finalDirectoryName: _requiredString(json, 'finalDirectoryName'),
      createdAtUtc: DateTime.parse(_requiredString(json, 'createdAtUtc')),
      updatedAtUtc: DateTime.parse(_requiredString(json, 'updatedAtUtc')),
      inventoryCompletedAtUtc: _optionalDateTime(
        json,
        'inventoryCompletedAtUtc',
      ),
      manifestSha256: _optionalString(json, 'manifestSha256'),
      expectedFileCount: _requiredNonNegativeInt(json, 'expectedFileCount'),
      expectedByteCount: _requiredNonNegativeInt(json, 'expectedByteCount'),
      metadataRowCount: _requiredNonNegativeInt(json, 'metadataRowCount'),
      unreferencedFileCount: _requiredNonNegativeInt(
        json,
        'unreferencedFileCount',
      ),
      operationalDebrisCount: _requiredNonNegativeInt(
        json,
        'operationalDebrisCount',
      ),
      copiedFileCount: _requiredNonNegativeInt(json, 'copiedFileCount'),
      copiedByteCount: _requiredNonNegativeInt(json, 'copiedByteCount'),
      verifiedFileCount: _requiredNonNegativeInt(json, 'verifiedFileCount'),
      verifiedByteCount: _requiredNonNegativeInt(json, 'verifiedByteCount'),
      availableCapacityBytes: _optionalNonNegativeInt(
        json,
        'availableCapacityBytes',
      ),
      requiredCapacityBytes: _optionalNonNegativeInt(
        json,
        'requiredCapacityBytes',
      ),
      previousConfiguration: AttachmentArchiveLocationConfiguration.fromJson(
        _requiredMap(json, 'previousConfiguration'),
      ),
      intendedConfiguration: _optionalMap(
        json,
        'intendedConfiguration',
      )?.let(AttachmentArchiveLocationConfiguration.fromJson),
      activationOccurred: _requiredBool(json, 'activationOccurred'),
      sourceRetained: _requiredBool(json, 'sourceRetained'),
      deferredReason: _optionalString(
        json,
        'deferredReason',
      )?.let(AttachmentArchiveRelocationDeferredReason.values.byName),
      failure: _optionalString(json, 'failure'),
      resumeStage: _optionalString(
        json,
        'resumeStage',
      )?.let(AttachmentArchiveRelocationStage.values.byName),
    );
  }
}

extension _Let<T> on T {
  R let<R>(R Function(T value) transform) => transform(this);
}

@immutable
final class AttachmentArchiveRelocationProgress {
  const AttachmentArchiveRelocationProgress({
    required this.operationId,
    required this.stage,
    required this.filesCopied,
    required this.filesVerified,
    required this.bytesCopied,
    required this.bytesVerified,
    required this.expectedFiles,
    required this.expectedBytes,
    required this.deferredReason,
    required this.isResumable,
    required this.activationOccurred,
    required this.sourceRetained,
  });

  factory AttachmentArchiveRelocationProgress.fromJournal(
    AttachmentArchiveRelocationJournal journal,
  ) {
    return AttachmentArchiveRelocationProgress(
      operationId: journal.operationId,
      stage: journal.stage,
      filesCopied: journal.copiedFileCount,
      filesVerified: journal.verifiedFileCount,
      bytesCopied: journal.copiedByteCount,
      bytesVerified: journal.verifiedByteCount,
      expectedFiles: journal.expectedFileCount,
      expectedBytes: journal.expectedByteCount,
      deferredReason: journal.deferredReason,
      isResumable: !journal.stage.isTerminal,
      activationOccurred: journal.activationOccurred,
      sourceRetained: journal.sourceRetained,
    );
  }

  final String operationId;
  final AttachmentArchiveRelocationStage stage;
  final int filesCopied;
  final int filesVerified;
  final int bytesCopied;
  final int bytesVerified;
  final int expectedFiles;
  final int expectedBytes;
  final AttachmentArchiveRelocationDeferredReason? deferredReason;
  final bool isResumable;
  final bool activationOccurred;
  final bool sourceRetained;
}

String _requiredString(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! String || value.isEmpty) {
    throw FormatException('$key must be a non-empty string.');
  }
  return value;
}

String? _optionalString(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value == null) {
    return null;
  }
  if (value is! String) {
    throw FormatException('$key must be a string.');
  }
  return value;
}

int _requiredNonNegativeInt(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! int || value < 0) {
    throw FormatException('$key must be a non-negative integer.');
  }
  return value;
}

int? _optionalNonNegativeInt(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value == null) {
    return null;
  }
  if (value is! int || value < 0) {
    throw FormatException('$key must be a non-negative integer.');
  }
  return value;
}

bool _requiredBool(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! bool) {
    throw FormatException('$key must be a boolean.');
  }
  return value;
}

Map<String, Object?> _requiredMap(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! Map) {
    throw FormatException('$key must be an object.');
  }
  return Map<String, Object?>.from(value);
}

Map<String, Object?>? _optionalMap(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value == null) {
    return null;
  }
  if (value is! Map) {
    throw FormatException('$key must be an object.');
  }
  return Map<String, Object?>.from(value);
}

DateTime? _optionalDateTime(Map<String, Object?> json, String key) {
  final value = _optionalString(json, key);
  return value == null ? null : DateTime.parse(value);
}
