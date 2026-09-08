import 'package:flutter/widgets.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../config/theme/widgets/heatmap/activity_heatmap_color_scale.dart';
import '../../application/conversation_signatures/conversation_signature_display_provider.dart';
import 'conversation_signature_card.dart';

ConversationSignatureCardData conversationSignatureCardDataFromDisplay(
  ConversationSignatureDisplayModel signature, {
  String? titleContextLabel,
  ConversationSignatureSummaryHighlight summaryHighlight =
      ConversationSignatureSummaryHighlight.none,
  ConversationSignatureMonthMarker? highlightedMonth,
  bool includeTags = false,
  bool includeChatHook = false,
}) {
  return ConversationSignatureCardData(
    conversationId: signature.conversationId,
    title: signature.title,
    chatHookLabel: includeChatHook ? signature.chatHookLabel : null,
    titleContextLabel: titleContextLabel,
    summaryHighlight: summaryHighlight,
    highlightedMonth: highlightedMonth,
    participantCount: signature.participantCount,
    messageCount: signature.messageCount,
    firstMessageAtUtc: signature.firstMessageAtUtc,
    lastMessageAtUtc: signature.lastMessageAtUtc,
    activityMonths: signature.activityMonths,
    tagLabels: includeTags
        ? [for (final tag in signature.tags) tag.displayName]
        : const <String>[],
  );
}

Color conversationSignatureMonthColorForMessageCount(int messageCount) {
  return activityHeatmapColorForMessageCount(messageCount);
}

ConversationSignatureCardStyle conversationSignatureCardStyle(
  ThemeColors colors,
  ThemeTypography typography,
) {
  return ConversationSignatureCardStyle(
    backgroundColor: colors.surfaces.surface.withValues(alpha: 0.14),
    hoverBackgroundColor: colors.surfaces.hover,
    selectedBackgroundColor: colors.surfaces.selectedRegion,
    borderColor: colors.lines.borderSubtle.withValues(alpha: 0),
    hoverBorderColor: colors.lines.borderSubtle.withValues(alpha: 0.38),
    selectedBorderColor: colors.accents.selection.withValues(alpha: 0.58),
    titleStyle: typography.callout.copyWith(
      color: colors.content.textPrimary,
      fontWeight: FontWeight.w600,
    ),
    selectedTitleStyle: typography.callout.copyWith(
      color: colors.content.textPrimary,
      fontWeight: FontWeight.w600,
    ),
    titleContextStyle: typography.caption.copyWith(
      color: colors.status.warning.withValues(alpha: 0.82),
      fontWeight: FontWeight.w500,
    ),
    participantSuffixStyle: typography.caption.copyWith(
      color: colors.content.textTertiary.withValues(alpha: 0.68),
      fontWeight: FontWeight.w500,
    ),
    chatHookStyle: typography.caption.copyWith(
      color: colors.content.textPrimary.withValues(alpha: 0.72),
      fontWeight: FontWeight.w400,
    ),
    summaryStyle: typography.caption.copyWith(
      color: colors.content.textTertiary.withValues(alpha: 0.78),
    ),
    summaryHighlightStyle: typography.caption.copyWith(
      color: colors.status.warning.withValues(alpha: 0.9),
      fontWeight: FontWeight.w700,
    ),
    monthHighlightColor: colors.status.warning,
    tagTextStyle: typography.caption.copyWith(
      color: colors.content.textSecondary.withValues(alpha: 0.9),
      fontWeight: FontWeight.w500,
    ),
    tagBackgroundColor: colors.surfaces.surface.withValues(alpha: 0.32),
    tagBorderColor: colors.lines.borderSubtle.withValues(alpha: 0.26),
    emptyMonthBorderColor: colors.lines.borderSubtle,
  );
}

