import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/app_czar/domain/app_czar_models.dart';
import 'package:remember_this_text/essentials/app_czar_operating_session/application/app_czar_operating_currentness_classifier.dart';
import 'package:remember_this_text/essentials/app_czar_operating_session/domain/app_czar_operating_currentness_models.dart';

void main() {
  test('currentness disposition taxonomy is exact', () {
    expect(
      AppCzarOperatingCurrentnessDisposition.values,
      <AppCzarOperatingCurrentnessDisposition>[
        AppCzarOperatingCurrentnessDisposition.noChange,
        AppCzarOperatingCurrentnessDisposition.sourceAhead,
        AppCzarOperatingCurrentnessDisposition.sourceUnreadable,
        AppCzarOperatingCurrentnessDisposition.sourceUnknown,
        AppCzarOperatingCurrentnessDisposition.sourceUnstable,
        AppCzarOperatingCurrentnessDisposition.localContradiction,
        AppCzarOperatingCurrentnessDisposition.transient,
      ],
    );
  });

  group('classifyAppCzarOperatingCurrentness', () {
    test('incoherent or mutation-active evidence is transient', () {
      expect(
        _classify(afterMessageDataGeneration: 2),
        AppCzarOperatingCurrentnessDisposition.transient,
      );
      expect(
        _classify(mutationActive: true),
        AppCzarOperatingCurrentnessDisposition.transient,
      );
    });

    test('access-denied and unavailable sources are unreadable', () {
      for (final condition in <AppCzarSourceCondition>[
        AppCzarSourceCondition.accessDenied,
        AppCzarSourceCondition.unavailable,
      ]) {
        final decision = classifyAppCzarOperatingCurrentness(
          _observation(
            source: AppCzarSourceObservation(
              condition: condition,
              issue: 'literal source failure',
            ),
          ),
        );

        expect(
          decision.disposition,
          AppCzarOperatingCurrentnessDisposition.sourceUnreadable,
        );
        expect(decision.detail, 'literal source failure');
      }
    });

    test('unknown source remains distinct from unreadable', () {
      final decision = classifyAppCzarOperatingCurrentness(
        _observation(
          source: const AppCzarSourceObservation.unknown(
            'source evidence was inconclusive',
          ),
        ),
      );

      expect(
        decision.disposition,
        AppCzarOperatingCurrentnessDisposition.sourceUnknown,
      );
      expect(decision.detail, 'source evidence was inconclusive');
    });

    test('false or absent sample stability is source-unstable', () {
      for (final sampleStable in <bool?>[false, null]) {
        expect(
          _classify(source: _source(sampleStable: sampleStable)),
          AppCzarOperatingCurrentnessDisposition.sourceUnstable,
        );
      }
    });

    test('incomplete local evidence is a local contradiction', () {
      final cases = <AppCzarOperatingCurrentnessObservation>[
        _observation(
          importStore: _importStore(
            condition: AppCzarDatabaseCondition.unhealthy,
          ),
        ),
        _observation(
          graphStore: _graphStore(
            condition: AppCzarDatabaseCondition.unhealthy,
          ),
        ),
        _observation(graphStore: _graphStore(messageCount: 99)),
        _observation(graphStore: _graphStore(chatCount: 0)),
        _observation(graphStore: _graphStore(chatMessageEdgeCount: 0)),
        _observation(importStore: _importStore(liveMessageCount: null)),
        _observation(importStore: _importStore(liveMaxSourceRowId: null)),
        _observation(source: _source(messageCount: null)),
        _observation(source: _source(maxRowId: null)),
      ];

      for (final observation in cases) {
        expect(
          classifyAppCzarOperatingCurrentness(observation).disposition,
          AppCzarOperatingCurrentnessDisposition.localContradiction,
        );
      }
    });

    test('a source behind either local boundary is contradictory', () {
      expect(
        _classify(source: _source(messageCount: 99)),
        AppCzarOperatingCurrentnessDisposition.localContradiction,
      );
      expect(
        _classify(source: _source(maxRowId: 199)),
        AppCzarOperatingCurrentnessDisposition.localContradiction,
      );
      expect(
        _classify(source: _source(messageCount: 101, maxRowId: 199)),
        AppCzarOperatingCurrentnessDisposition.localContradiction,
      );
    });

    test('equal count and high-water is no-change', () {
      final decision = classifyAppCzarOperatingCurrentness(_observation());

      expect(
        decision.disposition,
        AppCzarOperatingCurrentnessDisposition.noChange,
      );
      expect(decision.detail, contains('100/200'));
    });

    test('a forward count or high-water delta is source-ahead', () {
      expect(
        _classify(source: _source(messageCount: 101)),
        AppCzarOperatingCurrentnessDisposition.sourceAhead,
      );
      expect(
        _classify(source: _source(maxRowId: 201)),
        AppCzarOperatingCurrentnessDisposition.sourceAhead,
      );
      expect(
        _classify(source: _source(messageCount: 101, maxRowId: 201)),
        AppCzarOperatingCurrentnessDisposition.sourceAhead,
      );
    });
  });
}

