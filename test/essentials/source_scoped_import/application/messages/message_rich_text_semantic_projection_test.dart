import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_rich_text_semantic_projection.dart';

void main() {
  const rawFacts = (
    ssId: 101,
    sourceRowId: 51,
    attributedBodyBlobByteCount: 12,
    loadedAttributedBodyBlobByteCount: 12,
    maximumAttributedBodyBlobBytes: 8 * 1024 * 1024,
  );

  test('projects a decoded result to normalized persisted text', () {
    final projection = projectMessageRichTextSemantics(
      MessageRichTextSemanticInput(
        ssId: rawFacts.ssId,
        sourceRowId: rawFacts.sourceRowId,
        attributedBodyBlobByteCount: rawFacts.attributedBodyBlobByteCount,
        loadedAttributedBodyBlobByteCount:
            rawFacts.loadedAttributedBodyBlobByteCount,
        maximumAttributedBodyBlobBytes: rawFacts.maximumAttributedBodyBlobBytes,
        decoderFact: const MessageRichTextDecoderResult('  decoded text  '),
      ),
    );

    expect(
      projection,
      isA<PersistMessageRichText>()
          .having((value) => value.ssId, 'ssId', rawFacts.ssId)
          .having(
            (value) => value.sourceRowId,
            'sourceRowId',
            rawFacts.sourceRowId,
          )
          .having(
            (value) => value.normalizedText,
            'normalizedText',
            'decoded text',
          ),
    );
  });

  for (final text in <String>['', ' ', ' \n\t ']) {
    test('projects ${text.length}-character empty output as typed empty', () {
      final projection = projectMessageRichTextSemantics(
        MessageRichTextSemanticInput(
          ssId: rawFacts.ssId,
          sourceRowId: rawFacts.sourceRowId,
          attributedBodyBlobByteCount: rawFacts.attributedBodyBlobByteCount,
          loadedAttributedBodyBlobByteCount:
              rawFacts.loadedAttributedBodyBlobByteCount,
          maximumAttributedBodyBlobBytes:
              rawFacts.maximumAttributedBodyBlobBytes,
          decoderFact: MessageRichTextDecoderResult(text),
        ),
      );

      expect(projection, isA<EmptyMessageRichText>());
      expect(projection.ssId, rawFacts.ssId);
      expect(projection.sourceRowId, rawFacts.sourceRowId);
    });
  }

  for (final failureKind in MessageRichTextDecodeFailureKind.values) {
    test('preserves typed ${failureKind.name} failure', () {
      final projection = projectMessageRichTextSemantics(
        MessageRichTextSemanticInput(
          ssId: rawFacts.ssId,
          sourceRowId: rawFacts.sourceRowId,
          attributedBodyBlobByteCount: rawFacts.attributedBodyBlobByteCount,
          loadedAttributedBodyBlobByteCount:
              rawFacts.loadedAttributedBodyBlobByteCount,
          maximumAttributedBodyBlobBytes:
              rawFacts.maximumAttributedBodyBlobBytes,
          decoderFact: MessageRichTextDecoderFailure(failureKind),
        ),
      );

      expect(
        projection,
        isA<FailedMessageRichText>().having(
          (value) => value.failureKind,
          'failureKind',
          failureKind,
        ),
      );
    });
  }
}
