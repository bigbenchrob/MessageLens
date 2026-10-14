enum MessageRichTextDecodeFailureKind {
  inputExceedsMaximumBytes,
  loadedBlobLengthMismatch,
  decoderDidNotProduceText,
}

sealed class MessageRichTextDecoderFact {
  const MessageRichTextDecoderFact();
}

final class MessageRichTextDecoderResult extends MessageRichTextDecoderFact {
  const MessageRichTextDecoderResult(this.text);

  final String text;
}

final class MessageRichTextDecoderFailure extends MessageRichTextDecoderFact {
  const MessageRichTextDecoderFailure(this.kind);

  final MessageRichTextDecodeFailureKind kind;
}

final class MessageRichTextSemanticInput {
  const MessageRichTextSemanticInput({
    required this.ssId,
    required this.sourceRowId,
    required this.attributedBodyBlobByteCount,
    required this.loadedAttributedBodyBlobByteCount,
    required this.maximumAttributedBodyBlobBytes,
    required this.decoderFact,
  });

  final int ssId;
  final int sourceRowId;
  final int attributedBodyBlobByteCount;
  final int? loadedAttributedBodyBlobByteCount;
  final int maximumAttributedBodyBlobBytes;
  final MessageRichTextDecoderFact decoderFact;
}

sealed class MessageRichTextSemanticProjection {
  const MessageRichTextSemanticProjection({
    required this.ssId,
    required this.sourceRowId,
  });

  final int ssId;
  final int sourceRowId;
}

final class PersistMessageRichText extends MessageRichTextSemanticProjection {
  const PersistMessageRichText({
    required super.ssId,
    required super.sourceRowId,
    required this.normalizedText,
  });

  final String normalizedText;
}

final class EmptyMessageRichText extends MessageRichTextSemanticProjection {
  const EmptyMessageRichText({required super.ssId, required super.sourceRowId});
}

final class FailedMessageRichText extends MessageRichTextSemanticProjection {
  const FailedMessageRichText({
    required super.ssId,
    required super.sourceRowId,
    required this.failureKind,
  });

  final MessageRichTextDecodeFailureKind failureKind;
}

MessageRichTextSemanticProjection projectMessageRichTextSemantics(
  MessageRichTextSemanticInput input,
) {
  return switch (input.decoderFact) {
    MessageRichTextDecoderFailure(:final kind) => FailedMessageRichText(
      ssId: input.ssId,
      sourceRowId: input.sourceRowId,
      failureKind: kind,
    ),
    MessageRichTextDecoderResult(:final text) => switch (text.trim()) {
      final normalizedText when normalizedText.isNotEmpty =>
        PersistMessageRichText(
          ssId: input.ssId,
          sourceRowId: input.sourceRowId,
          normalizedText: normalizedText,
        ),
      _ => EmptyMessageRichText(
        ssId: input.ssId,
        sourceRowId: input.sourceRowId,
      ),
    },
  };
}
