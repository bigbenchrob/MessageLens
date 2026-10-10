import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/messages_source/feature_level_providers.dart';

void main() {
  test('path projection is lazy and does not perform a source read', () {
    final reader = _FakeCurrentMessagesSourceEvidenceReader();
    final container = ProviderContainer(
      overrides: [
        currentMessagesSourceEvidenceReaderProvider.overrideWith(
          (ref) => reader,
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(
      container.read(currentMessagesSourcePathProvider),
      '/source/chat.db',
    );
    expect(reader.readCount, 0);

    final evidence = container.read(currentMessagesSourceEvidenceProvider);

    expect(evidence.isReadable, isTrue);
    expect(reader.readCount, 1);
  });
}

final class _FakeCurrentMessagesSourceEvidenceReader
    implements CurrentMessagesSourceEvidenceReader {
  var readCount = 0;

  @override
  String get sourcePath => '/source/chat.db';

  @override
  CurrentMessagesSourceEvidence read() {
    readCount++;
    return const CurrentMessagesSourceEvidence.readable(
      sourcePath: '/source/chat.db',
      maxRowId: 42,
    );
  }
}
