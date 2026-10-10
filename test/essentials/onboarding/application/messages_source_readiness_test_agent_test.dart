import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/sqlite_chat_db_source_probe_reader.dart';
import 'package:remember_this_text/essentials/messages_source/infrastructure/probe_current_messages_source_evidence_reader.dart';
import 'package:remember_this_text/essentials/onboarding/application/full_disk_access.dart';
import 'package:remember_this_text/essentials/onboarding/application/messages_source_access_denied_test_agent.dart';
import 'package:remember_this_text/essentials/onboarding/application/messages_source_access_evaluation.dart';
import 'package:remember_this_text/essentials/onboarding/application/messages_source_readiness_test_agent.dart';
import 'package:remember_this_text/essentials/onboarding/infrastructure/system/macos_full_disk_access.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('delegates true and false to the truthful source capability', () async {
    final fullDiskAccess = _FakeFullDiskAccess(
      result: MessagesSourceAccessResult.readable,
    );
    final evaluation = MessagesSourceAccessEvaluation(
      fullDiskAccess: fullDiskAccess,
    );
    final agent = MessagesSourceReadinessTestAgent(evaluation: evaluation);

    expect(await agent.evaluate(), isTrue);
    fullDiskAccess.result = MessagesSourceAccessResult.unavailable;
    expect(await agent.evaluate(), isFalse);
    expect(fullDiskAccess.readInvocationCount, 2);
  });

  test('preserves specialist failures', () async {
    final agent = MessagesSourceReadinessTestAgent(
      evaluation: MessagesSourceAccessEvaluation(
        fullDiskAccess: _FakeFullDiskAccess(
          result: MessagesSourceAccessResult.readable,
          failRead: true,
        ),
      ),
    );

    await expectLater(agent.evaluate(), throwsA(isA<StateError>()));
  });

  test('truthful SQLite source success evaluates true', () async {
    final tempDirectory = Directory.systemTemp.createTempSync(
      'presence-readable-source-',
    );
    addTearDown(() {
      if (tempDirectory.existsSync()) {
        tempDirectory.deleteSync(recursive: true);
      }
    });
    final databasePath = '${tempDirectory.path}/chat.db';
    final database = sqlite3.open(databasePath);
    try {
      database.execute('CREATE TABLE message (guid TEXT);');
    } finally {
      database.dispose();
    }
    final agent = MessagesSourceReadinessTestAgent(
      evaluation: MessagesSourceAccessEvaluation(
        fullDiskAccess: MacosFullDiskAccess(
          sourceEvidenceReader: _sourceReader(databasePath),
        ),
      ),
    );

    expect(await agent.evaluate(), isTrue);
  });

  test('failed SQLite source query evaluates false', () async {
    final tempDirectory = Directory.systemTemp.createTempSync(
      'presence-unreadable-source-',
    );
    addTearDown(() {
      if (tempDirectory.existsSync()) {
        tempDirectory.deleteSync(recursive: true);
      }
    });
    final databasePath = '${tempDirectory.path}/chat.db';
    File(databasePath).writeAsStringSync('readable but not SQLite');
    final agent = MessagesSourceReadinessTestAgent(
      evaluation: MessagesSourceAccessEvaluation(
        fullDiskAccess: MacosFullDiskAccess(
          sourceEvidenceReader: _sourceReader(databasePath),
        ),
      ),
    );

    expect(await agent.evaluate(), isFalse);
  });

  test(
    'access-denied projection consumes the same fresh observation',
    () async {
      final fullDiskAccess = _FakeFullDiskAccess(
        result: MessagesSourceAccessResult.accessDenied,
      );
      final evaluation = MessagesSourceAccessEvaluation(
        fullDiskAccess: fullDiskAccess,
      );
      final readableAgent = MessagesSourceReadinessTestAgent(
        evaluation: evaluation,
      );
      final accessDeniedAgent = MessagesSourceAccessDeniedTestAgent(
        evaluation: evaluation,
      );

      expect(await readableAgent.evaluate(), isFalse);
      fullDiskAccess.result = MessagesSourceAccessResult.unavailable;
      expect(await accessDeniedAgent.evaluate(), isTrue);
      expect(fullDiskAccess.readInvocationCount, 1);
    },
  );

  test(
    'access-denied projection evaluates freshly after reconstruction',
    () async {
      final fullDiskAccess = _FakeFullDiskAccess(
        result: MessagesSourceAccessResult.unavailable,
      );
      final accessDeniedAgent = MessagesSourceAccessDeniedTestAgent(
        evaluation: MessagesSourceAccessEvaluation(
          fullDiskAccess: fullDiskAccess,
        ),
      );

      expect(await accessDeniedAgent.evaluate(), isFalse);
      expect(fullDiskAccess.readInvocationCount, 1);
    },
  );
}

ProbeCurrentMessagesSourceEvidenceReader _sourceReader(String sourcePath) {
  return ProbeCurrentMessagesSourceEvidenceReader(
    sourceReadProbe: const SqliteChatDbSourceProbeReader().readMaxRowId,
    sourcePathResolver: () => sourcePath,
  );
}

final class _FakeFullDiskAccess implements FullDiskAccess {
  _FakeFullDiskAccess({required this.result, this.failRead = false});

  MessagesSourceAccessResult result;
  final bool failRead;
  int readInvocationCount = 0;

  @override
  String get messagesDatabasePath => '/test/Library/Messages/chat.db';

  @override
  MessagesSourceAccessResult inspectMessagesSourceAccess() {
    readInvocationCount += 1;
    if (failRead) {
      throw StateError('Messages source probe failed.');
    }
    return result;
  }

  @override
  bool canReadMessagesDatabase() {
    return inspectMessagesSourceAccess() == MessagesSourceAccessResult.readable;
  }

  @override
  Future<void> openSettings() async {}
}
