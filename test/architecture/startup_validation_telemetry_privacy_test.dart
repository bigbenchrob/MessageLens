import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('startup validation telemetry model cannot accept content payloads', () {
    final source = File(
      'lib/essentials/onboarding/domain/startup_validation_telemetry.dart',
    ).readAsStringSync();
    const forbiddenIdentifiers = <String>[
      'messageText',
      'message_text',
      'contactName',
      'contactHandle',
      'attachmentName',
      'attachmentPath',
      'archiveRootPath',
      'canonicalRootPath',
      'urlValue',
      'rawDatabaseRow',
      'sqlResultContents',
      'failureMessage',
    ];

    for (final identifier in forbiddenIdentifiers) {
      expect(source, isNot(contains(identifier)), reason: identifier);
    }
    expect(source, isNot(contains('Map<String, dynamic>? context')));
  });
}
