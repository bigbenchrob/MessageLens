import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'public seams expose neither mover execution nor activation internals',
    () {
      final seam = File(
        'lib/features/attachments/feature_level_providers.dart',
      ).readAsStringSync();
      final settingsSeam = File(
        'lib/features/settings/feature_level_providers.dart',
      ).readAsStringSync();

      expect(seam, isNot(contains('attachment_archive_relocation')));
      expect(
        seam,
        isNot(contains('attachment_archive_relocation_activation_gate')),
      );
      expect(seam, isNot(contains('AttachmentArchiveRelocationService')));
      expect(
        settingsSeam,
        isNot(contains('attachment_archive_relocation_actions_provider')),
      );
    },
  );

  test('only verified internal services construct active custom configuration', () {
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
      'lib/features/attachments/application/attachment_archive_adoption_service.dart',
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

  test(
    'legacy qualification predicate is exact but has no Settings consumer',
    () {
      final gate = File(
        'lib/features/attachments/application/'
        'attachment_archive_relocation_enablement_provider.dart',
      ).readAsStringSync();
      final actions = File(
        'lib/features/settings/application/'
        'attachment_archive_relocation_actions_provider.dart',
      ).readAsStringSync();
      final settingsComposition = File(
        'lib/essentials/sidebar/application/'
        'cassette_widget_coordinator_provider.dart',
      ).readAsStringSync();

      expect(gate, contains('admittedArchiveAccessAuthorityProvider'));
      expect(
        gate,
        contains(
          '/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/'
          'MessageLens Development',
        ),
      );
      expect(gate, contains('e9310d3f-8dc8-4436-a48e-c4fb7cf8d4a5'));
      expect(RegExp(r'/Volumes/').allMatches(gate), hasLength(1));
      expect(gate, isNot(contains('attachmentArchiveLocationProvider')));
      expect(gate, isNot(contains('Platform.environment')));
      expect(gate, isNot(contains('String.fromEnvironment')));
      expect(gate, isNot(contains('bool.fromEnvironment')));
      expect(gate, isNot(contains('readSetting')));
      expect(gate, isNot(contains('writeSetting')));
      expect(
        actions,
        isNot(contains('attachmentArchiveRelocationExecutionEnabledProvider')),
      );
      expect(
        actions,
        isNot(contains('attachmentArchiveRelocationWorkflowProvider')),
      );
      expect(
        settingsComposition,
        isNot(contains('attachmentArchiveRelocationExecutionEnabledProvider')),
      );
      expect(
        settingsComposition,
        isNot(contains('attachmentArchiveRelocationWorkflowProvider')),
      );
    },
  );
}
