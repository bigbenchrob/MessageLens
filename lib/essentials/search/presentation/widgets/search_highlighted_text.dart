import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../application/message_text_search_matching.dart';
import '../../application/message_text_search_query.dart';

class SearchHighlightedText extends ConsumerWidget {
  const SearchHighlightedText({
    super.key,
    required this.text,
    required this.query,
    this.style,
    this.highlightStyle,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final String query;
  final TextStyle? style;
  final TextStyle? highlightStyle;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final effectiveStyle = style ?? DefaultTextStyle.of(context).style;
    final intent = MessageTextSearchQuery.parse(query).executionIntent;
    if (intent.tokens.isEmpty) {
      return Text(
        text,
        style: effectiveStyle,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    return Text.rich(
      TextSpan(
        style: effectiveStyle,
        children: buildSearchHighlightSpans(
          text: text,
          intent: intent,
          highlightStyle:
              highlightStyle ??
              effectiveStyle.copyWith(
                backgroundColor: colors.messagePanels.accentTint,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

@visibleForTesting
List<TextSpan> buildSearchHighlightSpans({
  required String text,
  required MessageTextSearchExecutionIntent intent,
  required TextStyle highlightStyle,
}) {
  final matches = messageTextSearchHighlightMatches(text: text, intent: intent);
  if (matches.isEmpty) {
    return [TextSpan(text: text)];
  }

  final spans = <TextSpan>[];
  var cursor = 0;
  for (final match in matches) {
    if (match.start > cursor) {
      spans.add(TextSpan(text: text.substring(cursor, match.start)));
    }

    spans.add(
      TextSpan(
        text: text.substring(match.start, match.end),
        style: highlightStyle,
      ),
    );
    cursor = match.end;
  }
  if (cursor < text.length) {
    spans.add(TextSpan(text: text.substring(cursor)));
  }
  return spans;
}
