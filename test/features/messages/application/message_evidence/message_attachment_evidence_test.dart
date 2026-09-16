import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/chat_summaries/chat_summary.dart';
import 'package:remember_this_text/features/attachments/application/attachment_file_access.dart';
import 'package:remember_this_text/features/attachments/domain/constants/attachment_archive_payload_status.dart';
import 'package:remember_this_text/features/attachments/domain/constants/attachment_provenance.dart';
import 'package:remember_this_text/features/attachments/domain/constants/resolved_attachment_availability.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_state.dart';
import 'package:remember_this_text/features/messages/application/message_evidence/message_attachment_evidence.dart';

void main() {
  test(
    'maps archived message image attachment to display-ready evidence',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'message-attachment-evidence-test-',
      );
      addTearDown(() async {
        await tempDir.delete(recursive: true);
      });
      final archivedFile = File('${tempDir.path}/photo.jpg');
      await archivedFile.writeAsBytes(const <int>[1, 2, 3]);

      final evidence = messageAttachmentEvidenceFromMessageAttachment(
        MessageAttachment(
          attachmentSsId: 1,
          guid: 'guid',
          filename: '/source/photo.jpg',
          transferName: 'photo.jpg',
          uti: 'public.jpeg',
          mimeType: 'image/jpeg',
          totalBytes: 100,
          createdAtUtc: '2026-05-20T10:00:00.000Z',
          localFileExists: false,
          archiveRelativePath: 'aa/photo.jpg',
          archiveAbsolutePath: archivedFile.path,
          archiveFileExists: true,
        ),
        _FakeAttachmentFileAccess(existingPaths: {archivedFile.path}),
      );

      expect(evidence.isImage, isTrue);
      expect(evidence.isDisplayable, isTrue);
      expect(evidence.displayPath, archivedFile.path);
      expect(evidence.provenance, AttachmentProvenance.archived);
      expect(evidence.availability, ResolvedAttachmentAvailability.available);
    },
  );

  test('maps missing message attachment to visible unavailable evidence', () {
    final evidence = messageAttachmentEvidenceFromMessageAttachment(
      const MessageAttachment(
        attachmentSsId: 2,
        guid: 'guid',
        filename: '/missing/photo.jpg',
        transferName: 'photo.jpg',
        uti: 'public.jpeg',
        mimeType: 'image/jpeg',
        totalBytes: 100,
        createdAtUtc: '2026-05-20T10:00:00.000Z',
        localFileExists: false,
        archiveRelativePath: 'aa/photo.jpg',
        archiveAbsolutePath: '/missing/archive/photo.jpg',
        archiveFileExists: false,
      ),
      const _FakeAttachmentFileAccess(),
    );

    expect(evidence.isImage, isTrue);
    expect(evidence.isDisplayable, isFalse);
    expect(
      evidence.availability,
      ResolvedAttachmentAvailability.unavailableAwaitingRecovery,
    );
    expect(evidence.provenance, isNull);
  });

  test(
    'maps archived message video attachment to display-ready evidence',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'message-video-evidence-test-',
      );
      addTearDown(() async {
        await tempDir.delete(recursive: true);
      });
      final archivedFile = File('${tempDir.path}/clip.mov');
      await archivedFile.writeAsBytes(const <int>[1, 2, 3]);

      final evidence = messageAttachmentEvidenceFromMessageAttachment(
        MessageAttachment(
          attachmentSsId: 3,
          guid: 'guid',
          filename: '/source/clip.mov',
          transferName: 'clip.mov',
          uti: 'public.movie',
          mimeType: 'video/quicktime',
          totalBytes: 100,
          createdAtUtc: '2026-05-20T10:00:00.000Z',
          localFileExists: false,
          archiveRelativePath: 'aa/clip.mov',
          archiveAbsolutePath: archivedFile.path,
          archiveFileExists: true,
        ),
        _FakeAttachmentFileAccess(existingPaths: {archivedFile.path}),
      );

      expect(evidence.isVideo, isTrue);
      expect(evidence.isDisplayable, isTrue);
      expect(evidence.displayPath, archivedFile.path);
      expect(evidence.provenance, AttachmentProvenance.archived);
      expect(evidence.availability, ResolvedAttachmentAvailability.available);
    },
  );

  test('classifies plugin payload attachments as URL preview evidence', () {
    final evidence = messageAttachmentEvidenceFromMessageAttachment(
      const MessageAttachment(
        attachmentSsId: 4,
        guid: 'guid',
        filename: '/source/GUID.pluginPayloadAttachment',
        transferName: 'GUID.pluginPayloadAttachment',
        uti: null,
        mimeType: null,
        totalBytes: 100,
        createdAtUtc: '2026-05-20T10:00:00.000Z',
        localFileExists: false,
        archiveRelativePath: 'aa/GUID.pluginPayloadAttachment',
        archiveAbsolutePath: '/archive/GUID.pluginPayloadAttachment',
        archiveFileExists: false,
      ),
      const _FakeAttachmentFileAccess(),
    );

    expect(evidence.isUrlPreview, isTrue);
    expect(evidence.isImage, isFalse);
    expect(evidence.isVideo, isFalse);
  });

  test('extracts first URL from message text', () {
    expect(
      firstUrlInMessageText('see https://example.com/story now'),
      'https://example.com/story',
    );
    expect(firstUrlInMessageText('no URL here'), isNull);
  });

  test('maps unavailable archive root without claiming payload missing', () {
    final evidence = messageAttachmentEvidenceFromMessageAttachment(
      const MessageAttachment(
        attachmentSsId: 5,
        guid: 'guid',
        filename: '/source/offline.jpg',
        transferName: 'offline.jpg',
        uti: 'public.jpeg',
        mimeType: 'image/jpeg',
        totalBytes: 100,
        createdAtUtc: '2026-09-15T10:00:00.000Z',
        localFileExists: false,
        archiveRelativePath: 'aa/offline.jpg',
        archiveAbsolutePath: null,
        archivePayloadStatus: AttachmentArchivePayloadStatus.rootUnavailable,
        archiveLocationAvailability:
            AttachmentArchiveLocationAvailability.customUnavailable,
        archiveLocationGeneration: 4,
        archiveRootIssue: 'Volume disconnected.',
      ),
      const _FakeAttachmentFileAccess(),
    );

    expect(
      evidence.availability,
      ResolvedAttachmentAvailability.archiveUnavailable,
    );
    expect(evidence.availabilityLabel, 'archive unavailable');
    expect(
      evidence.archivePayloadStatus,
      AttachmentArchivePayloadStatus.rootUnavailable,
    );
    expect(evidence.archiveLocationGeneration, 4);
  });

  test('live fallback keeps archive-unavailable evidence visible', () {
    const livePath = '/source/offline.jpg';
    final evidence = messageAttachmentEvidenceFromMessageAttachment(
      const MessageAttachment(
        attachmentSsId: 6,
        guid: 'guid',
        filename: livePath,
        transferName: 'offline.jpg',
        uti: 'public.jpeg',
        mimeType: 'image/jpeg',
        totalBytes: 100,
        createdAtUtc: '2026-09-15T10:00:00.000Z',
        localFileExists: true,
        archiveRelativePath: 'aa/offline.jpg',
        archiveAbsolutePath: null,
        archivePayloadStatus: AttachmentArchivePayloadStatus.rootUnavailable,
        archiveLocationAvailability:
            AttachmentArchiveLocationAvailability.customUnavailable,
      ),
      const _FakeAttachmentFileAccess(existingPaths: {livePath}),
    );

    expect(evidence.availability, ResolvedAttachmentAvailability.available);
    expect(evidence.provenance, AttachmentProvenance.messagesLive);
    expect(
      evidence.availabilityLabel,
      'available from Messages · archive unavailable',
    );
  });

  test('collapses multiple URL preview resources into one evidence item', () {
    final evidence = messageAttachmentEvidenceFromMessageAttachments(const [
      MessageAttachment(
        attachmentSsId: 10,
        guid: 'preview-1',
        filename: '/source/ONE.pluginPayloadAttachment',
        transferName: 'ONE.pluginPayloadAttachment',
        uti: null,
        mimeType: null,
        totalBytes: 100,
        createdAtUtc: '2026-05-20T10:00:00.000Z',
        localFileExists: false,
        archiveRelativePath: null,
        archiveAbsolutePath: null,
        archiveFileExists: false,
      ),
      MessageAttachment(
        attachmentSsId: 11,
        guid: 'preview-2',
        filename: '/source/TWO.pluginPayloadAttachment',
        transferName: 'TWO.pluginPayloadAttachment',
        uti: null,
        mimeType: null,
        totalBytes: 100,
        createdAtUtc: '2026-05-20T10:00:00.000Z',
        localFileExists: false,
        archiveRelativePath: null,
        archiveAbsolutePath: null,
        archiveFileExists: false,
      ),
      MessageAttachment(
        attachmentSsId: 12,
        guid: 'image',
        filename: '/source/photo.jpg',
        transferName: 'photo.jpg',
        uti: 'public.jpeg',
        mimeType: 'image/jpeg',
        totalBytes: 100,
        createdAtUtc: '2026-05-20T10:00:00.000Z',
        localFileExists: false,
        archiveRelativePath: null,
        archiveAbsolutePath: null,
        archiveFileExists: false,
      ),
    ], const _FakeAttachmentFileAccess());

    expect(evidence, hasLength(2));
    expect(evidence.first.isUrlPreview, isTrue);
    expect(evidence.first.attachmentSsId, 10);
    expect(evidence.first.sourceRecordCount, 2);
    expect(evidence.last.isImage, isTrue);
  });
}

class _FakeAttachmentFileAccess implements AttachmentFileAccess {
  const _FakeAttachmentFileAccess({this.existingPaths = const <String>{}});

  final Set<String> existingPaths;

  @override
  String? expandPath(String? path) {
    return path == null || path.isEmpty ? null : path;
  }

  @override
  String? existingExpandedPath(String? path) {
    if (path == null || path.isEmpty || !existingPaths.contains(path)) {
      return null;
    }
    return path;
  }
}
