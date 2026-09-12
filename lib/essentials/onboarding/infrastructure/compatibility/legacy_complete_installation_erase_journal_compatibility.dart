import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

import '../../../archive_environment/application/archive_marker_store.dart';
import '../../../archive_environment/domain/archive_access_authority.dart';
import '../../../archive_environment/domain/archive_environment.dart';
import '../../../archive_environment/domain/archive_instance_id.dart';
import '../../application/message_lens_installation_validation_service.dart';
import '../../domain/message_lens_installation_state.dart';
import '../../domain/startup_installation_validation.dart';

/// Result of recognizing and safely retiring an obsolete Complete Erase journal.
enum LegacyCompleteInstallationEraseJournalDisposition {
  noJournal,
  removedStalePreEraseJournal,
  removedStalePostInstallJournal,
}

/// Ordinary admission plus bounded diagnostics about legacy journal handling.
final class LegacyCompleteInstallationEraseJournalAdmissionResult {
  const LegacyCompleteInstallationEraseJournalAdmissionResult({
    required this.authority,
    required this.disposition,
    required this.diagnostics,
  });

  final ArchiveAccessAuthority authority;
  final LegacyCompleteInstallationEraseJournalDisposition disposition;
  final Map<String, String> diagnostics;
}

/// Fail-closed refusal raised when an obsolete journal is not provably stale.
final class LegacyCompleteInstallationEraseJournalException
    implements Exception {
  const LegacyCompleteInstallationEraseJournalException({
    required this.code,
    required this.message,
    required this.diagnostics,
  });

  final String code;
  final String message;
  final Map<String, String> diagnostics;

  @override
  String toString() {
    return 'Legacy Complete Erase journal blocked startup [$code]: $message';
  }
}

typedef OrdinaryArchiveAdmission = Future<ArchiveAccessAuthority> Function();

/// Temporary compatibility seam for journals written by obsolete tester builds.
///
/// Remove no earlier than MessageLens 0.4.0 and 2027-09-01, after confirming
/// that the supported tester-upgrade window no longer includes affected builds.
/// This type may remove only [obsoleteJournalFileName]. It cannot resume the
/// retired transaction or mutate any archive store or identity.
final class LegacyCompleteInstallationEraseJournalCompatibility {
  const LegacyCompleteInstallationEraseJournalCompatibility({
    required this.fullValidator,
  });

  static const String obsoleteJournalFileName =
      '.messagelens-complete-installation-erase.json';
  static const String _archiveMarkerFileName = '.messagelens-archive.json';
  static const String _processLockFileName = 'MessageLens.instance.lock';
  static const String removalNotBeforeVersion = '0.4.0';
  static final DateTime removalNotBeforeUtc = DateTime.utc(2027, 9);

  final MessageLensInstallationFullValidator fullValidator;

