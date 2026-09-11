import 'package:meta/meta.dart';

/// Parsed message-text search intent derived from an unchanged user input.
@immutable
final class MessageTextSearchQuery {
  MessageTextSearchQuery._({
    required this.rawInput,
    required List<MessageTextSearchToken> tokens,
    required this.hasTrailingWhitespace,
    required this.filterSaved,
  }) : tokens = List<MessageTextSearchToken>.unmodifiable(tokens),
       executionIntent = MessageTextSearchExecutionIntent._(
         tokens: tokens,
         filterSaved: filterSaved,
       );

  factory MessageTextSearchQuery.parse(String rawInput) {
    final tokens = <MessageTextSearchToken>[];
    var filterSaved = false;

    for (final match in RegExp(r'\S+').allMatches(rawInput)) {
      final rawToken = match.group(0);
      if (rawToken == null) {
        continue;
      }

      final normalizedText = rawToken.toLowerCase();
      if (normalizedText == 'is:saved') {
        filterSaved = true;
        continue;
      }

      final isComplete = match.end < rawInput.length;
      if (isComplete) {
        tokens.add(ExactMessageTextSearchToken(normalizedText));
        continue;
      }

      if (normalizedText.runes.length >= 2) {
        tokens.add(PrefixMessageTextSearchToken(normalizedText));
      }
    }

    return MessageTextSearchQuery._(
      rawInput: rawInput,
      tokens: tokens,
      hasTrailingWhitespace:
          rawInput.isNotEmpty && rawInput != rawInput.trimRight(),
      filterSaved: filterSaved,
    );
  }

  /// The input exactly as supplied by the editable search field.
  final String rawInput;

  /// Executable text-search tokens in their original order.
  final List<MessageTextSearchToken> tokens;

  /// Whether whitespace at the end of [rawInput] completed its final token.
  final bool hasTrailingWhitespace;

  /// Whether the existing `is:saved` operator was present in [rawInput].
  final bool filterSaved;

  /// Stable search semantics, independent of editor-only whitespace choices.
  final MessageTextSearchExecutionIntent executionIntent;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MessageTextSearchQuery &&
            other.rawInput == rawInput &&
            _tokensEqual(other.tokens, tokens) &&
            other.hasTrailingWhitespace == hasTrailingWhitespace &&
            other.filterSaved == filterSaved;
  }

  @override
  int get hashCode => Object.hash(
    rawInput,
    Object.hashAll(tokens),
    hasTrailingWhitespace,
    filterSaved,
  );
}

/// Cache-safe search identity derived only from parsed execution semantics.
///
/// Raw input remains owned by [MessageTextSearchQuery]. Two visibly different
/// editor strings may therefore share this value when they execute the same
/// search, while exact and prefix forms always remain distinct.
@immutable
final class MessageTextSearchExecutionIntent {
  MessageTextSearchExecutionIntent._({
    required List<MessageTextSearchToken> tokens,
    required this.filterSaved,
  }) : tokens = List<MessageTextSearchToken>.unmodifiable(tokens);

  final List<MessageTextSearchToken> tokens;
  final bool filterSaved;

  bool get isExecutable => tokens.isNotEmpty || filterSaved;

  String get stableKey {
    final parts = <String>[];
    if (filterSaved) {
      parts.add('saved:1');
    } else {
      parts.add('saved:0');
    }
    for (final token in tokens) {
      final kind = token is PrefixMessageTextSearchToken ? 'prefix' : 'exact';
      parts.add('$kind:${token.normalizedText.length}:${token.normalizedText}');
    }
    return parts.join('|');
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MessageTextSearchExecutionIntent &&
            _tokensEqual(other.tokens, tokens) &&
            other.filterSaved == filterSaved;
  }

  @override
  int get hashCode => Object.hash(Object.hashAll(tokens), filterSaved);
}

@immutable
sealed class MessageTextSearchToken {
  const MessageTextSearchToken(this.normalizedText);

  /// Lowercased query text. Document tokenization remains backend-owned.
  final String normalizedText;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other.runtimeType == runtimeType &&
            other is MessageTextSearchToken &&
            other.normalizedText == normalizedText;
  }

  @override
  int get hashCode => Object.hash(runtimeType, normalizedText);
}

/// A token explicitly completed by following whitespace.
final class ExactMessageTextSearchToken extends MessageTextSearchToken {
  const ExactMessageTextSearchToken(super.normalizedText);
}

/// The word-initial prefix currently being typed.
final class PrefixMessageTextSearchToken extends MessageTextSearchToken {
  const PrefixMessageTextSearchToken(super.normalizedText);
}

bool _tokensEqual(
  List<MessageTextSearchToken> left,
  List<MessageTextSearchToken> right,
) {
  if (left.length != right.length) {
    return false;
  }
  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) {
      return false;
    }
  }
  return true;
}
