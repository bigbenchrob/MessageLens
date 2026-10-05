import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _repairExecutorPath =
    'lib/features/attachments/application/'
    'app_czar_attachment_archive_repair_executor.dart';
const _repairExecutorContractPath =
    'lib/essentials/app_czar_attachment_archive_repair/application/'
    'app_czar_attachment_archive_repair_executor_provider.dart';
const _repairControllerPath =
    'lib/essentials/app_czar_attachment_archive_repair/application/'
    'app_czar_attachment_archive_repair_controller.dart';
const _repairModelsPath =
    'lib/essentials/app_czar_attachment_archive_repair/domain/'
    'app_czar_attachment_archive_repair_models.dart';
const _repairScreenPath =
    'lib/essentials/app_czar_attachment_archive_repair/presentation/'
    'app_czar_attachment_archive_repair_screen.dart';
const _repairFactoryProviderPath =
    'lib/features/attachments/application/'
    'app_czar_attachment_archive_repair_executor_factory_provider.dart';
const _repairWriterPath =
    'lib/features/attachments/application/'
    'admitted_attachment_archive_repair_writer.dart';
const _requiredReaderPath =
    'lib/features/attachments/infrastructure/repositories/'
    'sqlite_required_attachment_evidence_reader.dart';
const _startupCoverageProbePath =
    'lib/features/attachments/infrastructure/repositories/'
    'read_only_app_czar_attachment_coverage_probe.dart';
const _repairabilityReaderPath =
    'lib/features/attachments/application/'
    'attachment_repairability_evidence_reader.dart';
const _archiveFileStoreContractPath =
    'lib/features/attachments/application/attachment_archive_file_store.dart';
const _archiveFileStorePath =
    'lib/features/attachments/infrastructure/repositories/'
    'filesystem_attachment_archive_file_store.dart';
const _sourceReaderPath =
    'lib/features/attachments/infrastructure/repositories/'
    'source_database_current_messages_attachment_source_reader.dart';

