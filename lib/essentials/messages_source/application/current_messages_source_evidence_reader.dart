import '../domain/current_messages_source_evidence.dart';

abstract interface class CurrentMessagesSourceEvidenceReader {
  String get sourcePath;

  CurrentMessagesSourceEvidence read();
}
