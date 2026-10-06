import '../domain/message_lens_installation_state.dart';

export '../../installation_evidence/application/message_lens_physical_installation_evidence_reader.dart';

abstract interface class MessageLensInstallationEvidenceReader {
  Future<MessageLensInstallationEvidence> readBounded({
    required String archiveRootPath,
  });
}