void main() {
  test('startup and repair share one required attachment definition', () {
    final reader = _read(_requiredReaderPath);
    final startupProbe = _read(_startupCoverageProbePath);
    final repairabilityReader = _read(_repairabilityReaderPath);
    final repairExecutor = _read(_repairExecutorPath);
    final allOtherRepairSources = <String>[
      startupProbe,
      repairabilityReader,
      repairExecutor,
      ..._repairPackageFiles()
          .where((file) => file.path != _requiredReaderPath)
          .map((file) => file.readAsStringSync()),
    ].join('\n');

    expect(reader, contains('implements RequiredAttachmentEvidenceReader'));
    expect(reader, contains('RequiredAttachmentEvidencePage readPage'));
    expect(reader, contains('RequiredAttachmentEvidenceSummary readSummary'));
    expect(reader, contains('JOIN message_to_attachment'));
    expect(reader, contains('NULLIF(TRIM(m.guid)'));
    expect(reader, contains('NULLIF(TRIM(a.filename)'));
    expect(reader, contains('NULLIF(TRIM(a.mime_type)'));
    expect(reader, contains("SourceScopedRowSql.sourceId('m.ss_id')"));
    expect(reader, contains("SourceScopedRowSql.sourceId('a.ss_id')"));

    expect(startupProbe, contains('RequiredAttachmentEvidenceReader'));
    expect(startupProbe, contains('AttachmentRepairabilityEvidenceReader'));
    expect(startupProbe, contains('_repairabilityEvidenceReader.readCurrent'));
    expect(
      repairabilityReader,
      contains('RequiredAttachmentEvidenceReader _requiredEvidenceReader'),
    );
    expect(
      repairabilityReader,
      contains('_requiredEvidenceReader.readSummary'),
    );
    expect(repairabilityReader, contains('_requiredEvidenceReader.readPage'));
    expect(repairExecutor, contains('AttachmentRepairabilityEvidenceReader'));
    expect(
      repairExecutor,
      contains('_repairabilityEvidenceReader.readCurrent'),
    );
    expect(repairExecutor, isNot(contains('.readPage(')));

    const requiredSqlFragments = <String>[
      'JOIN message_to_attachment',
      'NULLIF(TRIM(m.guid)',
      'NULLIF(TRIM(a.filename)',
      'NULLIF(TRIM(a.mime_type)',
    ];
    for (final fragment in requiredSqlFragments) {
      expect(
        allOtherRepairSources,
        isNot(contains(fragment)),
        reason:
            'The required-universe SQL fragment "$fragment" must remain '
            'owned by $_requiredReaderPath.',
      );
    }
  });

  test('required evidence pagination is bounded deterministic keyset work', () {
    final contract = _read(
      'lib/features/attachments/application/'
      'required_attachment_evidence_reader.dart',
    );
    final reader = _read(_requiredReaderPath);

    expect(contract, contains('int limit = 75'));
    expect(reader, contains('limit < 1 || limit > 100'));
    expect(reader, contains('limit: limit + 1'));
    expect(reader, contains('ORDER BY m.guid, live_attachment_rowid'));
    expect(reader, contains('m.guid > ?'));
    expect(reader, contains('live_attachment_rowid'));
    expect(reader, contains('pagination did not advance'));
    expect(reader, isNot(contains('.toList()..sort')));
  });

  test('source availability shares the canonical installer extension rule', () {
    final contract = _read(_archiveFileStoreContractPath);
    final fileStore = _read(_archiveFileStorePath);
    final sourceReader = _read(_sourceReaderPath);

    expect(
      contract,
      contains('String normalizeAttachmentArchiveSourceExtension('),
    );
    expect(contract, contains(r"RegExp(r'^\.[a-z0-9]{1,16}$')"));
    expect(
      RegExp(
        r'normalizeAttachmentArchiveSourceExtension\s*\(',
      ).allMatches(fileStore),
      hasLength(2),
    );
    expect(
      sourceReader,
      contains(
        'normalizeAttachmentArchiveSourceExtension(path.extension(sourcePath))',
      ),
    );
  });

  test('repair owns one exact attachment-reconciliation Ball edge', () {
    final factoryProvider = _read(_repairFactoryProviderPath);
    final allRepairSources = _repairProductionFiles()
        .map((file) => file.readAsStringSync())
        .join('\n');

    expect(
      RegExp(
        r'\.read\(archiveMutationCoordinatorProvider\.notifier\)',
      ).allMatches(factoryProvider),
      hasLength(1),
    );
    expect(
      RegExp(
        r'\.runWithCapability(?:<[^>]+>)?\s*\(',
      ).allMatches(factoryProvider),
      hasLength(1),
    );
    expect(
      RegExp(
        r'static const _operation\s*=\s*'
        r'ArchiveMutationOperation\.attachmentReconciliation',
      ).allMatches(factoryProvider),
      hasLength(1),
    );
    expect(
      RegExp(r'operation:\s*_operation').allMatches(factoryProvider),
      hasLength(2),
    );
    expect(
      RegExp(
        r'\.runWithCapability(?:<[^>]+>)?\s*\(',
      ).allMatches(allRepairSources),
      hasLength(1),
      reason: 'Attachment repair must not acquire a nested Ball.',
    );
  });

  test('one confirmation identifies one exact memory-only bounded plan', () {
    final models = _read(_repairModelsPath);
    final executor = _read(_repairExecutorPath);
    final repairabilityReader = _read(_repairabilityReaderPath);
    final contract = _read(_repairExecutorContractPath);
    final controller = _read(_repairControllerPath);
    final authorization = _typeBlock(
      models,
      'final class AppCzarAttachmentArchiveRepairBatchAuthorization',
    );

    expect(
      models,
      contains(
        'const int appCzarAttachmentArchiveRepairMaximumAuthorizedItems = 75;',
      ),
    );
    expect(authorization, contains('final String planIdentity;'));
    expect(authorization, contains('final int itemCount;'));
    expect(authorization, contains('final int? totalKnownBytes;'));
    expect(
      authorization,
      contains(
        'itemCount <= appCzarAttachmentArchiveRepairMaximumAuthorizedItems',
      ),
    );
    for (final term in <String>[
      'ArchiveCompatibilityKey',
      'archiveScopeIdentity',
      'archiveGeneration',
      'resolvedArchivePath',
      'sourcePath',
      'messageGuid',
      'filename',
    ]) {
      expect(
        authorization,
        isNot(contains(term)),
        reason: 'The presentation authorization must not expose $term.',
      );
    }

    expect(executor, contains('final class _AttachmentArchiveRepairBatchPlan'));
    expect(
      executor,
      contains('_AttachmentArchiveRepairBatchPlan? _pendingPlan;'),
    );
    expect(
      executor,
      contains('List<AttachmentRepairabilityAvailableItem>.unmodifiable'),
    );
    expect(
      _read(_repairabilityReaderPath),
      contains('availableItems.length < maximumAvailableItems'),
    );
    expect(
      executor,
      contains('items[index].hasSameMaterialEvidenceAs(other.items[index])'),
    );
    expect(
      repairabilityReader,
      contains(
        'sourceEvidence.hasSameMaterialEvidenceAs(other.sourceEvidence)',
      ),
    );
    expect(
      executor,
      contains(
        'requiredEvidenceFingerprint != other.requiredEvidenceFingerprint',
      ),
    );
    expect(
      executor,
      contains('!identical(authorizedPlan.authorization, authorization)'),
    );

    expect(contract, contains('preserveAuthorizedBatch({'));
    expect(
      contract,
      contains(
        'required AppCzarAttachmentArchiveRepairBatchAuthorization '
        'authorization',
      ),
    );
    expect(
      controller,
      contains(
        'final currentAuthorization = '
        '_current.snapshot?.nextBatchAuthorization;',
      ),
    );
    expect(
      controller,
      contains('!identical(currentAuthorization, authorization)'),
    );
    expect(
      controller,
      contains('preservationTotalCount: authorization.itemCount'),
    );
    expect(controller, contains('executor.preserveAuthorizedBatch('));
    expect(controller, contains('repairability.availableFromMessagesCount'));
  });

  test('authorized execution cannot chain or refill a later evidence page', () {
    final executor = _read(_repairExecutorPath);
    final allRepairSources = _repairProductionFiles()
        .map((file) => file.readAsStringSync())
        .join('\n');
    final preserveMethod = _methodBlock(
      executor,
      'Future<AppCzarAttachmentArchiveRepairObservation> '
      '_preserveAuthorizedBatch(',
    );

    expect(
      RegExp(
        r'_mutationBatchExecutor\.preserveNoRecordBatch\s*\(',
      ).allMatches(preserveMethod),
      hasLength(1),
    );
    expect(preserveMethod, contains('sources: authorizedPlan.sources'));
    expect(preserveMethod, contains('_pendingPlan = null;'));
    expect(preserveMethod, contains('return _inspect(binding);'));
    expect(preserveMethod, isNot(contains('while (')));
    expect(preserveMethod, isNot(contains('.readPage(')));
    expect(preserveMethod, isNot(contains('cursor')));
    expect(preserveMethod, isNot(contains('pageSize')));

    for (final retiredTerm in <String>[
      'preserveAvailable',
      'authorizedTotal',
      'processed < authorizedTotal',
    ]) {
      expect(
        allRepairSources,
        isNot(contains(retiredTerm)),
        reason:
            'One confirmation must not retain the retired $retiredTerm '
            'multi-page authorization path.',
      );
    }
  });

  test('capability and writable lease remain callback-local proof', () {
    final writer = _read(_repairWriterPath);
    final factoryProvider = _read(_repairFactoryProviderPath);

    expect(writer, contains('required ArchiveMutationCapability capability'));
    expect(
      writer,
      contains('required AttachmentArchiveWritableRootLease writableRootLease'),
    );
    expect(
      writer,
      isNot(matches(RegExp(r'final\s+ArchiveMutationCapability\s+_'))),
    );
    expect(
      writer,
      isNot(matches(RegExp(r'final\s+AttachmentArchiveWritableRootLease\s+_'))),
    );
    expect(
      factoryProvider,
      isNot(matches(RegExp(r'final\s+ArchiveMutationCapability\s+_'))),
    );
    expect(
      factoryProvider,
      isNot(matches(RegExp(r'final\s+AttachmentArchiveWritableRootLease\s+_'))),
    );
    expect(writer, isNot(contains('archiveMutationCoordinatorProvider')));
    expect(
      factoryProvider,
      contains('attachmentArchiveWritableRootAdmissionProvider'),
    );
  });

  test('payload durability structurally precedes archive record commit', () {
    final writer = _read(_repairWriterPath);
    final payloadInstall = writer.indexOf(
      'final archiveWrite = await _installPayload(',
    );
    final sourceReproof = writer.indexOf(
      'final postInstallSource = await _sourceReader.observeCurrent(',
    );
    final mutationRevalidation = writer.indexOf(
      'AttachmentArchiveMutationBoundary.beforeMetadataCommit',
    );
    final recordCommit = writer.indexOf('_writeStore.writeArchiveRecord(');

    expect(payloadInstall, greaterThanOrEqualTo(0));
    expect(writer, contains('_fileStore.writeArchiveEntry('));
    expect(sourceReproof, greaterThan(payloadInstall));
    expect(mutationRevalidation, greaterThan(sourceReproof));
    expect(recordCommit, greaterThan(mutationRevalidation));
    expect(writer, contains('_verifyCommittedObject('));
  });

  test('repair coordinators own no filesystem or durable resume authority', () {
    final sources = <String>[
      ..._repairCoordinatorFiles().map((file) => file.readAsStringSync()),
      _read(_repairExecutorPath),
      _read(_repairFactoryProviderPath),
    ].join('\n');
    const forbidden = <String>[
      "import 'dart:io';",
      'File(',
      'Directory(',
      'RandomAccessFile',
      'SharedPreferences',
      'operation_snapshot',
      'OperationSnapshot',
      'repairCursor',
      'resumeCursor',
      'persistedPlan',
      'serializedPlan',
      'repairPlanHistory',
      'repairAuthorizationHistory',
      'lastRepairSucceeded',
      'lastRepairFailed',
      'repairSucceeded',
      'repairFailed',
      'appCzarDataUpdateControllerProvider',
      'appCzarSourceAccessControllerProvider',
      'appCzarOperatingSessionControllerProvider',
    ];
    for (final term in forbidden) {
      expect(
        sources,
        isNot(contains(term)),
        reason: 'Repair orchestration must not contain $term',
      );
    }
  });

  test(
    'batch consent is consumed inside the existing stop and drain model',
    () {
      final executor = _read(_repairExecutorPath);
      final controller = _read(_repairControllerPath);
      final executorStop = _methodBlock(
        executor,
        'Future<void> stopAndDrain()',
      );
      final controllerStop = _methodBlock(
        controller,
        'Future<void> stopAndDrain()',
      );

      expect(executorStop, contains('_stopRequested = true;'));
      expect(executorStop, contains('_pendingPlan = null;'));
      expect(executorStop, contains('await activeDrain;'));
      expect(
        executor,
        contains(
          '// Claim this displayed plan before any await so double invocation '
          'cannot',
        ),
      );
      expect(controllerStop, contains('_stopRequested = true;'));
      expect(controllerStop, contains('await executor.stopAndDrain();'));
      expect(controllerStop, contains('await activeRun;'));
    },
  );

  test('repair screen exposes aggregate facts only', () {
    final screen = _read(_repairScreenPath);
    const forbidden = <String>[
      'resolvedArchivePath',
      'archiveScopeIdentity',
      'sourcePath',
      'messageGuid',
      'filename',
      'contactName',
      'messageText',
    ];
    for (final term in forbidden) {
      expect(
        screen,
        isNot(contains(term)),
        reason: 'Repair presentation must not expose $term',
      );
    }
    expect(screen, contains('Required payloads'));
    expect(screen, contains('Covered'));
    expect(screen, contains('Need attention'));
    expect(screen, contains('Available from Messages'));
    expect(screen, contains('Source currently absent'));
    expect(screen, contains('Source evidence unavailable'));
    expect(screen, contains('Record-backed recovery needed'));
    expect(screen, contains('Next repair batch'));
    expect(screen, contains('Total source size:'));
    expect(screen, contains('Total size could not be established'));
    expect(screen, contains("'Preserve these '"));
    expect(screen, contains(r'${authorization.itemCount}'));
    expect(screen, contains('await onStart(authorization)'));
    expect(screen, isNot(contains('Preserve Available Attachments')));
  });

  test('production startup remains on the legacy startup branch', () {
    final mainSource = _read('lib/main.dart');

    expect(
      mainSource,
      contains(
        'return exactDevelopmentGateEnabled\n'
        '      ? MessageLensStartupPresentation.appCzarHarness\n'
        '      : MessageLensStartupPresentation.legacyStartup;',
      ),
    );
    expect(
      mainSource,
      contains('MessageLensStartupPresentation.legacyStartup => StartupApp('),
    );
    expect(
      RegExp(r'AppCzarStartupHarness\s*\(').allMatches(mainSource),
      hasLength(1),
    );
  });
}

