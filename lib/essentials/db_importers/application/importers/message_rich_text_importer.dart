import '../../domain/base_table_importer.dart';
import '../../domain/row_progress_reporter.dart';
import '../../infrastructure/sqlite/import_context_sqlite.dart';

class MessageRichTextImporter extends BaseTableImporter
    with RowProgressReporter {
  MessageRichTextImporter();

  @override
  String get name => 'message_rich_text';

  @override
  List<String> get dependsOn => const <String>['messages'];

  @override
  Future<void> validatePrereqs(IImportContext ctx) async {
    // No-op: this importer enhances previously imported messages.
  }

  @override
  Future<void> copy(IImportContext ctx) async {
    final extractor = ctx.extractor;
    final linkedCandidates = _readCandidateIds(
      ctx,
      'messages.extractionCandidates',
    );
    final recoveredCandidates = _readCandidateIds(
      ctx,
      'recoveredUnlinkedMessages.extractionCandidates',
    );
    final candidates = <int>{
      ...linkedCandidates,
      ...recoveredCandidates,
    }.toList(growable: false);
    ctx.info(
      'MessageRichTextImporter: starting with ${candidates.length} extraction candidates '
      '(messagesDbPath=${ctx.messagesDbPath}, rustExtractionLimit=${ctx.rustExtractionLimit}).',
    );
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
    ctx.info(
      'MessageRichTextImporter: extractor availability result = $available.',
    );
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
        'MessageRichTextImporter: extraction failed (${error.runtimeType}): $error',
      );
      ctx.writeScratch('messages.richTextApplied', 0);
      return;
    }

    ctx.info(
      'MessageRichTextImporter: extractor returned ${extracted.length} decoded message payloads.',
    );

    if (extracted.isEmpty) {
      ctx.info('MessageRichTextImporter: extractor returned no results.');
      ctx.writeScratch('messages.richTextApplied', 0);
      return;
    }

    var linkedApplied = 0;
    var recoveredApplied = 0;
    var processed = 0;
    var emptyOrMissingResults = 0;
    for (final id in linkedCandidates) {
      final text = extracted[id];
      final normalized = text?.trim();
      if (normalized == null || normalized.isEmpty) {
        emptyOrMissingResults += 1;
        processed += 1;
        continue;
      }
      await ctx.importDb.updateMessageText(messageId: id, text: normalized);
      linkedApplied += 1;
      processed += 1;
      if (processed % 200 == 0 || processed == candidates.length) {
        reportRowProgress(processed: processed, total: candidates.length);
      }
    }

    for (final id in recoveredCandidates) {
      final text = extracted[id];
      final normalized = text?.trim();
      if (normalized == null || normalized.isEmpty) {
        emptyOrMissingResults += 1;
        processed += 1;
        continue;
      }
      await ctx.importDb.updateRecoveredUnlinkedMessageText(
        messageId: id,
        text: normalized,
      );
      recoveredApplied += 1;
      processed += 1;
      if (processed % 200 == 0 || processed == candidates.length) {
        reportRowProgress(processed: processed, total: candidates.length);
      }
    }

    ctx.info(
      'MessageRichTextImporter: applied extracted text to '
      '${linkedApplied + recoveredApplied}/${candidates.length} messages '
      '($emptyOrMissingResults empty-or-missing results).',
    );
    ctx.writeScratch('messages.richTextApplied', linkedApplied);
    ctx.writeScratch(
      'recoveredUnlinkedMessages.richTextApplied',
      recoveredApplied,
    );
  }

  @override
  Future<void> postValidate(IImportContext ctx) async {}
}

List<int> _readCandidateIds(IImportContext ctx, String key) {
  final raw = ctx.readScratch<Object?>(key);
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
