import 'package:meta/meta.dart';

import 'message_text_search_query.dart';

/// A UTF-16 source range that should receive search-match emphasis.
@immutable
final class MessageTextSearchMatch {
  const MessageTextSearchMatch({required this.start, required this.end});

  final int start;
  final int end;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MessageTextSearchMatch &&
            other.start == start &&
            other.end == end;
  }

  @override
  int get hashCode => Object.hash(start, end);
}

/// Finds display spans using the exact/prefix intent sent to FTS5.
///
/// SQLite's unicode61 tokenizer is not available in Dart. This uses Unicode
/// letter, number, mark, and private-use categories as the narrowest practical
/// approximation, with the common Latin diacritic folding used by unicode61.
List<MessageTextSearchMatch> messageTextSearchHighlightMatches({
  required String text,
  required MessageTextSearchExecutionIntent intent,
}) {
  if (text.isEmpty || intent.tokens.isEmpty) {
    return const <MessageTextSearchMatch>[];
  }

  final documentTokens = _tokenize(text);
  if (documentTokens.isEmpty) {
    return const <MessageTextSearchMatch>[];
  }

  final matches = <MessageTextSearchMatch>[];
  for (final searchToken in intent.tokens) {
    matches.addAll(
      _matchesForSearchToken(
        documentTokens: documentTokens,
        searchToken: searchToken,
      ),
    );
  }
  if (matches.isEmpty) {
    return const <MessageTextSearchMatch>[];
  }

  matches.sort((left, right) {
    final byStart = left.start.compareTo(right.start);
    return byStart != 0 ? byStart : right.end.compareTo(left.end);
  });

  final nonOverlapping = <MessageTextSearchMatch>[];
  for (final match in matches) {
    if (nonOverlapping.isEmpty || match.start >= nonOverlapping.last.end) {
      nonOverlapping.add(match);
      continue;
    }
    if (match.end > nonOverlapping.last.end) {
      final previous = nonOverlapping.removeLast();
      nonOverlapping.add(
        MessageTextSearchMatch(start: previous.start, end: match.end),
      );
    }
  }
  return List<MessageTextSearchMatch>.unmodifiable(nonOverlapping);
}

bool messageTextMatchesSearchIntent({
  required String text,
  required MessageTextSearchExecutionIntent intent,
  required bool matchAnyTerm,
}) {
  if (intent.tokens.isEmpty) {
    return false;
  }

  final documentTokens = _tokenize(text);
  if (documentTokens.isEmpty) {
    return false;
  }

  bool matches(MessageTextSearchToken searchToken) {
    return _matchesForSearchToken(
      documentTokens: documentTokens,
      searchToken: searchToken,
    ).isNotEmpty;
  }

  return matchAnyTerm
      ? intent.tokens.any(matches)
      : intent.tokens.every(matches);
}

List<MessageTextSearchMatch> _matchesForSearchToken({
  required List<_SearchDocumentToken> documentTokens,
  required MessageTextSearchToken searchToken,
}) {
  final queryTokens = _tokenize(searchToken.normalizedText);
  if (queryTokens.isEmpty || queryTokens.length > documentTokens.length) {
    return const <MessageTextSearchMatch>[];
  }

  final matches = <MessageTextSearchMatch>[];
  final finalQueryIndex = queryTokens.length - 1;
  for (
    var documentStart = 0;
    documentStart <= documentTokens.length - queryTokens.length;
    documentStart++
  ) {
    var isMatch = true;
    for (var queryIndex = 0; queryIndex < queryTokens.length; queryIndex++) {
      final documentToken = documentTokens[documentStart + queryIndex];
      final queryToken = queryTokens[queryIndex];
      final isPrefixComponent =
          searchToken is PrefixMessageTextSearchToken &&
          queryIndex == finalQueryIndex;
      final componentMatches = isPrefixComponent
          ? documentToken.normalizedText.startsWith(queryToken.normalizedText)
          : documentToken.normalizedText == queryToken.normalizedText;
      if (!componentMatches) {
        isMatch = false;
        break;
      }
    }
    if (!isMatch) {
      continue;
    }

    final firstDocumentToken = documentTokens[documentStart];
    final lastDocumentToken = documentTokens[documentStart + finalQueryIndex];
    final end = searchToken is PrefixMessageTextSearchToken
        ? lastDocumentToken.sourceEndForPrefixLength(
            queryTokens.last.normalizedText.length,
          )
        : lastDocumentToken.end;
    matches.add(
      MessageTextSearchMatch(start: firstDocumentToken.start, end: end),
    );
  }
  return matches;
}

