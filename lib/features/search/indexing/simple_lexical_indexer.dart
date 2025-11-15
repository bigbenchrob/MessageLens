import 'search_indexer.dart';

class SimpleLexicalIndexer extends SearchIndexer {
  SimpleLexicalIndexer();

  @override
  String get id => 'simple_lexical';

  @override
  String get description =>
      'Validates single-term LIKE search fallback (legacy path)';

  @override
  Future<void> rebuildAll(SearchIndexContext context) async {
    context.info(
      '[SimpleLexicalIndexer] rebuildAll called — no-op (logical indexer)',
    );
  }

  @override
  bool get supportsPartialRebuild => false;

  @override
  Future<void> rebuildForMessages(
    SearchIndexContext context,
    Iterable<int> messageIds,
  ) async {}

  @override
  Future<void> validate(SearchIndexContext context) async {
    final db = context.db;
    const sampleQuery =
        'SELECT id FROM working_messages WHERE text_content IS NOT NULL '
        "AND LOWER(text_content) LIKE '%a%' LIMIT 1";

    try {
      await db.customSelect(sampleQuery).get();
      context.info('[SimpleLexicalIndexer] validation completed successfully');
    } catch (error) {
      context.error('[SimpleLexicalIndexer] validation failed: $error');
      throw StateError('SimpleLexicalIndexer validation failed: $error');
    }
  }
}
