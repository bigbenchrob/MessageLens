import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../archive_environment/feature_level_providers.dart'
    show archiveAccessAuthorityProvider;
import '../domain/message_lens_installation_state.dart';
import '../infrastructure/persistence/sqlite_message_lens_installation_evidence_reader.dart';
import 'message_lens_installation_evidence_reader.dart';
import 'message_lens_installation_state_classifier.dart';

part 'advanced_start_fresh_current_state_reader_provider.g.dart';

abstract interface class AdvancedStartFreshCurrentStateReader {
  Future<MessageLensInstallationState> readCurrentState();
}

final class BoundedAdvancedStartFreshCurrentStateReader
    implements AdvancedStartFreshCurrentStateReader {
  const BoundedAdvancedStartFreshCurrentStateReader({
    required this.archiveRootPath,
    required this.evidenceReader,
    this.classifier = const MessageLensInstallationStateClassifier(),
  });

  final String archiveRootPath;
  final MessageLensInstallationEvidenceReader evidenceReader;
  final MessageLensInstallationStateClassifier classifier;

  @override
  Future<MessageLensInstallationState> readCurrentState() async {
    final evidence = await evidenceReader.readBounded(
      archiveRootPath: archiveRootPath,
    );
    return classifier.classify(evidence);
  }
}

@Riverpod(keepAlive: true)
AdvancedStartFreshCurrentStateReader advancedStartFreshCurrentStateReader(
  Ref ref,
) {
  final authority = ref.watch(archiveAccessAuthorityProvider);
  return BoundedAdvancedStartFreshCurrentStateReader(
    archiveRootPath: authority.rootPath,
    evidenceReader: const SqliteMessageLensInstallationEvidenceReader(),
  );
}
