import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/working/constants.dart';

void main() {
  final workingDatabaseSource = File(
    'lib/essentials/db/infrastructure/data_sources/local/working/working_database.dart',
  ).readAsStringSync();

  test('service constraints stay in sync with carrier constants', () {
    final constraints = _extractServiceConstraints(workingDatabaseSource);
    expect(
      constraints.length,
      3,
      reason:
          'handles, chats, and chat_to_handle each declare a service constraint',
    );

    constraints.forEach(_expectConstraintMatchesValues);
  });
}

void _expectConstraintMatchesValues(String constraint) {
  expect(
    constraint,
    contains('NOT NULL'),
    reason: 'constraint must include NOT NULL requirement',
  );
  expect(
    constraint,
    contains('DEFAULT ${"'$carrierServiceUnknownValue'"}'),
    reason: 'constraint must include expected default value',
  );

  final match = RegExp(r'CHECK\(service IN \((.+)\)\)').firstMatch(constraint);
  expect(match, isNotNull, reason: 'constraint must contain service IN clause');

  final rawValues = match!.group(1)!;
  final parsed = rawValues
      .split(',')
      .map((segment) => segment.trim().replaceAll("'", '').replaceAll('"', ''))
      .toList();

  expect(
    parsed,
    carrierServiceValues,
    reason: 'constraint values must match documented carrier services',
  );

  expect(constraint, carrierServiceCheckConstraint);
}

List<String> _extractServiceConstraints(String source) {
  final regex = RegExp(r'customConstraint\([\s\r\n]*"([^"]+)"', dotAll: true);

  return regex
      .allMatches(source)
      .map((match) => match.group(1)!)
      .where((value) => value.contains('service IN ('))
      .toList();
}
