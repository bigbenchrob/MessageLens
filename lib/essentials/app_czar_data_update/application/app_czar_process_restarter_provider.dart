import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../features/attachments/application/attachment_archive_adoption_enablement_provider.dart'
    show attachmentArchiveAdoptionExecutionEnabledProvider;
import '../infrastructure/macos_development_process_restarter.dart';
import 'app_czar_process_restarter.dart';

part 'app_czar_process_restarter_provider.g.dart';

@riverpod
AppCzarProcessRestarter appCzarProcessRestarter(Ref ref) {
  return MacosDevelopmentProcessRestarter(
    developmentExecutionEnabled: ref.watch(
      attachmentArchiveAdoptionExecutionEnabledProvider,
    ),
  );
}
