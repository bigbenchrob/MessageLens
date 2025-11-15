import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:remember_this_text/features/messages/application/use_cases/global_message_timeline_provider.dart';
import 'package:remember_this_text/features/messages/presentation/view/global_timeline_view.dart';
import 'package:remember_this_text/features/messages/presentation/view_model/global_timeline_controller.dart';
import 'package:remember_this_text/features/messages/presentation/view_model/message_by_id_provider.dart';
import 'package:remember_this_text/features/messages/presentation/view_model/messages_for_chat_provider.dart';

void main() {
  late GlobalTimelineState sampleState;
  late Map<int, ChatMessageListItem> messageFixtures;

  setUp(() {
    final items = [
      GlobalMessageTimelineItem(
        ordinal: 0,
        messageId: 1,
        chatId: 42,
        sentAt: DateTime.utc(2024, 1, 1),
        monthKey: '2024-01',
      ),
      GlobalMessageTimelineItem(
        ordinal: 1,
        messageId: 2,
        chatId: 42,
        sentAt: DateTime.utc(2024, 1, 2),
        monthKey: '2024-01',
      ),
    ];

    sampleState = GlobalTimelineState(
      items: items,
      totalCount: 10,
      hasMoreBefore: true,
      hasMoreAfter: true,
    );

    messageFixtures = {
      for (final item in items)
        item.messageId: ChatMessageListItem(
          id: item.messageId,
          guid: 'guid-${item.messageId}',
          isFromMe: item.messageId.isEven,
          senderName: 'Sender ${item.messageId}',
          text: 'Message body ${item.messageId}',
          sentAt: item.sentAt,
          hasAttachments: false,
          attachments: const [],
        ),
    };
  });

  ProviderScope buildView({required _FakeGlobalTimelineController controller}) {
    return ProviderScope(
      overrides: [
        globalTimelineControllerProvider().overrideWith(() => controller),
        globalTimelineBoundsProvider.overrideWith(
          (ref) async => GlobalTimelineBounds(
            earliest: DateTime.utc(2023, 1, 1),
            latest: DateTime.utc(2024, 1, 10),
          ),
        ),
        for (final entry in messageFixtures.entries)
          messageByIdProvider(
            messageId: entry.key,
          ).overrideWith((ref) async => entry.value),
      ],
      child: const MacosApp(
        debugShowCheckedModeBanner: false,
        home: GlobalTimelineView(),
      ),
    );
  }

  testWidgets('renders summary header and message rows', (tester) async {
    final controller = _FakeGlobalTimelineController(sampleState);

    await tester.pumpWidget(buildView(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('Global message timeline'), findsOneWidget);
    expect(find.text('Total messages'), findsOneWidget);
    expect(find.text('Chat 42'), findsWidgets);
    expect(find.text('Message body 1'), findsOneWidget);
  });

  testWidgets('tapping jump to newest delegates to controller', (tester) async {
    final controller = _FakeGlobalTimelineController(sampleState);

    await tester.pumpWidget(buildView(controller: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Jump to newest'));
    await tester.pump();

    expect(controller.jumpToNewestCalled, isTrue);
  });
}

class _FakeGlobalTimelineController extends GlobalTimelineController {
  _FakeGlobalTimelineController(this._state);

  final GlobalTimelineState _state;
  bool jumpToNewestCalled = false;

  @override
  Future<GlobalTimelineState> build({
    int? startAfterOrdinal,
    int? endBeforeOrdinal,
    int pageSize = 100,
  }) async {
    return _state;
  }

  @override
  Future<void> jumpToNewest() async {
    jumpToNewestCalled = true;
  }
}
