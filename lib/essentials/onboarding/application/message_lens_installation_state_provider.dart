import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../archive_environment/feature_level_providers.dart'
    show archiveAccessAuthorityProvider;
import '../domain/startup_installation_validation.dart';
import '../infrastructure/persistence/sqlite_message_lens_installation_evidence_reader.dart';
import '../infrastructure/persistence/sqlite_message_lens_installation_integrity_validator.dart';
import 'message_lens_installation_validation_service.dart';

part 'message_lens_installation_state_provider.g.dart';

@Riverpod(keepAlive: true)
Stream<StartupInstallationValidationState> messageLensInstallationState(
  Ref ref,
) {
  final authority = ref.watch(archiveAccessAuthorityProvider);
  return const MessageLensInstallationValidationService(
    evidenceReader: SqliteMessageLensInstallationEvidenceReader(),
    integrityValidator: SqliteMessageLensInstallationIntegrityValidator(),
  ).validateForStartup(archiveRootPath: authority.rootPath);
}
