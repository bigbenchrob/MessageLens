import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_projector.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/message_projection_repository.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/chat_message_joins/chat_message_join_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_rich_text_enricher.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/ports/message_extractor_port.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/import_database_provider.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/source_database/sqflite_source_database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const int _fixtureInsertBatchSize = 1000;
const String _qualificationToken = 'synthetic-disposable-archive';

Future<void> main() async {
  try {
    final environment = Platform.environment;
    if (environment['ML_PACKAGED_QUALIFICATION_TOKEN'] != _qualificationToken) {
      throw StateError('Packaged qualification token is absent.');
    }
    final databasePath = _requiredEnvironment('ML_PACKAGED_DB_PATH');
    _requireDisposablePath(databasePath);
    final resultPath = _requiredEnvironment('ML_PACKAGED_RESULT_PATH');
    _requireDisposablePath(resultPath);
    final mode = _requiredEnvironment('ML_PACKAGED_MODE');
    final candidateCount = _requiredPositiveInt('ML_PACKAGED_CANDIDATE_COUNT');
    final baseBlobBytes = _requiredPositiveInt('ML_PACKAGED_BLOB_BYTES');

    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final databaseFile = File(databasePath);
    final database = await ImportDatabase.open(
      databaseDirectory: databaseFile.parent.path,
      databaseName: databaseFile.uri.pathSegments.last,
    );
    try {
      switch (mode) {
        case 'prepare':
          await _populateSyntheticCandidates(
            database,
            candidateCount: candidateCount,
            baseBlobBytes: baseBlobBytes,
          );
          await _writeResult(resultPath, <String, Object?>{
            'mode': mode,
            'candidateCount': candidateCount,
          });
        case 'enrich':
          await _runEnrichment(
            database,
            candidateCount: candidateCount,
            resultPath: resultPath,
          );
        case 'inspect':
          await _writeInspection(database, resultPath: resultPath);
        case 'prepareSource':
          await _populateSyntheticSource(
            _requiredEnvironment('ML_PACKAGED_SOURCE_DB_PATH'),
            messageCount: candidateCount,
          );
          await _writeResult(resultPath, <String, Object?>{
            'mode': mode,
            'messageCount': candidateCount,
          });
        case 'sourcePipeline':
          await _runSourcePipeline(
            database,
            messageCount: candidateCount,
            resultPath: resultPath,
          );
        case 'inspectSourcePipeline':
          await _writeSourcePipelineInspection(
            database,
            resultPath: resultPath,
          );
        default:
          throw StateError('Unknown packaged qualification mode: $mode');
      }
    } finally {
      await database.close();
    }
    exit(0);
  } catch (error, stackTrace) {
    stderr.writeln('PACKAGED_QUALIFICATION_FAILURE $error');
    stderr.writeln(stackTrace);
    exit(1);
  }
}

Future<void> _runSourcePipeline(
  ImportDatabase database, {
  required int messageCount,
  required String resultPath,
}) async {
  final environment = Platform.environment;
  final boundary = environment['ML_PACKAGED_PAUSE_BOUNDARY'];
  final markerPath = environment['ML_PACKAGED_MARKER_PATH'];
  if (markerPath != null) {
    _requireDisposablePath(markerPath);
  }
  final sourceDatabasePath = _requiredEnvironment('ML_PACKAGED_SOURCE_DB_PATH');
  _requireDisposablePath(sourceDatabasePath);
  final graphDatabasePath = _requiredEnvironment('ML_PACKAGED_GRAPH_DB_PATH');
  _requireDisposablePath(graphDatabasePath);

  final messages = await MessageImporter(
    chatDbPath: sourceDatabasePath,
    importLedger: database,
    sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
    onPageBoundary: (observation) {
      if (boundary == 'beforeFirstSourcePageCommit' &&
          observation.pageOrdinal == 1) {
        _markAndPause(markerPath, boundary!, observation.pageOrdinal);
      }
    },
    onPageMetric: (metric) {
      if (boundary == 'afterMultipleSourcePageCommits' &&
          metric.pageOrdinal == 2) {
        _markAndPause(markerPath, boundary!, metric.pageOrdinal);
      }
    },
  ).importNewMessages();

  if (boundary == 'beforeRelationshipImport') {
    _markAndPause(markerPath, boundary!, 0);
  }
  final relationships = await ChatMessageJoinImporter(
    chatDbPath: sourceDatabasePath,
    importLedger: database,
    sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
  ).importJoins();

  if (boundary == 'beforeGraphProjectionCommit') {
    _markAndPause(markerPath, boundary!, 0);
  }
  final graphDatabase = ConversationGraphDatabase(
    NativeDatabase(File(graphDatabasePath)),
  );
  try {
    await graphDatabase.customSelect('SELECT 1').get();
    final projection = await MessageProjector(
      repository: SqliteMessageProjectionRepository(
        importLedgerDatabase: database,
        graphDatabase: graphDatabase,
      ),
    ).projectMessages();
    await _writeResult(resultPath, <String, Object?>{
      'mode': 'sourcePipeline',
      'fixtureMessageCount': messageCount,
      'inputMessageCount': messages.insertedMessageCount,
      'insertedRelationshipCount': relationships.insertedJoinCount,
      'insertedGraphMessageCount': projection.insertedMessageCount,
    });
  } finally {
    await graphDatabase.close();
  }
}