AppCzarOperatingCurrentnessDisposition _classify({
  AppCzarSourceObservation? source,
  bool mutationActive = false,
  int afterMessageDataGeneration = 1,
}) {
  return classifyAppCzarOperatingCurrentness(
    _observation(
      source: source,
      mutationActive: mutationActive,
      afterMessageDataGeneration: afterMessageDataGeneration,
    ),
  ).disposition;
}

AppCzarOperatingCurrentnessObservation _observation({
  AppCzarSourceObservation? source,
  AppCzarDatabaseObservation? importStore,
  AppCzarDatabaseObservation? graphStore,
  bool mutationActive = false,
  int afterMessageDataGeneration = 1,
}) {
  final revisionToken = Object();
  final before = _fence(
    revisionToken: revisionToken,
    mutationActive: mutationActive,
  );
  final after = _fence(
    revisionToken: revisionToken,
    mutationActive: mutationActive,
    messageDataGeneration: afterMessageDataGeneration,
  );
  return AppCzarOperatingCurrentnessObservation(
    before: before,
    after: after,
    source: source ?? _source(),
    importStore: importStore ?? _importStore(),
    graphStore: graphStore ?? _graphStore(),
  );
}

AppCzarOperatingReadFence _fence({
  required Object revisionToken,
  required bool mutationActive,
  int messageDataGeneration = 1,
}) {
  return AppCzarOperatingReadFence(
    messageDataGeneration: messageDataGeneration,
    archiveLocation: const AppCzarOperatingArchiveLocationEvidence(
      generation: 3,
      isReadable: true,
      isWritableMutationEligible: true,
      resolvedPath: '/test/archive',
    ),
    mutation: AppCzarOperatingMutationFence(
      isActive: mutationActive,
      revisionToken: revisionToken,
      lastReleasedAtMicroseconds: 10,
    ),
  );
}

AppCzarSourceObservation _source({
  int? messageCount = 100,
  int? maxRowId = 200,
  bool? sampleStable = true,
}) {
  return AppCzarSourceObservation(
    condition: AppCzarSourceCondition.readable,
    messageCount: messageCount,
    maxRowId: maxRowId,
    sampleStable: sampleStable,
  );
}

AppCzarDatabaseObservation _importStore({
  AppCzarDatabaseCondition condition = AppCzarDatabaseCondition.healthy,
  int? liveMessageCount = 100,
  int? liveMaxSourceRowId = 200,
}) {
  return AppCzarDatabaseObservation(
    condition: condition,
    schemaVersion: 10,
    messageCount: 100,
    liveMessageCount: liveMessageCount,
    liveMaxSourceRowId: liveMaxSourceRowId,
  );
}

AppCzarDatabaseObservation _graphStore({
  AppCzarDatabaseCondition condition = AppCzarDatabaseCondition.healthy,
  int? messageCount = 100,
  int? chatCount = 5,
  int? chatMessageEdgeCount = 100,
}) {
  return AppCzarDatabaseObservation(
    condition: condition,
    schemaVersion: 3,
    messageCount: messageCount,
    chatCount: chatCount,
    chatMessageEdgeCount: chatMessageEdgeCount,
  );
}
