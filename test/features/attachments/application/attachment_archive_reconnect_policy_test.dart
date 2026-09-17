import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_reconnect_policy.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_configuration.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_state.dart';

void main() {
  test('reconnect requests one bounded sweep per writable transition', () {
    final configuration = AttachmentArchiveLocationConfiguration.customExternal(
      bookmarkDataBase64: base64Encode(<int>[1]),
      lastKnownPath: '/Volumes/Archive',
      customWritePolicy: AttachmentArchiveCustomWritePolicy.activeArchive,
    );
    final unavailable = AttachmentArchiveLocationState.customUnavailable(
      configuration: configuration,
      issue: 'Disconnected.',
      generation: 1,
    );
    final available = AttachmentArchiveLocationState.customAvailable(
      configuration: configuration,
      archiveRootPath: '/Volumes/Archive',
      generation: 2,
    );
    final repeatedAvailable = available.withGeneration(2);

    final decisions = <bool>[
      shouldScheduleBoundedAttachmentArchiveReconnectSweep(
        previous: unavailable,
        current: available,
      ),
      shouldScheduleBoundedAttachmentArchiveReconnectSweep(
        previous: available,
        current: repeatedAvailable,
      ),
      shouldScheduleBoundedAttachmentArchiveReconnectSweep(
        previous: repeatedAvailable,
        current: repeatedAvailable,
      ),
    ];

    expect(decisions.where((decision) => decision), hasLength(1));
  });

  test(
    'default and non-activated custom roots never schedule reconnect work',
    () {
      final selectedConfiguration =
          AttachmentArchiveLocationConfiguration.customExternal(
            bookmarkDataBase64: base64Encode(<int>[2]),
            lastKnownPath: '/Volumes/Selected',
          );
      final selected = AttachmentArchiveLocationState.customAvailable(
        configuration: selectedConfiguration,
        archiveRootPath: '/Volumes/Selected',
      );
      final internal = AttachmentArchiveLocationState.defaultAvailable(
        archiveRootPath: '/internal/attachment_archive',
      );

      expect(
        shouldScheduleBoundedAttachmentArchiveReconnectSweep(
          previous: selected,
          current: selected,
        ),
        isFalse,
      );
      expect(
        shouldScheduleBoundedAttachmentArchiveReconnectSweep(
          previous: selected,
          current: internal,
        ),
        isFalse,
      );
    },
  );
}
