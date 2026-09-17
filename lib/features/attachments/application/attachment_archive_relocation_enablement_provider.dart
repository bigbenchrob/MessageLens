import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'attachment_archive_relocation_enablement_provider.g.dart';

/// Final production safety gate for the attachment-archive relocation UI.
///
/// Phase Six deliberately ships the reviewed workflow with execution disabled.
/// Tests override this provider only for disposable archives. Enabling a real
/// relocation requires a later explicit code review and authorization.
@riverpod
bool attachmentArchiveRelocationProductionEnabled(Ref ref) => false;
