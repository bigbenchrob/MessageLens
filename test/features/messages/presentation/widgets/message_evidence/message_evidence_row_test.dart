import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:remember_this_text/essentials/debug/application/developer_mode_provider.dart';
import 'package:remember_this_text/features/messages/domain/message_evidence/message_evidence_row_data.dart';
import 'package:remember_this_text/features/messages/domain/message_evidence/message_evidence_scope.dart';
import 'package:remember_this_text/features/messages/presentation/widgets/message_evidence/message_evidence_row.dart';

void main() {
  testWidgets('hides raw handle metadata for normal conversation evidence', (
    tester,
  ) async {
    await _pumpRow(
      tester,
      developerMode: DeveloperModeValue.user,
      scope: const ConversationEvidenceScope(conversationId: 42),
      message: _message(),
    );

    expect(find.textContaining('received from Claire'), findsOneWidget);
    expect(find.textContaining('handle: 1 (778) 990-8506'), findsNothing);
  });

  testWidgets('shows raw handle metadata for explicit handle evidence', (
    tester,
  ) async {
    await _pumpRow(
      tester,
      developerMode: DeveloperModeValue.user,
      scope: const HandleMessagesEvidenceScope(handleId: 7),
      message: _message(),
    );

    expect(find.textContaining('received from Claire'), findsOneWidget);
    expect(find.textContaining('handle: 1 (778) 990-8506'), findsOneWidget);
  });

  testWidgets('shows raw handle metadata for developer diagnostics', (
    tester,
  ) async {
    await _pumpRow(
      tester,
      developerMode: DeveloperModeValue.developer,
      scope: const ConversationEvidenceScope(conversationId: 42),
      message: _message(),
    );

    expect(find.textContaining('received from Claire'), findsOneWidget);
    expect(find.textContaining('handle: 1 (778) 990-8506'), findsOneWidget);
  });

  testWidgets('does not render semantic provenance badges under messages', (
    tester,
  ) async {
    await _pumpRow(
      tester,
      developerMode: DeveloperModeValue.developer,
      scope: const ConversationEvidenceScope(conversationId: 42),
      message: _message(
        semanticKind: 'rich_text',
        itemKind: 'text',
        associatedMessageId: 123,
        hasAttributedBodySource: true,
        hasMessageSummaryInfo: true,
        errorCode: 0,
      ),
    );

    expect(find.text('hello'), findsOneWidget);
    expect(find.text('rich_text'), findsNothing);
    expect(find.text('text'), findsNothing);
    expect(find.text('associated 123'), findsNothing);
    expect(find.text('attributed body'), findsNothing);
    expect(find.text('summary info'), findsNothing);
    expect(find.text('error 0'), findsNothing);
  });

  testWidgets('names the conversation recipient for outgoing evidence', (
    tester,
  ) async {
    await _pumpRow(
      tester,
      developerMode: DeveloperModeValue.user,
      scope: const ConversationEvidenceScope(conversationId: 42),
      message: _message(isFromMe: true, conversationDisplayTitle: 'Claire'),
    );

    expect(find.textContaining('from me to Claire'), findsOneWidget);
    expect(find.textContaining('from me | me'), findsNothing);
  });

  testWidgets('labels incoming self-conversation evidence as self', (
    tester,
  ) async {
    await _pumpRow(
      tester,
      developerMode: DeveloperModeValue.user,
      scope: const ConversationEvidenceScope(conversationId: 42),
      message: _message(isSelfConversation: true),
    );

    expect(find.textContaining('self'), findsOneWidget);
    expect(find.textContaining('received from'), findsNothing);
  });

  testWidgets('labels outgoing self-conversation evidence as self', (
    tester,
  ) async {
    await _pumpRow(
      tester,
      developerMode: DeveloperModeValue.user,
      scope: const ConversationEvidenceScope(conversationId: 42),
      message: _message(isFromMe: true, isSelfConversation: true),
    );

    expect(find.textContaining('self'), findsOneWidget);
    expect(find.textContaining('from me to'), findsNothing);
  });

  testWidgets('uses lowercase me for a canonical self sender', (tester) async {
    await _pumpRow(
      tester,
      developerMode: DeveloperModeValue.user,
      scope: const RecoveredMessagesEvidenceScope(
        contactId: null,
        onlyNoHandleFromMe: false,
      ),
      message: _message(senderIsMe: true, senderDisplayHandle: 'me'),
    );

    expect(find.textContaining('received from me'), findsOneWidget);
    expect(find.textContaining('received from Me'), findsNothing);
  });

  testWidgets('renders conversation context action from explicit callback', (
    tester,
  ) async {
    var opened = false;
    await _pumpRow(
      tester,
      developerMode: DeveloperModeValue.user,
      scope: const MessageSearchEvidenceScope(query: 'hello'),
      message: _message(sourceConversationId: 99),
      onOpenConversationContext: () {
        opened = true;
      },
    );

    expect(find.text('In conversation'), findsOneWidget);

    await tester.tap(find.text('In conversation'));
    await tester.pump();

    expect(opened, isTrue);
  });

  testWidgets('hides conversation context action when callback is absent', (
    tester,
  ) async {
    await _pumpRow(
      tester,
      developerMode: DeveloperModeValue.user,
      scope: const MessageSearchEvidenceScope(query: 'hello'),
      message: _message(sourceConversationId: 99),
    );

    expect(find.text('In conversation'), findsNothing);
  });

  testWidgets('renders persistent correspondence chrome for anchor messages', (
    tester,
  ) async {
    await _pumpRow(
      tester,
      developerMode: DeveloperModeValue.user,
      scope: const MessageSearchEvidenceScope(query: 'hello'),
      message: _message(),
      isAnchorMessage: true,
    );

    final anchorDecorations = tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .map((box) => box.decoration)
        .whereType<BoxDecoration>()
        .where((decoration) {
          return decoration.border != null &&
              decoration.boxShadow != null &&
              decoration.color != null;
        })
        .toList(growable: false);

    expect(anchorDecorations, isNotEmpty);
  });

  testWidgets('message body highlighting uses structured token boundaries', (
    tester,
  ) async {
    await _pumpRow(
      tester,
      developerMode: DeveloperModeValue.user,
      scope: const MessageSearchEvidenceScope(query: 'post '),
      message: _message(text: 'post postmaster crosspost'),
      searchQuery: 'post ',
    );

    final selectableText = tester.widget<SelectableText>(
      find.byType(SelectableText),
    );
    final rootSpan = selectableText.textSpan!;
    final highlightedText = rootSpan.children!
        .whereType<TextSpan>()
        .where((span) {
          return span.style?.backgroundColor != null;
        })
        .map((span) {
          return span.text;
        })
        .toList(growable: false);

    expect(highlightedText, ['post']);
  });
}