Future<void> _writeSourcePipelineInspection(
  ImportDatabase database, {
  required String resultPath,
}) async {
  final graphDatabasePath = _requiredEnvironment('ML_PACKAGED_GRAPH_DB_PATH');
  _requireDisposablePath(graphDatabasePath);
  final importedMessages = await database.database.rawQuery(
    'SELECT COUNT(*) AS c FROM messages',
  );
  final importedRelationships = await database.database.rawQuery(
    'SELECT COUNT(*) AS c FROM chat_to_message',
  );
  var graphMessageCount = 0;
  if (File(graphDatabasePath).existsSync()) {
    final graphDatabase = ConversationGraphDatabase(
      NativeDatabase(File(graphDatabasePath)),
    );
    try {
      await graphDatabase.customSelect('SELECT 1').get();
      final graphRows = await graphDatabase.selectRows(
        'SELECT COUNT(*) AS c FROM messages',
      );
      graphMessageCount = graphRows.single['c'] as int? ?? 0;
    } finally {
      await graphDatabase.close();
    }
  }
  await _writeResult(resultPath, <String, Object?>{
    'mode': 'inspectSourcePipeline',
    'importedMessageCount': importedMessages.single['c'],
    'importedRelationshipCount': importedRelationships.single['c'],
    'graphMessageCount': graphMessageCount,
  });
}

Future<void> _populateSyntheticSource(
  String databasePath, {
  required int messageCount,
}) async {
  _requireDisposablePath(databasePath);
  final database = await openDatabase(databasePath);
  try {
    await database.execute('''
      CREATE TABLE message (
        ROWID INTEGER PRIMARY KEY,
        guid TEXT,
        handle_id INTEGER,
        is_from_me INTEGER NOT NULL,
        date INTEGER,
        date_read INTEGER,
        date_delivered INTEGER,
        text TEXT,
        attributedBody BLOB,
        associated_message_guid TEXT,
        item_type INTEGER,
        associated_message_type INTEGER,
        thread_originator_guid TEXT,
        error INTEGER,
        is_system_message INTEGER,
        message_summary_info BLOB,
        payload_data BLOB
      )
    ''');
    await database.execute('''
      CREATE TABLE chat (
        ROWID INTEGER PRIMARY KEY,
        guid TEXT NOT NULL
      )
    ''');
    await database.execute('''
      CREATE TABLE chat_message_join (
        ROWID INTEGER PRIMARY KEY,
        chat_id INTEGER,
        message_id INTEGER
      )
    ''');
    await database.insert('chat', <String, Object?>{
      'ROWID': 1,
      'guid': 'synthetic-chat',
    });
    for (
      var start = 0;
      start < messageCount;
      start += _fixtureInsertBatchSize
    ) {
      final end = start + _fixtureInsertBatchSize < messageCount
          ? start + _fixtureInsertBatchSize
          : messageCount;
      final batch = database.batch();
      for (var index = start; index < end; index += 1) {
        final sourceRowId = (index * 2) + 1;
        batch.insert('message', <String, Object?>{
          'ROWID': sourceRowId,
          'guid': 'synthetic-source-message-$sourceRowId',
          'handle_id': 0,
          'is_from_me': index.isEven ? 1 : 0,
          'text': 'synthetic',
        });
      }
      await batch.commit(noResult: true);
    }
    await database.insert('chat_message_join', <String, Object?>{
      'ROWID': 1,
      'chat_id': 1,
      'message_id': 1,
    });
  } finally {
    await database.close();
  }
}

