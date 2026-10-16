import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/archive_reset_admission.dart';

part 'archive_reset_admission_provider.g.dart';

/// Only the composition root supplies explicit selection. Absence denies reset.
@Riverpod(keepAlive: true)
ArchiveResetAdmission archiveResetAdmission(Ref ref) {
  final admission = ArchiveResetAdmission.unavailable();
  ref.onDispose(admission.revoke);
  return admission;
}