String _typeBlock(String source, String declaration) {
  final start = source.indexOf(declaration);
  expect(start, greaterThanOrEqualTo(0), reason: '$declaration must exist');
  final openingBrace = source.indexOf('{', start);
  return _balancedBlock(source, declaration, start, openingBrace);
}

String _methodBlock(String source, String declaration) {
  final start = source.indexOf(declaration);
  expect(start, greaterThanOrEqualTo(0), reason: '$declaration must exist');
  final asyncBody = source.indexOf(') async {', start);
  final openingBrace = asyncBody < 0 ? -1 : asyncBody + ') async '.length;
  return _balancedBlock(source, declaration, start, openingBrace);
}

String _balancedBlock(
  String source,
  String declaration,
  int start,
  int openingBrace,
) {
  expect(
    openingBrace,
    greaterThanOrEqualTo(0),
    reason: '$declaration must have a body',
  );
  var depth = 0;
  for (var index = openingBrace; index < source.length; index++) {
    switch (source[index]) {
      case '{':
        depth += 1;
      case '}':
        depth -= 1;
        if (depth == 0) {
          return source.substring(start, index + 1);
        }
    }
  }
  fail('$declaration must have a balanced body');
}

String _read(String path) {
  final file = File(path);
  expect(file.existsSync(), isTrue, reason: '$path must exist');
  return file.readAsStringSync();
}

Iterable<File> _repairCoordinatorFiles() {
  return Directory('lib/essentials/app_czar_attachment_archive_repair')
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .where((file) => !file.path.endsWith('.g.dart'));
}

Iterable<File> _repairProductionFiles() sync* {
  yield* _repairCoordinatorFiles();
  for (final path in <String>[
    _repairExecutorPath,
    _repairabilityReaderPath,
    _repairFactoryProviderPath,
    _repairWriterPath,
  ]) {
    final file = File(path);
    if (file.existsSync()) {
      yield file;
    }
  }
}

Iterable<File> _repairPackageFiles() sync* {
  yield* _repairCoordinatorFiles();
  for (final path in <String>[
    _repairExecutorPath,
    _repairabilityReaderPath,
    _repairFactoryProviderPath,
    _repairWriterPath,
    _startupCoverageProbePath,
  ]) {
    final file = File(path);
    if (file.existsSync()) {
      yield file;
    }
  }
}