Future<void> _runEnrichment(
  ImportDatabase database, {
  required int candidateCount,
  required String resultPath,
}) async {
  final environment = Platform.environment;
  final boundary = environment['ML_PACKAGED_PAUSE_BOUNDARY'];
  final pausePageOrdinal =
      int.tryParse(environment['ML_PACKAGED_PAUSE_PAGE_ORDINAL'] ?? '') ?? 2;
  final markerPath = environment['ML_PACKAGED_MARKER_PATH'];
  if (markerPath != null) {
    _requireDisposablePath(markerPath);
  }
  final metricsPath = environment['ML_PACKAGED_METRICS_PATH'];
  if (metricsPath != null) {
    _requireDisposablePath(metricsPath);
  }

  final stopwatch = Stopwatch()..start();
  final extractor = _SyntheticPackagedExtractor(
    onDecoderPageStarted: (pageOrdinal) {
      if (boundary == 'duringDecoder' && pageOrdinal == pausePageOrdinal) {
        _markAndPause(markerPath, boundary!, pageOrdinal);
      }
    },
  );
  final result = await MessageRichTextEnricher(
    chatDbPath: '/synthetic/disposable/chat.db',
    importLedger: database,
    extractor: extractor,
    onPageBoundary: (observation) {
      if (boundary == 'afterDecoderBeforePersistence' &&
          observation.pageOrdinal == pausePageOrdinal) {
        _markAndPause(markerPath, boundary!, observation.pageOrdinal);
      }
    },
    onPageMetric: (metric) {
      if (metricsPath != null) {
        File(metricsPath).writeAsStringSync(
          '${jsonEncode(metric.toLogContext())}\n',
          mode: FileMode.append,
          flush: true,
        );
      }
      if (boundary == 'afterRichTextPersistence' &&
          metric.pageOrdinal == pausePageOrdinal) {
        _markAndPause(markerPath, boundary!, metric.pageOrdinal);
      }
    },
  ).enrichMissingText();
  stopwatch.stop();

  await _writeResult(resultPath, <String, Object?>{
    'mode': 'enrich',
    'fixtureCandidateCount': candidateCount,
    'inputCandidateCount': result.candidateMessageCount,
    'enrichedMessageCount': result.enrichedMessageCount,
    'missingExtractionCount': result.missingExtractionCount,
    'decoderPageCount': extractor.callCount,
    'elapsedMilliseconds': stopwatch.elapsedMilliseconds,
  });
}

Future<void> _writeInspection(
  ImportDatabase database, {
  required String resultPath,
}) async {
  final window = await database.messageTextEnrichmentWindow();
  final rows = await database.database.rawQuery('''
    SELECT
      COUNT(*) AS total_count,
      SUM(CASE WHEN text IS NOT NULL THEN 1 ELSE 0 END) AS enriched_count
    FROM messages
  ''');
  final row = rows.single;
  await _writeResult(resultPath, <String, Object?>{
    'mode': 'inspect',
    'totalMessageCount': row['total_count'],
    'enrichedMessageCount': row['enriched_count'] ?? 0,
    'remainingCandidateCount': window.candidateCount,
  });
}

