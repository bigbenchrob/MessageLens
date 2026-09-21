import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('showcase presentation imports no mutation or adoption authority', () {
    final presentationImports = _imports(_read(_viewPath));
    const forbidden = <String>[
      'archive_mutation',
      'adoption',
      'remediation_authority',
      'location_controller',
      'file_store',
      '/db/',
      'package:http',
    ];

    for (final token in forbidden) {
      expect(
        presentationImports,
        isNot(contains(token)),
        reason: 'Showcase presentation must not import $token',
      );
    }
  });

  test('showcase source is transient, local, and bounded', () {
    final source = _read(_sourcePath);

    expect(source, contains('Duration(milliseconds: 750)'));
    expect(source, contains('AttachmentShowcaseItem? _pendingLatest'));
    expect(source, contains('int get retainedItemCount'));
    expect(source, isNot(contains('List<AttachmentShowcaseItem>')));
    expect(source, isNot(contains("import 'dart:io'")));
    expect(source, isNot(contains('Database')));
    expect(source, isNot(contains('writeAs')));
    expect(source, isNot(contains('package:http')));
    expect(source, isNot(contains('SettingsStore')));
    expect(source, isNot(contains('SharedPreferences')));
  });

  test('remediation publishes synchronously after verified installation', () {
    final service = _read(_servicePath);
    final remediationStart = service.indexOf('Future<void> _remediate(');
    final publishStart = service.indexOf('void _publishShowcaseItem(');

    expect(remediationStart, greaterThanOrEqualTo(0));
    expect(publishStart, greaterThan(remediationStart));
    final remediation = service.substring(remediationStart, publishStart);
    expect(
      remediation.indexOf('installVerifiedArchiveEntryAtPath('),
      lessThan(remediation.indexOf('_publishShowcaseItem(')),
    );
    expect(remediation, isNot(contains('await _publishShowcaseItem(')));

    final finalProofStart = service.indexOf(
      'Future<void> _proveFinalCoverage(',
      publishStart,
    );
    final publisher = service.substring(publishStart, finalProofStart);
    expect(publisher, contains('try {'));
    expect(publisher, contains('} on Object {'));
  });
}

String _read(String filePath) => File(filePath).readAsStringSync();

String _imports(String source) {
  return source
      .split('\n')
      .where((line) => line.trimLeft().startsWith('import '))
      .join('\n');
}

const _servicePath =
    'lib/features/attachments/application/'
    'attachment_archive_adoption_service.dart';
const _sourcePath =
    'lib/features/attachments/application/'
    'attachment_showcase_source_provider.dart';
const _viewPath =
    'lib/features/attachments/presentation/widgets/'
    'attachment_showcase_view.dart';
