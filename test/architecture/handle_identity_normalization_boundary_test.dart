import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'source handle identity remains separate from semantic normalization',
    () {
      final importer = File(
        'lib/essentials/source_scoped_import/application/handles/'
        'handle_importer.dart',
      ).readAsStringSync();
      final sourceProjection = File(
        'lib/essentials/source_scoped_import/application/handles/'
        'handle_source_projection.dart',
      ).readAsStringSync();
      final projection = File(
        'lib/essentials/conversation_graph/infrastructure/repositories/'
        'handle_projection_repository.dart',
      ).readAsStringSync();
      final identifierUtilities = File(
        'lib/essentials/db/shared/handle_identifier_utils.dart',
      ).readAsStringSync();

      expect(sourceProjection, contains('SourceScopedRowKey.pack'));
      expect(importer, isNot(contains('SourceScopedRowKey.pack')));
      expect(importer, contains('preservedUnnormalizedHandleCount'));
      expect(projection, contains('PreservedUnnormalizedHandleIdentifier'));
      expect(projection, isNot(contains('buildCanonicalHandleGroupingKey')));
      expect(
        identifierUtilities,
        isNot(contains('buildCanonicalHandleGroupingKey')),
      );
      expect(
        projection,
        isNot(contains('normalizedIdentifier: sourceHandle.rawIdentifier')),
      );
    },
  );
}