final RegExp _unicode61Approximation = RegExp(
  r'[\p{L}\p{N}\p{M}\p{Co}]+',
  unicode: true,
);
final RegExp _combiningMark = RegExp(r'^\p{M}$', unicode: true);

List<_SearchDocumentToken> _tokenize(String text) {
  final tokens = <_SearchDocumentToken>[];
  for (final match in _unicode61Approximation.allMatches(text)) {
    final token = _SearchDocumentToken.fromMatch(match);
    if (token.normalizedText.isNotEmpty) {
      tokens.add(token);
    }
  }
  return tokens;
}

final class _SearchDocumentToken {
  _SearchDocumentToken({
    required this.start,
    required this.end,
    required this.normalizedText,
    required this.normalizedCodeUnitEnds,
  });

  factory _SearchDocumentToken.fromMatch(RegExpMatch match) {
    final source = match.group(0) ?? '';
    final normalized = StringBuffer();
    final normalizedCodeUnitEnds = <int>[];
    var sourceOffset = match.start;

    for (final rune in source.runes) {
      final sourceCharacter = String.fromCharCode(rune);
      sourceOffset += sourceCharacter.length;
      final folded = _foldSearchCharacter(sourceCharacter);
      normalized.write(folded);
      for (var index = 0; index < folded.length; index++) {
        normalizedCodeUnitEnds.add(sourceOffset);
      }
    }

    return _SearchDocumentToken(
      start: match.start,
      end: match.end,
      normalizedText: normalized.toString(),
      normalizedCodeUnitEnds: normalizedCodeUnitEnds,
    );
  }

  final int start;
  final int end;
  final String normalizedText;
  final List<int> normalizedCodeUnitEnds;

  int sourceEndForPrefixLength(int normalizedLength) {
    if (normalizedCodeUnitEnds.isEmpty || normalizedLength <= 0) {
      return start;
    }
    final index = normalizedLength >= normalizedCodeUnitEnds.length
        ? normalizedCodeUnitEnds.length - 1
        : normalizedLength - 1;
    return normalizedCodeUnitEnds[index];
  }
}

String _foldSearchCharacter(String character) {
  if (_combiningMark.hasMatch(character)) {
    return '';
  }
  final lower = character.toLowerCase();
  final folded = StringBuffer();
  for (final rune in lower.runes) {
    final lowerCharacter = String.fromCharCode(rune);
    if (_combiningMark.hasMatch(lowerCharacter)) {
      continue;
    }
    folded.write(_commonLatinDiacriticFold[lowerCharacter] ?? lowerCharacter);
  }
  return folded.toString();
}

final Map<String, String> _commonLatinDiacriticFold = _buildLatinFoldMap();

Map<String, String> _buildLatinFoldMap() {
  const groups = <String, String>{
    'a': 'àáâãäåāăąǎạảấầẩẫậắằẳẵặ',
    'c': 'çćĉċč',
    'd': 'ďđ',
    'e': 'èéêëēĕėęěẹẻẽếềểễệ',
    'g': 'ĝğġģ',
    'h': 'ĥħ',
    'i': 'ìíîïĩīĭįıǐịỉ',
    'j': 'ĵ',
    'k': 'ķ',
    'l': 'ĺļľŀł',
    'n': 'ñńņňŉŋ',
    'o': 'òóôõöōŏőǒọỏốồổỗộớờởỡợ',
    'r': 'ŕŗř',
    's': 'śŝşš',
    't': 'ţťŧ',
    'u': 'ùúûüũūŭůűųǔụủứừửữự',
    'w': 'ŵ',
    'y': 'ýÿŷỳỵỷỹ',
    'z': 'źżž',
  };
  return <String, String>{
    for (final entry in groups.entries)
      for (final rune in entry.value.runes)
        String.fromCharCode(rune): entry.key,
  };
}
