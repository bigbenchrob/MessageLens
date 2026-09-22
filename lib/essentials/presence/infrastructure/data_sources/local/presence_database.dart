import 'package:drift/drift.dart';

import '../../../../db/app_database_schema_versions.dart';
import '../../../domain/entities/test_agent_id.dart';

part 'presence_database.g.dart';

const String tellStepType = 'tell';
const String fixedDestinationStepType = 'fixed_destination';
const String testStepType = 'test';
const String choiceStepType = 'choice';
const String fdaTestStepType = 'fda_test';
const String contactsSourceReadinessStepType = 'contacts_source_readiness';
const String openFdaSettingsStepType = 'open_fda_settings';
const String scheduleRunStartedTraceEvent = 'schedule_run_started';
const String tripStartedTraceEvent = 'trip_started';
const String stepStartedTraceEvent = 'step_started';
const String stepCompletedTraceEvent = 'step_completed';
const String tripCompletedTraceEvent = 'trip_completed';
const String routeDecisionTraceEvent = 'route_decision';
const String scheduleRunCompletedTraceEvent = 'schedule_run_completed';

@DataClassName('ScheduleDefinitionRow')
class ScheduleDefinitions extends Table {
  IntColumn get id => integer()();

  TextColumn get name => text().unique()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('TripDefinitionRow')
class TripDefinitions extends Table {
  IntColumn get id => integer()();

  TextColumn get name => text().unique()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('StepDefinitionRow')
class StepDefinitions extends Table {
  IntColumn get id => integer()();

  TextColumn get name => text().unique()();

  late final TextColumn stepType = text()
      .named('type')
      .check(
        stepType.isIn(const <String>[
          tellStepType,
          fixedDestinationStepType,
          testStepType,
          choiceStepType,
          fdaTestStepType,
          contactsSourceReadinessStepType,
          openFdaSettingsStepType,
        ]),
      )();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('ScheduleTripOccurrenceRow')
class ScheduleTripOccurrences extends Table {
  IntColumn get id => integer()();