  Future<LegacyCompleteInstallationEraseJournalAdmissionResult> admit({
    required String canonicalRootPath,
    required ArchiveEnvironment expectedEnvironment,
    required ArchiveMarkerStore markerStore,
    required OrdinaryArchiveAdmission ordinaryAdmission,
  }) async {
    final journalPath = path.join(canonicalRootPath, obsoleteJournalFileName);
    final journalType = FileSystemEntity.typeSync(
      journalPath,
      followLinks: false,
    );
    if (journalType == FileSystemEntityType.notFound) {
      final authority = await ordinaryAdmission();
      return LegacyCompleteInstallationEraseJournalAdmissionResult(
        authority: authority,
        disposition:
            LegacyCompleteInstallationEraseJournalDisposition.noJournal,
        diagnostics: const <String, String>{'journal': 'absent'},
      );
    }
    if (journalType != FileSystemEntityType.file) {
      throw _failure(
        code: 'journal_not_regular_file',
        message: 'The legacy transaction path is not a regular file.',
        diagnostics: <String, String>{'journalType': journalType.toString()},
      );
    }

    final journalFile = File(journalPath);
    final originalBytes = journalFile.readAsBytesSync();
    final transaction = _parseTransaction(originalBytes);
    final diagnostics = <String, String>{
      'journal': 'present',
      'journalEnvironment': transaction.environment.serializedName,
      'expectedEnvironment': expectedEnvironment.serializedName,
      'journalArchiveId': transaction.newArchiveInstanceId.value,
    };
    if (transaction.environment != expectedEnvironment) {
      throw _failure(
        code: 'environment_mismatch',
        message: 'The legacy transaction belongs to another environment.',
        diagnostics: diagnostics,
      );
    }

    final marker = await markerStore.read();
    if (marker == null) {
      throw _failure(
        code: 'marker_missing',
        message: 'The archive marker is missing.',
        diagnostics: diagnostics,
      );
    }
    diagnostics['markerArchiveId'] = marker.archiveInstanceId.value;

    final ArchiveAccessAuthority authority;
    try {
      authority = await ordinaryAdmission();
    } on Object catch (error) {
      diagnostics['ordinaryAdmission'] = 'failed';
      diagnostics['admissionErrorType'] = error.runtimeType.toString();
      throw _failure(
        code: 'ordinary_admission_failed',
        message: 'The current archive did not pass ordinary admission.',
        diagnostics: diagnostics,
      );
    }
    diagnostics['ordinaryAdmission'] = 'passed';

    final FullInstallationValidationResult validation;
    try {
      validation = await fullValidator.validateFully(
        archiveRootPath: canonicalRootPath,
        trigger: InstallationIntegrityValidationTrigger
            .destructiveJournalCompatibility,
      );
    } on Object catch (error) {
      diagnostics['evidenceRead'] = 'failed';
      diagnostics['evidenceErrorType'] = error.runtimeType.toString();
      throw _failure(
        code: 'installation_evidence_unavailable',
        message: 'The current archive evidence could not be inspected.',
        diagnostics: diagnostics,
      );
    }
    final evidence = validation.evidence;
    final state = validation.installationState;
    diagnostics['evidenceRead'] = 'passed';
    diagnostics['installationState'] = state.kind.name;
    diagnostics['fullIntegrityValidated'] = validation.fullIntegrityValidated
        .toString();

    final markerMatchesReplacement =
        marker.archiveInstanceId == transaction.newArchiveInstanceId;
    if (!markerMatchesReplacement) {
      if (!_isCoherentCurrentArchive(
        evidence: evidence,
        state: state,
        fullIntegrityValidated: validation.fullIntegrityValidated,
      )) {
        throw _failure(
          code: 'current_archive_not_coherent',
          message:
              'The current archive is not coherent enough for stale-journal cleanup.',
          diagnostics: diagnostics,
        );
      }
      _deleteUnchangedJournal(
        journalFile: journalFile,
        originalBytes: originalBytes,
        diagnostics: diagnostics,
      );
      return LegacyCompleteInstallationEraseJournalAdmissionResult(
        authority: authority,
        disposition: LegacyCompleteInstallationEraseJournalDisposition
            .removedStalePreEraseJournal,
        diagnostics: Map<String, String>.unmodifiable(diagnostics),
      );
    }

    if (state.kind == MessageLensInstallationStateKind.virgin) {
      if (!_hasOnlyVirginRootArtifacts(canonicalRootPath)) {
        throw _failure(
          code: 'replacement_identity_has_unexpected_artifacts',
          message:
              'The replacement identity contains artifacts outside the Virgin root contract.',
          diagnostics: diagnostics,
        );
      }
      _deleteUnchangedJournal(
        journalFile: journalFile,
        originalBytes: originalBytes,
        diagnostics: diagnostics,
      );
      return LegacyCompleteInstallationEraseJournalAdmissionResult(
        authority: authority,
        disposition: LegacyCompleteInstallationEraseJournalDisposition
            .removedStalePostInstallJournal,
        diagnostics: Map<String, String>.unmodifiable(diagnostics),
      );
    }

    throw _failure(
      code: 'replacement_identity_not_virgin',
      message: 'The replacement identity is not proven to be a Virgin archive.',
      diagnostics: diagnostics,
    );
  }

  bool _hasOnlyVirginRootArtifacts(String canonicalRootPath) {
    const allowedNames = <String>{
      obsoleteJournalFileName,
      _archiveMarkerFileName,
      _processLockFileName,
    };
    final rootType = FileSystemEntity.typeSync(
      canonicalRootPath,
      followLinks: false,
    );
    if (rootType != FileSystemEntityType.directory) {
      return false;
    }

    for (final entity in Directory(
      canonicalRootPath,
    ).listSync(followLinks: false)) {
      final name = path.basename(entity.path);
      final type = FileSystemEntity.typeSync(entity.path, followLinks: false);
      if (!allowedNames.contains(name) || type != FileSystemEntityType.file) {
        return false;
      }
    }
    return true;
  }

