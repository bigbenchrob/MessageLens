import '../domain/message_lens_installation_state.dart';

abstract interface class MessageLensInstallationEvidenceReader {
  Future<MessageLensInstallationEvidence> readBounded({
    required String archiveRootPath,
  });
}
