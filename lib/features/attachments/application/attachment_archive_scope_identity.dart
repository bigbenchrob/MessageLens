import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;

import '../domain/entities/attachment_archive_location_configuration.dart';

/// Returns the stable identity for one admitted attachment-archive scope.
///
/// A scope is more specific than a filesystem path: it is bound to the
/// MessageLens archive instance, the persisted location configuration, and the
/// canonical resolved attachment root. Startup assessment and mutation-time
/// revalidation must use this same function so they cannot disagree about
/// which archive an observation describes.
String attachmentArchiveScopeIdentity({
  required String archiveInstanceId,
  required AttachmentArchiveLocationConfiguration configuration,
  required String archiveRootPath,
}) {
  final material = <String>[
    archiveInstanceId,
    configuration.toPersistedValue(),
    path.normalize(path.absolute(archiveRootPath)),
  ].join('\u0000');
  return sha256.convert(utf8.encode(material)).toString();
}
