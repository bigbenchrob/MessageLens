import '../domain/message_lens_physical_installation_evidence.dart';

abstract interface class MessageLensPhysicalInstallationEvidenceReader {
  Future<MessageLensPhysicalInstallationEvidence> readPhysicalBounded({
    required String archiveRootPath,
  });
}
