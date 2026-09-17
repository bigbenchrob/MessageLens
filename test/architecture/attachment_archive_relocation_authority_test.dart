import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('verified relocation is not exported through the attachments seam', () {
    final seam = File(
      'lib/features/attachments/feature_level_providers.dart',
    ).readAsStringSync();

    expect(seam, isNot(contains('attachment_archive_relocation_provider')));
    expect(
      seam,
      isNot(contains('attachment_archive_relocation_activation_gate')),
    );
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
}