ConversationSignatureCardStyle favouriteConversationSignatureCardStyle(
  ThemeColors colors,
  ThemeTypography typography,
) {
  return ConversationSignatureCardStyle(
    backgroundColor: colors.surfaces.surface.withValues(alpha: 0.38),
    hoverBackgroundColor: colors.surfaces.hover,
    selectedBackgroundColor: colors.surfaces.selectedRegion,
    borderColor: colors.lines.borderSubtle.withValues(alpha: 0.18),
    hoverBorderColor: colors.lines.borderSubtle.withValues(alpha: 0.42),
    selectedBorderColor: colors.accents.selection.withValues(alpha: 0.6),
    titleStyle: typography.callout.copyWith(
      color: colors.content.textPrimary,
      fontWeight: FontWeight.w600,
    ),
    selectedTitleStyle: typography.callout.copyWith(
      color: colors.content.textPrimary,
      fontWeight: FontWeight.w700,
    ),
    titleContextStyle: typography.caption.copyWith(
      color: colors.status.warning.withValues(alpha: 0.82),
      fontWeight: FontWeight.w500,
    ),
    participantSuffixStyle: typography.caption.copyWith(
      color: colors.content.textTertiary.withValues(alpha: 0.72),
      fontWeight: FontWeight.w500,
    ),
    chatHookStyle: typography.caption.copyWith(
      color: colors.content.textPrimary.withValues(alpha: 0.74),
      fontWeight: FontWeight.w400,
    ),
    summaryStyle: typography.caption.copyWith(
      color: colors.content.textTertiary.withValues(alpha: 0.8),
    ),
    summaryHighlightStyle: typography.caption.copyWith(
      color: colors.status.warning.withValues(alpha: 0.9),
      fontWeight: FontWeight.w700,
    ),
    monthHighlightColor: colors.status.warning,
    tagTextStyle: typography.caption.copyWith(
      color: colors.content.textSecondary.withValues(alpha: 0.92),
      fontWeight: FontWeight.w500,
    ),
    tagBackgroundColor: colors.surfaces.surface.withValues(alpha: 0.38),
    tagBorderColor: colors.lines.borderSubtle.withValues(alpha: 0.28),
    emptyMonthBorderColor: colors.lines.borderSubtle,
  );
}

ConversationSignatureCardStyle conversationSignatureContextHeaderCardStyle(
  ThemeColors colors,
  ThemeTypography typography,
) {
  return ConversationSignatureCardStyle(
    backgroundColor: colors.surfaces.surface.withValues(alpha: 0.08),
    hoverBackgroundColor: colors.surfaces.surface.withValues(alpha: 0.08),
    selectedBackgroundColor: colors.surfaces.selected.withValues(alpha: 0.38),
    borderColor: colors.lines.borderSubtle.withValues(alpha: 0),
    hoverBorderColor: colors.lines.borderSubtle.withValues(alpha: 0),
    selectedBorderColor: colors.accents.selection.withValues(alpha: 0.38),
    titleStyle: typography.callout.copyWith(
      color: colors.content.textPrimary,
      fontWeight: FontWeight.w600,
    ),
    selectedTitleStyle: typography.callout.copyWith(
      color: colors.content.textPrimary,
      fontWeight: FontWeight.w600,
    ),
    titleContextStyle: typography.caption.copyWith(
      color: colors.status.warning.withValues(alpha: 0.72),
      fontWeight: FontWeight.w500,
    ),
    participantSuffixStyle: typography.caption.copyWith(
      color: colors.content.textTertiary.withValues(alpha: 0.58),
      fontWeight: FontWeight.w500,
    ),
    chatHookStyle: typography.caption.copyWith(
      color: colors.content.textPrimary.withValues(alpha: 0.68),
      fontWeight: FontWeight.w400,
    ),
    summaryStyle: typography.caption.copyWith(
      color: colors.content.textTertiary.withValues(alpha: 0.68),
    ),
    summaryHighlightStyle: typography.caption.copyWith(
      color: colors.status.warning.withValues(alpha: 0.82),
      fontWeight: FontWeight.w700,
    ),
    monthHighlightColor: colors.status.warning,
    tagTextStyle: typography.caption.copyWith(
      color: colors.content.textSecondary.withValues(alpha: 0.82),
      fontWeight: FontWeight.w500,
    ),
    tagBackgroundColor: colors.surfaces.surface.withValues(alpha: 0.2),
    tagBorderColor: colors.lines.borderSubtle.withValues(alpha: 0.2),
    emptyMonthBorderColor: colors.lines.borderSubtle.withValues(alpha: 0.82),
  );
}
