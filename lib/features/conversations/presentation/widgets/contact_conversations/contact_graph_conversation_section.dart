import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../../../application/contact_conversations/contact_conversation_navigation_actions_provider.dart';
import '../../../application/contact_conversations/contact_conversation_signatures_provider.dart';
import '../../../application/conversation_signatures/conversation_signature_display_provider.dart'
    show
        ConversationSignatureDisplayModel,
        conversationSignatureIdsWithDuplicateChatHooks;
import '../conversation_favourite_button.dart';
import '../conversation_signature_card.dart';
import '../conversation_signature_card_presentation.dart';

class ContactGraphConversationSection extends ConsumerWidget {
  const ContactGraphConversationSection({
    required this.contactId,
    required this.selectedConversationId,
    this.padding = const EdgeInsets.fromLTRB(20, 0, 20, 12),
    this.maxHeight = 220,
    super.key,
  });

  final int contactId;
  final int? selectedConversationId;
  final EdgeInsetsGeometry padding;
  final double maxHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signaturesAsync = ref.watch(
      contactConversationSignaturesProvider(contactId: contactId),
    );

    return signaturesAsync.when(
      data: (signatureDisplays) {
        if (signatureDisplays.isEmpty) {
          return _ContactGraphConversationNotice(
            padding: padding,
            title: 'No conversations found',
            message:
                'The graph has no conversation edges for this contact yet.',
          );
        }

        return _ContactGraphConversationContent(
          contactId: contactId,
          selectedConversationId: selectedConversationId,
          signatureDisplays: signatureDisplays,
          padding: padding,
          maxHeight: maxHeight,
        );
      },
      loading: () => _ContactGraphConversationNotice(
        padding: padding,
        title: 'Loading conversations',
        message: 'Reading the source-scoped conversation graph.',
      ),
      error: (error, _) => _ContactGraphConversationNotice(
        padding: padding,
        title: 'Unable to load conversations',
        message: '$error',
      ),
    );
  }
}

class _ContactGraphConversationNotice extends ConsumerWidget {
  const _ContactGraphConversationNotice({
    required this.padding,
    required this.title,
    required this.message,
  });

  final EdgeInsetsGeometry padding;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return Padding(
      padding: padding,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.messagePanels.supportSurface,
          border: Border.all(color: colors.messagePanels.cardBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: typography.headline),
              const SizedBox(height: 4),
              Text(message, style: typography.caption1),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactGraphConversationContent extends ConsumerStatefulWidget {
  const _ContactGraphConversationContent({
    required this.contactId,
    required this.selectedConversationId,
    required this.signatureDisplays,
    required this.padding,
    required this.maxHeight,
  });

  final int contactId;
  final int? selectedConversationId;
  final List<ConversationSignatureDisplayModel> signatureDisplays;
  final EdgeInsetsGeometry padding;
  final double maxHeight;

  @override
  ConsumerState<_ContactGraphConversationContent> createState() =>
      _ContactGraphConversationContentState();
}

class _ContactGraphConversationContentState
    extends ConsumerState<_ContactGraphConversationContent> {
  @override
  Widget build(BuildContext context) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final cardStyle = conversationSignatureCardStyle(colors, typography);
    final signatureDisplays = widget.signatureDisplays;
    final conversationIdsWithChatHooks =
        conversationSignatureIdsWithDuplicateChatHooks(signatureDisplays);

    return Padding(
      padding: widget.padding,
      child: SizedBox(
        width: double.infinity,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: widget.maxHeight),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: signatureDisplays.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final signature = signatureDisplays[index];
              return ConversationSignatureCard(
                key: ValueKey<int>(signature.conversationId),
                signature: conversationSignatureCardDataFromDisplay(
                  signature,
                  includeChatHook: conversationIdsWithChatHooks.contains(
                    signature.conversationId,
                  ),
                ),
                style: cardStyle,
                monthColorForMessageCount:
                    conversationSignatureMonthColorForMessageCount,
                isSelected:
                    signature.conversationId == widget.selectedConversationId,
                onMonthTap: (year, month, _) {
                  unawaited(
                    ref
                        .read(
                          contactConversationNavigationActionsProvider.notifier,
                        )
                        .selectContactConversationMonth(
                          contactId: widget.contactId,
                          conversationId: signature.conversationId,
                          monthAnchor: DateTime(year, month),
                        ),
                  );
                },
                trailing: ConversationFavouriteButton(
                  conversationId: signature.conversationId,
                ),
                onPressed: () {
                  unawaited(
                    ref
                        .read(
                          contactConversationNavigationActionsProvider.notifier,
                        )
                        .selectContactConversation(
                          contactId: widget.contactId,
                          conversationId: signature.conversationId,
                        ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
