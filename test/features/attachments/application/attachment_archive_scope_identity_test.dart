import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_scope_identity.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_configuration.dart';

void main() {
  const internal = AttachmentArchiveLocationConfiguration.defaultInternal();

  test('normalizes the resolved root before deriving scope identity', () {
    final canonical = attachmentArchiveScopeIdentity(
      archiveInstanceId: 'archive-instance',
      configuration: internal,
      archiveRootPath: '/tmp/archive',
    );
    final equivalent = attachmentArchiveScopeIdentity(
      archiveInstanceId: 'archive-instance',
      configuration: internal,
      archiveRootPath: '/tmp/parent/../archive',
    );

    expect(equivalent, canonical);
  });

  test('binds scope to archive instance and persisted configuration', () {
    final baseline = attachmentArchiveScopeIdentity(
      archiveInstanceId: 'archive-instance-a',
      configuration: internal,
      archiveRootPath: '/tmp/archive',
    );
    final differentInstance = attachmentArchiveScopeIdentity(
      archiveInstanceId: 'archive-instance-b',
      configuration: internal,
      archiveRootPath: '/tmp/archive',
    );
    final external = AttachmentArchiveLocationConfiguration.customExternal(
      bookmarkDataBase64: 'bookmark',
      lastKnownPath: '/tmp/archive',
      customWritePolicy: AttachmentArchiveCustomWritePolicy.activeArchive,
    );
    final differentConfiguration = attachmentArchiveScopeIdentity(
      archiveInstanceId: 'archive-instance-a',
      configuration: external,
      archiveRootPath: '/tmp/archive',
    );

    expect(differentInstance, isNot(baseline));
    expect(differentConfiguration, isNot(baseline));
  });
}
