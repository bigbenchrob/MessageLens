import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('public seam exposes workflow but not activation internals', () {
    final seam = File(
      'lib/features/attachments/feature_level_providers.dart',
    ).readAsStringSync();

    expect(seam, contains('attachment_archive_relocation_provider'));
    expect(
      seam,
      isNot(contains('attachment_archive_relocation_activation_gate')),
    );
    expect(seam, isNot(contains('AttachmentArchiveRelocationService')));
  });

  test('only relocation service constructs an active custom configuration', () {
    final offenders = <String>[];
    for (final entity in Directory(
      'lib/features/attachments',
    ).listSync(recursive: true, followLinks: false)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }
      final source = entity.readAsStringSync();
      if (RegExp(
        r'customWritePolicy:\s*AttachmentArchiveCustomWritePolicy\s*\.\s*activeArchive',
        multiLine: true,
      ).hasMatch(source)) {
        offenders.add(entity.path);
      }
    }

    expect(offenders, <String>[
      'lib/features/attachments/application/attachment_archive_relocation_service.dart',
    ]);
  });

  test('ordinary configuration persistence rejects activeArchive', () {
    final controller = File(
      'lib/features/attachments/application/'
      'attachment_archive_location_controller.dart',
    ).readAsStringSync();

    expect(
      controller,
      contains('Active custom attachment archives require verified relocation'),
    );
    expect(controller, contains('persistVerifiedRelocationConfiguration'));
    expect(controller, contains('AttachmentArchiveRelocationActivationPermit'));
  });

  test('settings widgets contain no archive filesystem or persistence work', () {
    final widgets = <File>[
      File(
        'lib/features/settings/application/sidebar_cassette_spec/'
        'widget_builders/attachment_archive_settings_supplemental_content.dart',
      ),
      File(
        'lib/features/settings/application/sidebar_cassette_spec/'
        'widget_builders/settings_action_list.dart',
      ),
    ];

    for (final widget in widgets) {
      final source = widget.readAsStringSync();
      expect(source, isNot(contains("import 'dart:io'")), reason: widget.path);
      expect(source, isNot(contains('Directory(')), reason: widget.path);
      expect(source, isNot(contains('File(')), reason: widget.path);
      expect(source, isNot(contains('createBookmark')), reason: widget.path);
      expect(
        source,
        isNot(contains('persistConfiguration')),
        reason: widget.path,
      );
      expect(source, isNot(contains('activeArchive')), reason: widget.path);
    }
  });

  test('production relocation gate defaults off', () {
    final gate = File(
      'lib/features/attachments/application/'
      'attachment_archive_relocation_enablement_provider.dart',
    ).readAsStringSync();

    expect(
      gate,
      contains(
        'attachmentArchiveRelocationProductionEnabled(Ref ref) => false',
      ),
    );
  });
}
