import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/search/application/message_text_search_query.dart';
import 'package:remember_this_text/essentials/search/presentation/widgets/search_highlighted_text.dart';

const _highlightStyle = TextStyle(fontWeight: FontWeight.bold);

void main() {
  test('prefix highlights only the matching word-prefix portion', () {
    expect(
      _highlightedText(
        text: 'post posting postmaster crosspost',
        query: 'post',
      ),
      ['post', 'post', 'post'],
    );
  });

  test('exact token highlights punctuation-delimited forms only', () {
    expect(
      _highlightedText(
        text:
            'post post. (post) post? post-master posting postmaster crosspost',
        query: 'post ',
      ),
      ['post', 'post', 'post', 'post', 'post'],
    );
  });

  test('multiple tokens retain independent exact and prefix semantics', () {
    expect(
      _highlightedText(
        text: 'Bass player and bassoon planning',
        query: 'bass pl',
      ),
      ['Bass', 'pl', 'pl'],
    );
  });

  test('matching is case-insensitive', () {
    expect(_highlightedText(text: 'POST Postmaster crossPOST', query: 'post'), [
      'POST',
      'Post',
    ]);
  });

  test('hyphens and apostrophes follow punctuation token boundaries', () {
    expect(_highlightedText(text: "post-master post's", query: 'post '), [
      'post',
      'post',
    ]);
    expect(_highlightedText(text: "can't cannot", query: "can't "), ["can't"]);
  });

  test('common Latin diacritics follow unicode61-style folding', () {
    expect(_highlightedText(text: 'CAFÉ Caféine', query: 'cafe '), ['CAFÉ']);
    expect(_highlightedText(text: 'Caféine', query: 'cafe'), ['Café']);
    expect(_highlightedText(text: 'ộ', query: 'o '), ['ộ']);
  });

  test('does not transliterate outside the maintained Latin fold table', () {
    expect(_highlightedText(text: 'smørrebrød', query: 'smor'), isEmpty);
  });

  test('documents the uncommon precomposed-diacritic approximation limit', () {
    // SQLite unicode61 with remove_diacritics=2 folds ṩ to s. The synchronous
    // Dart highlighter intentionally limits folding to its maintained common
    // Latin table, so this uncommon form can match FTS without being marked.
    expect(_highlightedText(text: 'ṩ', query: 's '), isEmpty);
  });

  testWidgets('renders rich highlighted text', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: SearchHighlightedText(
            text: 'posting crosspost',
            query: 'post',
          ),
        ),
      ),
    );

    expect(find.text('posting crosspost', findRichText: true), findsOneWidget);
  });
}

List<String?> _highlightedText({required String text, required String query}) {
  final intent = MessageTextSearchQuery.parse(query).executionIntent;
  final spans = buildSearchHighlightSpans(
    text: text,
    intent: intent,
    highlightStyle: _highlightStyle,
  );
  return [
    for (final span in spans)
      if (span.style == _highlightStyle) span.text,
  ];
}
