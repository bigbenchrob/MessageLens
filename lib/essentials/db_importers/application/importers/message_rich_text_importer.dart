import '../../domain/base_table_importer.dart';
import '../../infrastructure/sqlite/import_context_sqlite.dart';

class MessageRichTextImporter extends BaseTableImporter {
  const MessageRichTextImporter();

  @override
  String get name => 'message_rich_text';

  @override
  List<String> get dependsOn => const <String>['messages'];

  @override
  Future<void> validatePrereqs(ImportContext ctx) async {
    // No-op: this importer enhances previously imported messages.
  }

  @override
  Future<void> copy(ImportContext ctx) async {
    final extractor = ctx.extractor;
    final candidates = _readCandidateIds(ctx);
    if (candidates.isEmpty) {
      ctx.info('MessageRichTextImporter: no extraction candidates detected.');
      ctx.writeScratch('messages.richTextApplied', 0);
      return;
    }

    if (extractor == null) {
      ctx.info(
        'MessageRichTextImporter: extractor not available, skipping rich text extraction.',
      );
      ctx.writeScratch('messages.richTextApplied', 0);
      return;
    }

    final available = await extractor.isAvailable();
    if (!available) {
      ctx.info(
        'MessageRichTextImporter: extractor reported unavailable, skipping.',
      );
      ctx.writeScratch('messages.richTextApplied', 0);
      return;
    }

    Map<int, String> extracted;
    try {
      extracted = await extractor.extractAllMessageTexts(
        limit: ctx.rustExtractionLimit,
        dbPath: ctx.messagesDbPath,
      );
    } catch (error) {
      ctx.info(
        'MessageRichTextImporter: extraction failed (${error.runtimeType}), skipping.',
      );
      ctx.writeScratch('messages.richTextApplied', 0);
      return;
    }

    if (extracted.isEmpty) {
      ctx.info('MessageRichTextImporter: extractor returned no results.');
      ctx.writeScratch('messages.richTextApplied', 0);
      return;
    }

    var applied = 0;
    for (final id in candidates) {
      final text = extracted[id];
      final normalized = text?.trim();
      if (normalized == null || normalized.isEmpty) {
        continue;
      }
      await ctx.importDb.updateMessageText(messageId: id, text: normalized);
      applied += 1;
    }

    ctx.info(
      'MessageRichTextImporter: applied extracted text to $applied/${candidates.length} messages.',
    );
    ctx.writeScratch('messages.richTextApplied', applied);
  }

  @override
  Future<void> postValidate(ImportContext ctx) async {}
}

List<int> _readCandidateIds(ImportContext ctx) {
  final raw = ctx.readScratch<Object?>('messages.extractionCandidates');
  if (raw is List<Object?>) {
    return raw
        .map(
          (e) => e is int
              ? e
              : e is num
              ? e.toInt()
              : int.tryParse('$e'),
        )
        .whereType<int>()
        .toList(growable: false);
  }
  if (raw is List<int>) {
    return List<int>.from(raw);
  }
  return <int>[];
}
