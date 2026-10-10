import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/monitor/chat_db_source_probe_reader.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/sqlite_chat_db_source_probe_reader.dart';
import 'package:remember_this_text/essentials/messages_source/domain/current_messages_source_evidence.dart';
import 'package:remember_this_text/essentials/messages_source/infrastructure/probe_current_messages_source_evidence_reader.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  group('ProbeCurrentMessagesSourceEvidenceReader', () {
    test('preserves readable source path and bounded identity', () {
      final fixture = _createSourceFixture();
      addTearDown(fixture.dispose);
      final reader = _reader(fixture.databasePath);

      final evidence = reader.read();

      expect(evidence.condition, CurrentMessagesSourceReadCondition.readable);
      expect(evidence.sourcePath, fixture.databasePath);
      expect(evidence.maxRowId, 2);
      expect(evidence.failureKind, isNull);
    });

    test('preserves literal known access denial', () {
      final reader = ProbeCurrentMessagesSourceEvidenceReader(
        sourceReadProbe: (sourcePath) {
          throw ChatDbSourceProbeException(
            kind: ChatDbSourceProbeFailureKind.accessDenied,
            databasePath: sourcePath,
            operation: 'source file read verification',
          );
        },
        sourcePathResolver: () => '/protected/Library/Messages/chat.db',
      );

      final evidence = reader.read();

      expect(
        evidence.condition,
        CurrentMessagesSourceReadCondition.accessDenied,
      );
      expect(evidence.failureKind, ChatDbSourceProbeFailureKind.accessDenied);
    });

    test('preserves literal known unavailable failure kinds', () {
      for (final kind in <ChatDbSourceProbeFailureKind>[
        ChatDbSourceProbeFailureKind.databaseMissing,
        ChatDbSourceProbeFailureKind.filesystemReadFailed,
        ChatDbSourceProbeFailureKind.sqliteOpenFailed,
        ChatDbSourceProbeFailureKind.expectedSchemaUnavailable,
        ChatDbSourceProbeFailureKind.queryFailed,
      ]) {
        final reader = ProbeCurrentMessagesSourceEvidenceReader(
          sourceReadProbe: (sourcePath) {
            throw ChatDbSourceProbeException(
              kind: kind,
              databasePath: sourcePath,
              operation: 'test failure',
            );
          },
          sourcePathResolver: () => '/test/Library/Messages/chat.db',
        );

        final evidence = reader.read();

        expect(
          evidence.condition,
          CurrentMessagesSourceReadCondition.unavailable,
          reason: kind.name,
        );
        expect(evidence.failureKind, kind, reason: kind.name);
      }
    });

    test('keeps an unexpected observation genuinely unknown', () {
      final reader = ProbeCurrentMessagesSourceEvidenceReader(
        sourceReadProbe: (sourcePath) => throw StateError('unclassified'),
        sourcePathResolver: () => '/test/Library/Messages/chat.db',
      );

      final evidence = reader.read();

      expect(evidence.condition, CurrentMessagesSourceReadCondition.unknown);
      expect(evidence.failureKind, isNull);
      expect(evidence.error, isA<StateError>());
    });

    test('missing source remains unavailable and is never created', () {
      final directory = Directory.systemTemp.createTempSync(
        'current-messages-source-missing-',
      );
      addTearDown(() => directory.deleteSync(recursive: true));
      final sourcePath = '${directory.path}/chat.db';
      final reader = _reader(sourcePath);

      final evidence = reader.read();

      expect(
        evidence.condition,
        CurrentMessagesSourceReadCondition.unavailable,
      );
      expect(
        evidence.failureKind,
        ChatDbSourceProbeFailureKind.databaseMissing,
      );
      expect(File(sourcePath).existsSync(), isFalse);
    });

    test('uses the configured symlink path with trusted reader semantics', () {
      final fixture = _createSourceFixture();
      addTearDown(fixture.dispose);
      final linkPath = '${fixture.directory.path}/linked-chat.db';
      Link(linkPath).createSync(fixture.databasePath);
      final reader = _reader(linkPath);

      final evidence = reader.read();

      expect(evidence.condition, CurrentMessagesSourceReadCondition.readable);
      expect(evidence.sourcePath, linkPath);
      expect(evidence.maxRowId, 2);
    });

    test('re-resolves path for every observation without a stale cache', () {
      final first = _createSourceFixture(rowCount: 1);
      final second = _createSourceFixture(rowCount: 3);
      addTearDown(first.dispose);
      addTearDown(second.dispose);
      var sourcePath = first.databasePath;
      final reader = ProbeCurrentMessagesSourceEvidenceReader(
        sourceReadProbe: const SqliteChatDbSourceProbeReader().readMaxRowId,
        sourcePathResolver: () => sourcePath,
      );

      final firstEvidence = reader.read();
      sourcePath = second.databasePath;
      final secondEvidence = reader.read();

      expect(firstEvidence.sourcePath, first.databasePath);
      expect(firstEvidence.maxRowId, 1);
      expect(secondEvidence.sourcePath, second.databasePath);
      expect(secondEvidence.maxRowId, 3);
    });
  });
}

ProbeCurrentMessagesSourceEvidenceReader _reader(String sourcePath) {
  return ProbeCurrentMessagesSourceEvidenceReader(
    sourceReadProbe: const SqliteChatDbSourceProbeReader().readMaxRowId,
    sourcePathResolver: () => sourcePath,
  );
}

_SourceFixture _createSourceFixture({int rowCount = 2}) {
  final directory = Directory.systemTemp.createTempSync(
    'current-messages-source-',
  );
  final databasePath = '${directory.path}/chat.db';
  final database = sqlite3.open(databasePath);
  try {
    database.execute('CREATE TABLE message (guid TEXT);');
    for (var index = 0; index < rowCount; index++) {
      database.execute('INSERT INTO message (guid) VALUES (?);', <Object?>[
        'message-$index',
      ]);
    }
  } finally {
    database.dispose();
  }
  return _SourceFixture(directory: directory, databasePath: databasePath);
}

final class _SourceFixture {
  const _SourceFixture({required this.directory, required this.databasePath});

  final Directory directory;
  final String databasePath;

  void dispose() {
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }
  }
}