Future<void> _pumpRow(
  WidgetTester tester, {
  required DeveloperModeValue developerMode,
  required MessageEvidenceScope scope,
  required MessageEvidenceRowData message,
  bool isAnchorMessage = false,
  VoidCallback? onOpenConversationContext,
  String searchQuery = '',
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        developerModeProvider.overrideWith(
          () => _FakeDeveloperMode(developerMode),
        ),
      ],
      child: MacosApp(
        home: MessageEvidenceRow(
          message: message,
          evidenceScope: scope,
          isAnchorMessage: isAnchorMessage,
          searchQuery: searchQuery,
          onOpenConversationContext: onOpenConversationContext,
        ),
      ),
    ),
  );
  await tester.pump();
}

MessageEvidenceRowData _message({
  bool isFromMe = false,
  bool isSelfConversation = false,
  bool senderIsMe = false,
  String senderDisplayHandle = 'Claire',
  String text = 'hello',
  String? conversationDisplayTitle,
  String? semanticKind,
  String? itemKind,
  int? associatedMessageId,
  bool hasAttributedBodySource = false,
  bool hasMessageSummaryInfo = false,
  int? sourceConversationId,
  int? errorCode,
}) {
  return MessageEvidenceRowData(
    messageId: 8796093170832,
    dateUtc: '2026-05-20T18:58:00Z',
    isFromMe: isFromMe,
    text: text,
    associatedMessageId: associatedMessageId,
    attachmentCount: 0,
    sourceConversationId: sourceConversationId,
    conversationDisplayTitle: conversationDisplayTitle,
    isSelfConversation: isSelfConversation,
    senderIsMe: senderIsMe,
    senderDisplayHandle: senderDisplayHandle,
    senderRawHandleLabel: '1 (778) 990-8506',
    semanticKind: semanticKind,
    itemKind: itemKind,
    hasAttributedBodySource: hasAttributedBodySource,
    hasMessageSummaryInfo: hasMessageSummaryInfo,
    errorCode: errorCode,
  );
}

class _FakeDeveloperMode extends DeveloperMode {
  _FakeDeveloperMode(this._value);

  final DeveloperModeValue _value;

  @override
  Future<DeveloperModeValue> build() async => _value;
}
