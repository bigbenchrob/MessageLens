import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../conversation_graph/feature_level_providers.dart'
    show chatDbSourceProbeReaderProvider;
import '../domain/current_messages_source_evidence.dart';
import '../infrastructure/probe_current_messages_source_evidence_reader.dart';
import 'current_messages_source_evidence_reader.dart';

part 'current_messages_source_evidence_provider.g.dart';

@riverpod
CurrentMessagesSourceEvidenceReader currentMessagesSourceEvidenceReader(
  Ref ref,
) {
  return ProbeCurrentMessagesSourceEvidenceReader(
    sourceReadProbe: ref.watch(chatDbSourceProbeReaderProvider).readMaxRowId,
  );
}

@riverpod
String currentMessagesSourcePath(Ref ref) {
  return ref.watch(currentMessagesSourceEvidenceReaderProvider).sourcePath;
}

@riverpod
CurrentMessagesSourceEvidence currentMessagesSourceEvidence(Ref ref) {
  return ref.watch(currentMessagesSourceEvidenceReaderProvider).read();
}