  IntColumn get scheduleDefinitionId => integer()
      .named('schedule_definition_id')
      .references(ScheduleDefinitions, #id)();

  IntColumn get tripDefinitionId =>
      integer().named('trip_definition_id').references(TripDefinitions, #id)();

  late final IntColumn position = integer().check(
    position.isBiggerOrEqualValue(0),
  )();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => <Set<Column<Object>>>[
    <Column<Object>>{scheduleDefinitionId, position},
    <Column<Object>>{scheduleDefinitionId, tripDefinitionId},
    <Column<Object>>{scheduleDefinitionId, id},
  ];
}

@DataClassName('TripStepOccurrenceRow')
class TripStepOccurrences extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get tripDefinitionId =>
      integer().named('trip_definition_id').references(TripDefinitions, #id)();

  IntColumn get stepDefinitionId =>
      integer().named('step_definition_id').references(StepDefinitions, #id)();

  late final IntColumn position = integer().check(
    position.isBiggerOrEqualValue(0),
  )();

  @override
  List<Set<Column<Object>>> get uniqueKeys => <Set<Column<Object>>>[
    <Column<Object>>{tripDefinitionId, position},
  ];
}

@DataClassName('TellStepDefinitionRow')
class TellStepDefinitions extends Table {
  IntColumn get stepDefinitionId =>
      integer().named('step_definition_id').references(StepDefinitions, #id)();

  TextColumn get stepText => text().named('text')();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{stepDefinitionId};
}

@TableIndex(
  name: 'fixed_destination_step_destination_trip',
  columns: <Symbol>{#destinationTripDefinitionId},
)
@DataClassName('FixedDestinationStepDefinitionRow')
class FixedDestinationStepDefinitions extends Table {
  IntColumn get stepDefinitionId =>
      integer().named('step_definition_id').references(StepDefinitions, #id)();

  IntColumn get destinationTripDefinitionId => integer()
      .named('destination_trip_definition_id')
      .references(TripDefinitions, #id)();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{stepDefinitionId};
}

@TableIndex(
  name: 'fda_test_step_present_destination_trip',
  columns: <Symbol>{#presentDestinationTripDefinitionId},
)
@TableIndex(
  name: 'fda_test_step_absent_destination_trip',
  columns: <Symbol>{#absentDestinationTripDefinitionId},
)
@DataClassName('FdaTestStepDefinitionRow')
class FdaTestStepDefinitions extends Table {
  IntColumn get stepDefinitionId =>
      integer().named('step_definition_id').references(StepDefinitions, #id)();

  @ReferenceName('presentFdaTestStepDefinitions')
  IntColumn get presentDestinationTripDefinitionId => integer()
      .named('present_destination_trip_definition_id')
      .nullable()
      .references(TripDefinitions, #id)();

  @ReferenceName('absentFdaTestStepDefinitions')
  IntColumn get absentDestinationTripDefinitionId => integer()
      .named('absent_destination_trip_definition_id')
      .nullable()
      .references(TripDefinitions, #id)();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{stepDefinitionId};
}

@TableIndex(
  name: 'contacts_source_readiness_step_available_destination_trip',
  columns: <Symbol>{#availableDestinationTripDefinitionId},
)
@TableIndex(
  name: 'contacts_source_readiness_step_unavailable_destination_trip',
  columns: <Symbol>{#unavailableDestinationTripDefinitionId},
)
@DataClassName('ContactsSourceReadinessStepDefinitionRow')
class ContactsSourceReadinessStepDefinitions extends Table {
  IntColumn get stepDefinitionId =>
      integer().named('step_definition_id').references(StepDefinitions, #id)();

  @ReferenceName('availableContactsSourceReadinessStepDefinitions')
  IntColumn get availableDestinationTripDefinitionId => integer()
      .named('available_destination_trip_definition_id')
      .nullable()
      .references(TripDefinitions, #id)();

  @ReferenceName('unavailableContactsSourceReadinessStepDefinitions')
  IntColumn get unavailableDestinationTripDefinitionId => integer()
      .named('unavailable_destination_trip_definition_id')
      .nullable()
      .references(TripDefinitions, #id)();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{stepDefinitionId};
}

@DataClassName('OpenFdaSettingsStepDefinitionRow')
class OpenFdaSettingsStepDefinitions extends Table {
  IntColumn get stepDefinitionId =>
      integer().named('step_definition_id').references(StepDefinitions, #id)();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{stepDefinitionId};
}

@DataClassName('TestAgentDefinitionRow')
class TestAgentDefinitions extends Table {
  TextColumn get id => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@TableIndex(
  name: 'test_step_true_destination_trip',
  columns: <Symbol>{#trueDestinationTripDefinitionId},
)
@TableIndex(
  name: 'test_step_false_destination_trip',
  columns: <Symbol>{#falseDestinationTripDefinitionId},
)
@DataClassName('TestStepDefinitionRow')
class TestStepDefinitions extends Table {
  IntColumn get stepDefinitionId =>
      integer().named('step_definition_id').references(StepDefinitions, #id)();

  TextColumn get testAgentId =>
      text().named('test_agent_id').references(TestAgentDefinitions, #id)();

  @ReferenceName('trueTestStepDefinitions')
  IntColumn get trueDestinationTripDefinitionId => integer()
      .named('true_destination_trip_definition_id')
      .nullable()
      .references(TripDefinitions, #id)();

  @ReferenceName('falseTestStepDefinitions')
  IntColumn get falseDestinationTripDefinitionId => integer()
      .named('false_destination_trip_definition_id')
      .nullable()
      .references(TripDefinitions, #id)();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{stepDefinitionId};
}

@DataClassName('ChoiceStepDefinitionRow')
class ChoiceStepDefinitions extends Table {
  IntColumn get stepDefinitionId =>
      integer().named('step_definition_id').references(StepDefinitions, #id)();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{stepDefinitionId};
}

@TableIndex(
  name: 'choice_step_option_destination_trip',
  columns: <Symbol>{#destinationTripDefinitionId},
)
@DataClassName('ChoiceStepOptionRow')
class ChoiceStepOptions extends Table {
  IntColumn get stepDefinitionId => integer()
      .named('step_definition_id')
      .references(ChoiceStepDefinitions, #stepDefinitionId)();

  TextColumn get value => text()();

  late final IntColumn position = integer().check(
    position.isBiggerOrEqualValue(0),
  )();

  TextColumn get label => text()();

  IntColumn get destinationTripDefinitionId => integer()
      .named('destination_trip_definition_id')
      .references(TripDefinitions, #id)();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{
    stepDefinitionId,
    value,
  };

  @override
  List<Set<Column<Object>>> get uniqueKeys => <Set<Column<Object>>>[
    <Column<Object>>{stepDefinitionId, position},
  ];
}

@DataClassName('ScheduleRunRow')
class ScheduleRuns extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get scheduleDefinitionId => integer()
      .named('schedule_definition_id')
      .references(ScheduleDefinitions, #id)();

  IntColumn get currentTripOccurrenceId =>
      integer().named('current_trip_occurrence_id').nullable()();

  @override
  List<String> get customConstraints => <String>[
    'FOREIGN KEY (schedule_definition_id, current_trip_occurrence_id) REFERENCES schedule_trip_occurrences (schedule_definition_id, id) ON DELETE RESTRICT',
  ];
}

@DataClassName('ExecutionTraceEventRow')
class ExecutionTraceEvents extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get scheduleRunId =>
      integer().named('schedule_run_id').references(ScheduleRuns, #id)();

  late final IntColumn sequence = integer().check(
    sequence.isBiggerThanValue(0),
  )();

  late final TextColumn eventType = text()
      .named('event_type')
      .check(
        eventType.isIn(const <String>[
          scheduleRunStartedTraceEvent,
          tripStartedTraceEvent,
          stepStartedTraceEvent,
          stepCompletedTraceEvent,
          tripCompletedTraceEvent,
          routeDecisionTraceEvent,
          scheduleRunCompletedTraceEvent,
        ]),
      )();

  @ReferenceName('traceTripOccurrences')
  IntColumn get tripOccurrenceId => integer()
      .named('trip_occurrence_id')
      .nullable()
      .references(ScheduleTripOccurrences, #id)();

  IntColumn get stepOccurrenceId => integer()
      .named('step_occurrence_id')
      .nullable()
      .references(TripStepOccurrences, #id)();

  IntColumn get routingResultTripDefinitionId => integer()
      .named('routing_result_trip_definition_id')
      .nullable()
      .references(TripDefinitions, #id)();

  @ReferenceName('traceSelectedDestinationOccurrences')
  IntColumn get selectedDestinationTripOccurrenceId => integer()
      .named('selected_destination_trip_occurrence_id')
      .nullable()
      .references(ScheduleTripOccurrences, #id)();

  late final IntColumn occurredAtUtcUs = integer()
      .named('occurred_at_utc_us')
      .check(occurredAtUtcUs.isBiggerOrEqualValue(0))();

  @override
  List<Set<Column<Object>>> get uniqueKeys => <Set<Column<Object>>>[
    <Column<Object>>{scheduleRunId, sequence},
  ];

  @override
  List<String> get customConstraints => <String>[
    '''
    CHECK (
      (event_type IN ('schedule_run_started', 'schedule_run_completed')
        AND trip_occurrence_id IS NULL AND step_occurrence_id IS NULL)
      OR
      (event_type IN ('trip_started', 'trip_completed', 'route_decision')
        AND trip_occurrence_id IS NOT NULL AND step_occurrence_id IS NULL)
      OR
      (event_type IN ('step_started', 'step_completed')
        AND trip_occurrence_id IS NOT NULL AND step_occurrence_id IS NOT NULL)
    )''',
    '''
    CHECK (
      event_type = 'route_decision'
      OR (routing_result_trip_definition_id IS NULL
        AND selected_destination_trip_occurrence_id IS NULL)
    )''',
  ];
}

@DriftDatabase(
  tables: <Type>[
    ScheduleDefinitions,
    TripDefinitions,
    StepDefinitions,
    ScheduleTripOccurrences,
    TripStepOccurrences,
    TellStepDefinitions,
    FixedDestinationStepDefinitions,
    FdaTestStepDefinitions,
    ContactsSourceReadinessStepDefinitions,
    OpenFdaSettingsStepDefinitions,
    TestAgentDefinitions,
    TestStepDefinitions,
    ChoiceStepDefinitions,
    ChoiceStepOptions,
    ScheduleRuns,
    ExecutionTraceEvents,
  ],
)
class PresenceDatabase extends _$PresenceDatabase {
  PresenceDatabase(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => presenceSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator migrator) async {
      await migrator.createAll();
      await _createExecutionTraceAppendOnlyTriggers();
    },
    onUpgrade: (Migrator migrator, int from, int to) async {
      if (from < 2) {
        await migrator.alterTable(TableMigration(stepDefinitions));
        await migrator.createTable(fixedDestinationStepDefinitions);
      }
      if (from < 3) {
        if (from >= 2) {
          await migrator.alterTable(TableMigration(stepDefinitions));
        }
        await migrator.createTable(fdaTestStepDefinitions);
      }
      if (from < 4) {
        await migrator.createTable(executionTraceEvents);
        await _createExecutionTraceAppendOnlyTriggers();
      }
      if (from < 5) {
        await migrator.alterTable(TableMigration(stepDefinitions));
        await migrator.createTable(openFdaSettingsStepDefinitions);
      }
      if (from < 6) {
        await migrator.alterTable(TableMigration(stepDefinitions));
        await migrator.createTable(contactsSourceReadinessStepDefinitions);
      }
      if (from < 7) {
        await _addGenericTestGrammar(migrator);
      }
      if (from < 8) {
        await _activateGenericTestGrammar();
      }
      if (from < 9) {
        await migrator.alterTable(TableMigration(stepDefinitions));
        await migrator.createTable(choiceStepDefinitions);
        await migrator.createTable(choiceStepOptions);
      }
    },
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> _addGenericTestGrammar(Migrator migrator) async {
    await migrator.alterTable(TableMigration(stepDefinitions));
    await migrator.createTable(testAgentDefinitions);
    await migrator.createTable(testStepDefinitions);

    final messagesSourceAgentId = TestAgentId(
      'onboarding.messages-source-readable',
    );
    final contactsSourceAgentId = TestAgentId(
      'onboarding.contacts-source-readable',
    );
    await customStatement(
      'INSERT INTO test_agent_definitions (id) VALUES (?), (?)',
      <Object?>[messagesSourceAgentId.value, contactsSourceAgentId.value],
    );
    await customStatement(
      '''
      INSERT INTO test_step_definitions (
        step_definition_id,
        test_agent_id,
        true_destination_trip_definition_id,
        false_destination_trip_definition_id
      )
      SELECT
        step_definition_id,
        ?,
        present_destination_trip_definition_id,
        absent_destination_trip_definition_id
      FROM fda_test_step_definitions
      ''',
      <Object?>[messagesSourceAgentId.value],
    );
    await customStatement(
      '''
      INSERT INTO test_step_definitions (
        step_definition_id,
        test_agent_id,
        true_destination_trip_definition_id,
        false_destination_trip_definition_id
      )
      SELECT
        step_definition_id,
        ?,
        available_destination_trip_definition_id,
        unavailable_destination_trip_definition_id
      FROM contacts_source_readiness_step_definitions
      ''',
      <Object?>[contactsSourceAgentId.value],
    );

    // The generic rows are prepared now, but specialized base types remain
    // active until generic TestStep reconstruction is introduced atomically.
  }

  Future<void> _activateGenericTestGrammar() async {
    await customStatement(
      '''
      UPDATE step_definitions
      SET type = ?
      WHERE type IN (?, ?)
        AND id IN (SELECT step_definition_id FROM test_step_definitions)
      ''',
      <Object?>[testStepType, fdaTestStepType, contactsSourceReadinessStepType],
    );
  }

  Future<void> _createExecutionTraceAppendOnlyTriggers() async {
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS execution_trace_events_reject_update
      BEFORE UPDATE ON execution_trace_events
      BEGIN
        SELECT RAISE(ABORT, 'execution_trace_events is append-only');
      END
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS execution_trace_events_reject_delete
      BEFORE DELETE ON execution_trace_events
      BEGIN
        SELECT RAISE(ABORT, 'execution_trace_events is append-only');
      END
    ''');
  }
}
