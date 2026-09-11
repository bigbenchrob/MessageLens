import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/search/application/message_text_search_query.dart';

void main() {
  group('MessageTextSearchQuery', () {
    test('preserves empty input and produces no text tokens', () {
      final query = MessageTextSearchQuery.parse('');

      expect(query.rawInput, '');
      expect(query.tokens, isEmpty);
      expect(query.hasTrailingWhitespace, isFalse);
      expect(query.filterSaved, isFalse);
    });

    test('preserves whitespace-only input and produces no text tokens', () {
      const rawInput = '   ';
      final query = MessageTextSearchQuery.parse(rawInput);

      expect(query.rawInput, rawInput);
      expect(query.tokens, isEmpty);
      expect(query.hasTrailingWhitespace, isTrue);
    });

    test('ignores an unfinished one-character prefix', () {
      final query = MessageTextSearchQuery.parse('p');

      expect(query.tokens, isEmpty);
      expect(query.rawInput, 'p');
    });

    test('parses a completed one-character token as exact', () {
      final query = MessageTextSearchQuery.parse('p ');

      expect(query.tokens, const [ExactMessageTextSearchToken('p')]);
    });

    test('parses unfinished tokens of two or more characters as prefixes', () {
      expect(MessageTextSearchQuery.parse('po').tokens, const [
        PrefixMessageTextSearchToken('po'),
      ]);
      expect(MessageTextSearchQuery.parse('post').tokens, const [
        PrefixMessageTextSearchToken('post'),
      ]);
    });

    test('parses a whitespace-completed token as exact', () {
      final query = MessageTextSearchQuery.parse('post ');

      expect(query.tokens, const [ExactMessageTextSearchToken('post')]);
      expect(query.hasTrailingWhitespace, isTrue);
    });

    test('parses complete and active tokens independently', () {
      expect(MessageTextSearchQuery.parse('bass pl').tokens, const [
        ExactMessageTextSearchToken('bass'),
        PrefixMessageTextSearchToken('pl'),
      ]);
      expect(MessageTextSearchQuery.parse('bass player ').tokens, const [
        ExactMessageTextSearchToken('bass'),
        ExactMessageTextSearchToken('player'),
      ]);
    });

    test('preserves repeated spaces without changing token semantics', () {
      const rawInput = 'bass   pl';
      final query = MessageTextSearchQuery.parse(rawInput);

      expect(query.rawInput, rawInput);
      expect(query.tokens, const [
        ExactMessageTextSearchToken('bass'),
        PrefixMessageTextSearchToken('pl'),
      ]);
    });

    test('leading whitespace does not complete the first token', () {
      final query = MessageTextSearchQuery.parse('  post');

      expect(query.tokens, const [PrefixMessageTextSearchToken('post')]);
    });

    test('tabs and newlines complete preceding tokens', () {
      expect(MessageTextSearchQuery.parse('bass\tpl').tokens, const [
        ExactMessageTextSearchToken('bass'),
        PrefixMessageTextSearchToken('pl'),
      ]);
      expect(MessageTextSearchQuery.parse('bass\nplayer').tokens, const [
        ExactMessageTextSearchToken('bass'),
        PrefixMessageTextSearchToken('player'),
      ]);
    });

    test('a final tab or newline completes the final token', () {
      for (final rawInput in ['post\t', 'post\n']) {
        final query = MessageTextSearchQuery.parse(rawInput);

        expect(query.tokens, const [ExactMessageTextSearchToken('post')]);
        expect(query.hasTrailingWhitespace, isTrue);
      }
    });

    test('lowercases tokens without folding diacritics or punctuation', () {
      final query = MessageTextSearchQuery.parse('CAFÉ Re-Post');

      expect(query.tokens, const [
        ExactMessageTextSearchToken('café'),
        PrefixMessageTextSearchToken('re-post'),
      ]);
    });

    test('keeps one-character tokens when they are non-final', () {
      final query = MessageTextSearchQuery.parse('p value');

      expect(query.tokens, const [
        ExactMessageTextSearchToken('p'),
        PrefixMessageTextSearchToken('value'),
      ]);
    });

    test('extracts is:saved structurally in any token position', () {
      final savedOnly = MessageTextSearchQuery.parse('is:saved');
      final leading = MessageTextSearchQuery.parse('is:saved invoice');
      final trailing = MessageTextSearchQuery.parse('invoice is:saved');
      final middle = MessageTextSearchQuery.parse('invoice is:saved paid');

      expect(savedOnly.filterSaved, isTrue);
      expect(savedOnly.tokens, isEmpty);
      expect(leading.filterSaved, isTrue);
      expect(leading.tokens, const [PrefixMessageTextSearchToken('invoice')]);
      expect(trailing.filterSaved, isTrue);
      expect(trailing.tokens, const [ExactMessageTextSearchToken('invoice')]);
      expect(middle.filterSaved, isTrue);
      expect(middle.tokens, const [
        ExactMessageTextSearchToken('invoice'),
        PrefixMessageTextSearchToken('paid'),
      ]);
    });

    test('extracts is:saved case-insensitively without mutating input', () {
      const rawInput = 'Invoice IS:SAVED ';
      final query = MessageTextSearchQuery.parse(rawInput);

      expect(query.rawInput, rawInput);
      expect(query.filterSaved, isTrue);
      expect(query.tokens, const [ExactMessageTextSearchToken('invoice')]);
    });

    test('keeps FTS-special punctuation as ordinary token text', () {
      const rawInput = '"quote" star* -dash (group) key:value';
      final query = MessageTextSearchQuery.parse(rawInput);

      expect(query.tokens, const [
        ExactMessageTextSearchToken('"quote"'),
        ExactMessageTextSearchToken('star*'),
        ExactMessageTextSearchToken('-dash'),
        ExactMessageTextSearchToken('(group)'),
        PrefixMessageTextSearchToken('key:value'),
      ]);
      expect(query.filterSaved, isFalse);
    });

    test('post and completed post have distinct value semantics', () {
      final active = MessageTextSearchQuery.parse('post');
      final completed = MessageTextSearchQuery.parse('post ');

      expect(active, isNot(completed));
      expect(active.hashCode, isNot(completed.hashCode));
      expect(active.tokens, const [PrefixMessageTextSearchToken('post')]);
      expect(completed.tokens, const [ExactMessageTextSearchToken('post')]);
      expect(active.executionIntent, isNot(completed.executionIntent));
      expect(
        active.executionIntent.stableKey,
        isNot(completed.executionIntent.stableKey),
      );
    });

    test('raw spacing is excluded from equivalent execution identity', () {
      final first = MessageTextSearchQuery.parse('  post ');
      final second = MessageTextSearchQuery.parse('post    ');

      expect(first.rawInput, isNot(second.rawInput));
      expect(first, isNot(second));
      expect(first.executionIntent, second.executionIntent);
      expect(first.executionIntent.stableKey, second.executionIntent.stableKey);
    });

    test('p and completed p have distinct executable behavior', () {
      final active = MessageTextSearchQuery.parse('p');
      final completed = MessageTextSearchQuery.parse('p ');

      expect(active.executionIntent.isExecutable, isFalse);
      expect(completed.executionIntent.isExecutable, isTrue);
      expect(active.executionIntent, isNot(completed.executionIntent));
    });

    test('equivalent parsed queries have value equality', () {
      final first = MessageTextSearchQuery.parse('Bass pl');
      final second = MessageTextSearchQuery.parse('Bass pl');

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('exposes an immutable token list', () {
      final query = MessageTextSearchQuery.parse('bass pl');

      expect(
        () => query.tokens.add(const PrefixMessageTextSearchToken('extra')),
        throwsUnsupportedError,
      );
    });
  });
}