Future<void> _populateSyntheticCandidates(
  ImportDatabase database, {
  required int candidateCount,
  required int baseBlobBytes,
}) async {
  await database.database.insert('source_registry', <String, Object?>{
    'source_id': liveChatDbSourceId,
    'source_key': 'synthetic-live',
    'source_kind': 'synthetic_disposable',
    'created_at_utc': DateTime.now().toUtc().toIso8601String(),
  }, conflictAlgorithm: ConflictAlgorithm.ignore);
  const archiveSourceId = 3;
  await database.database.insert('source_registry', <String, Object?>{
    'source_id': archiveSourceId,
    'source_key': 'synthetic-archive',
    'source_kind': 'synthetic_disposable',
    'created_at_utc': DateTime.now().toUtc().toIso8601String(),
  }, conflictAlgorithm: ConflictAlgorithm.ignore);
  final liveBatchId = await database.insertImportBatch(
    sourceId: liveChatDbSourceId,
    startedAtUtc: DateTime.now().toUtc().toIso8601String(),
  );
  final archiveBatchId = await database.insertImportBatch(
    sourceId: archiveSourceId,
    startedAtUtc: DateTime.now().toUtc().toIso8601String(),
  );

  for (
    var start = 0;
    start < candidateCount;
    start += _fixtureInsertBatchSize
  ) {
    final end = start + _fixtureInsertBatchSize < candidateCount
        ? start + _fixtureInsertBatchSize
        : candidateCount;
    final batch = database.database.batch();
    for (var index = start; index < end; index += 1) {
      final useArchiveSource = index > 0 && index % 100 == 0;
      final sourceId = useArchiveSource ? archiveSourceId : liveChatDbSourceId;
      final sourceRowId = useArchiveSource
          ? ((index - 1) * 2) + 1
          : (index * 2) + 1;
      final size = switch (index) {
        _ when index % 5000 == 0 => baseBlobBytes * 32,
        _ when index % 101 == 0 => baseBlobBytes * 8,
        _ when index % 17 == 0 => baseBlobBytes * 2,
        _ => baseBlobBytes,
      };
      final blob = Uint8List(size)..fillRange(0, size, index % 251);
      batch.insert('messages', <String, Object?>{
        'ss_id': SourceScopedRowKey.pack(
          sourceId: sourceId,
          sourceRowId: sourceRowId,
        ),
        'source_id': sourceId,
        'source_rowid': sourceRowId,
        'guid': 'synthetic-$sourceId-$sourceRowId',
        'is_from_me': index.isEven ? 1 : 0,
        'text': null,
        'attributed_body_blob': blob,
        'has_attributed_body_source': 1,
        'batch_id': useArchiveSource ? archiveBatchId : liveBatchId,
      });
    }
    await batch.commit(noResult: true);
  }
}

void _markAndPause(String? markerPath, String boundary, int pageOrdinal) {
  if (markerPath == null) {
    throw StateError('Pause boundary requires a marker path.');
  }
  File(markerPath).writeAsStringSync(
    jsonEncode(<String, Object?>{
      'boundary': boundary,
      'pageOrdinal': pageOrdinal,
    }),
    flush: true,
  );
  sleep(const Duration(minutes: 5));
}

Future<void> _writeResult(
  String resultPath,
  Map<String, Object?> result,
) async {
  await File(resultPath).writeAsString('${jsonEncode(result)}\n', flush: true);
}

String _requiredEnvironment(String name) {
  final value = Platform.environment[name];
  if (value == null || value.isEmpty) {
    throw StateError('$name is required.');
  }
  return value;
}

int _requiredPositiveInt(String name) {
  final value = int.tryParse(_requiredEnvironment(name));
  if (value == null || value <= 0) {
    throw StateError('$name must be a positive integer.');
  }
  return value;
}

void _requireDisposablePath(String value) {
  final absolute = File(value).absolute.path;
  final systemTemp = Directory.systemTemp.absolute.path;
  final isSystemTemporary = absolute.startsWith('$systemTemp/');
  if (!isSystemTemporary &&
      !absolute.startsWith('/private/tmp/') &&
      !absolute.startsWith('/tmp/')) {
    throw StateError('Qualification path must stay under a temporary root.');
  }
}

final class _SyntheticPackagedExtractor implements MessageExtractorPort {
  _SyntheticPackagedExtractor({required this.onDecoderPageStarted});

  final void Function(int pageOrdinal) onDecoderPageStarted;
  int callCount = 0;

  @override
  Future<Map<int, String>> extractAllMessageTexts({
    int? limit,
    String? dbPath,
  }) async {
    throw StateError('Packaged qualification exercises blob extraction only.');
  }

  @override
  Future<Map<int, String>> extractMessageTextsFromBlobs(
    Map<int, Uint8List> attributedBodyBlobsByWorkId, {
    MessageExtractionProgressObserver? onProgress,
  }) async {
    callCount += 1;
    onDecoderPageStarted(callCount);
    final extracted = <int, String>{};
    var completed = 0;
    for (final workId in attributedBodyBlobsByWorkId.keys) {
      extracted[workId] = 'synthetic';
      completed += 1;
      onProgress?.call(
        completedWorkCount: completed,
        totalWorkCount: attributedBodyBlobsByWorkId.length,
        lastCompletedWorkId: workId,
      );
    }
    return extracted;
  }

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<bool> isBlobExtractionAvailable() async => true;
}
