import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'attachment_archive_relocation_actions_provider.g.dart';

/// Inert legacy shell retained until the obsolete mover is extracted/removed.
///
/// It is intentionally absent from the Settings public seam and exposes no
/// action capable of reaching the legacy relocation workflow.
@riverpod
class AttachmentArchiveRelocationActions
    extends _$AttachmentArchiveRelocationActions {
  @override
  void build() {}
}