  bool _isCoherentCurrentArchive({
    required MessageLensInstallationEvidence evidence,
    required MessageLensInstallationState state,
    required bool fullIntegrityValidated,
  }) {
    final existingDatabasesPassedBoundedInspection =
        <InstallationDatabaseEvidence>[
          evidence.sourceScopedImport,
          evidence.conversationGraph,
          evidence.overlay,
          evidence.presence,
        ].every(
          (database) => !database.exists || database.passedBoundedInspection,
        );
    if (!fullIntegrityValidated || !existingDatabasesPassedBoundedInspection) {
      return false;
    }

    return switch (state.kind) {
      MessageLensInstallationStateKind.virgin ||
      MessageLensInstallationStateKind.resumable ||
      MessageLensInstallationStateKind.completed => true,
      MessageLensInstallationStateKind.abandoned ||
      MessageLensInstallationStateKind.remediationRequired => false,
    };
  }

  _LegacyCompleteInstallationEraseTransaction _parseTransaction(
    List<int> bytes,
  ) {
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('Journal must contain a JSON object.');
      }
      const expectedKeys = <String>{
        'formatVersion',
        'environment',
        'newArchiveInstanceId',
        'createdAtUtc',
      };
      if (decoded.keys.toSet().difference(expectedKeys).isNotEmpty ||
          expectedKeys.difference(decoded.keys.toSet()).isNotEmpty) {
        throw const FormatException('Journal fields are not recognized.');
      }
      final formatVersion = decoded['formatVersion'];
      final environment = decoded['environment'];
      final newArchiveInstanceId = decoded['newArchiveInstanceId'];
      final createdAtUtc = decoded['createdAtUtc'];
      if (formatVersion != 1 ||
          environment is! String ||
          newArchiveInstanceId is! String ||
          createdAtUtc is! String) {
        throw const FormatException('Journal field types are invalid.');
      }
      final createdAt = DateTime.tryParse(createdAtUtc);
      if (createdAt == null || !createdAt.isUtc) {
        throw const FormatException('Journal timestamp must be UTC.');
      }
      return _LegacyCompleteInstallationEraseTransaction(
        environment: ArchiveEnvironment.parse(environment),
        newArchiveInstanceId: ArchiveInstanceId(newArchiveInstanceId),
      );
    } on LegacyCompleteInstallationEraseJournalException {
      rethrow;
    } on Object catch (error) {
      throw _failure(
        code: 'malformed_journal',
        message: 'The legacy transaction journal is malformed.',
        diagnostics: <String, String>{
          'journal': 'present',
          'parseErrorType': error.runtimeType.toString(),
        },
      );
    }
  }

  void _deleteUnchangedJournal({
    required File journalFile,
    required List<int> originalBytes,
    required Map<String, String> diagnostics,
  }) {
    final currentType = FileSystemEntity.typeSync(
      journalFile.path,
      followLinks: false,
    );
    if (currentType != FileSystemEntityType.file) {
      throw _failure(
        code: 'journal_changed_before_cleanup',
        message: 'The legacy transaction changed before safe cleanup.',
        diagnostics: diagnostics,
      );
    }
    final currentBytes = journalFile.readAsBytesSync();
    if (!_sameBytes(originalBytes, currentBytes)) {
      throw _failure(
        code: 'journal_changed_before_cleanup',
        message: 'The legacy transaction changed before safe cleanup.',
        diagnostics: diagnostics,
      );
    }
    journalFile.deleteSync();
  }

  bool _sameBytes(List<int> first, List<int> second) {
    if (first.length != second.length) {
      return false;
    }
    for (var index = 0; index < first.length; index += 1) {
      if (first[index] != second[index]) {
        return false;
      }
    }
    return true;
  }

  LegacyCompleteInstallationEraseJournalException _failure({
    required String code,
    required String message,
    required Map<String, String> diagnostics,
  }) {
    return LegacyCompleteInstallationEraseJournalException(
      code: code,
      message: message,
      diagnostics: Map<String, String>.unmodifiable(diagnostics),
    );
  }
}

final class _LegacyCompleteInstallationEraseTransaction {
  const _LegacyCompleteInstallationEraseTransaction({
    required this.environment,
    required this.newArchiveInstanceId,
  });

  final ArchiveEnvironment environment;
  final ArchiveInstanceId newArchiveInstanceId;
}
